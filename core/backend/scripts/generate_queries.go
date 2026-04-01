package main

import (
	"fmt"
	"os"
	"strings"
)

type ValueDef struct {
	Name string
	Type string // "real" or "bigint"
}

type MetricDef struct {
	Name   string
	Target string   // "asset_id" or "container_id"
	Dims   []string // e.g., "device", "interface"
	Vals   []ValueDef
}

var intervals = map[string]string{
	"1m":  "minute",
	"5m":  "minute", // Postgres date_trunc doesn't do 5 min easily directly, but SQLC doesn't care about the bucket logic inside date_trunc if we just group by it. Actually, wait! date_trunc('minute') buckets to 1 minute, not 5. To bucket by 5 minutes, we need a special formula, or we can just pass the time_bucket as a sqlc argument.
	"10m": "minute",
	"1h":  "hour",
	"1d":  "day",
}

// Instead of date_trunc inside SQL, we can pass the time_bucket as an arg from Go!
// This is much safer and precise. Go worker knows exactly the bucket it is computing for.
// But we might be aggregating multiple records that span the bucket. Wait, the WHERE clause restricts it: `time >= start_time AND time < end_time`. Since the worker runs exactly for that bucket, all rows belong to `sqlc.arg('time_bucket')`.
// So we just use `sqlc.arg('time_bucket')` for the time_bucket column!

var metricsSQL strings.Builder

func applyMetricType(m MetricDef) {
	upperName := strings.ToUpper(m.Name[:1]) + m.Name[1:]
	
	// 1. Insert Raw
	metricsSQL.WriteString(fmt.Sprintf("-- name: Insert%sRaw :copyfrom\n", upperName))
	cols := []string{"time", m.Target}
	cols = append(cols, m.Dims...)
	for _, v := range m.Vals {
		cols = append(cols, v.Name)
	}
	// copyfrom doesn't use VALUES ($1) it just uses the columns
	metricsSQL.WriteString(fmt.Sprintf("INSERT INTO metrics_%s_raw (%s) VALUES (", m.Name, strings.Join(cols, ", ")))
	for i := range cols {
		if i > 0 {
			metricsSQL.WriteString(", ")
		}
		metricsSQL.WriteString(fmt.Sprintf("$%d", i+1))
	}
	metricsSQL.WriteString(");\n\n")

	// 2. Aggregate Raw To Interval
	for interval := range intervals { // "1m", "5m" etc.
		upperInterval := strings.ToUpper(interval[:1]) + interval[1:]
		funcName := fmt.Sprintf("Aggregate%sRawTo%s", upperName, upperInterval)
		tableName := fmt.Sprintf("metrics_%s_%s", m.Name, interval)
		rawTableName := fmt.Sprintf("metrics_%s_raw", m.Name)

		metricsSQL.WriteString(fmt.Sprintf("-- name: %s :exec\n", funcName))
		
		// lagging partition
		partitionCols := m.Target
		for _, d := range m.Dims {
			partitionCols += ", " + d
		}
		
		metricsSQL.WriteString("WITH lagged AS (\n")
		metricsSQL.WriteString(fmt.Sprintf("  SELECT time, %s, ", partitionCols))
		var valNames []string
		for _, v := range m.Vals { valNames = append(valNames, v.Name) }
		metricsSQL.WriteString(strings.Join(valNames, ", "))
		metricsSQL.WriteString(fmt.Sprintf(",\n         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY %s ORDER BY time))) AS duration\n", partitionCols))
		metricsSQL.WriteString(fmt.Sprintf("  FROM %s\n", rawTableName))
		metricsSQL.WriteString("  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')\n")
		metricsSQL.WriteString(")\n")
		
		// Insert columns
		insCols := []string{"time_bucket", m.Target}
		insCols = append(insCols, m.Dims...)
		for _, v := range m.Vals {
			insCols = append(insCols, fmt.Sprintf("avg_%s", v.Name))
			insCols = append(insCols, fmt.Sprintf("min_%s", v.Name))
			insCols = append(insCols, fmt.Sprintf("max_%s", v.Name))
			insCols = append(insCols, fmt.Sprintf("wavg_%s", v.Name))
		}
		metricsSQL.WriteString(fmt.Sprintf("INSERT INTO %s (%s)\n", tableName, strings.Join(insCols, ", ")))
		
		// Select values
		selCols := []string{"sqlc.arg('time_bucket')"}
		selCols = append(selCols, m.Target)
		selCols = append(selCols, m.Dims...)
		for _, v := range m.Vals {
			selCols = append(selCols, fmt.Sprintf("COALESCE(AVG(%s), 0)::%s", v.Name, v.Type))
			selCols = append(selCols, fmt.Sprintf("COALESCE(MIN(%s), 0)::%s", v.Name, v.Type))
			selCols = append(selCols, fmt.Sprintf("COALESCE(MAX(%s), 0)::%s", v.Name, v.Type))
			sumW := "SUM(COALESCE(duration, 1))"
			wavgCalc := fmt.Sprintf("COALESCE((SUM(%s * COALESCE(duration, 1)) / NULLIF(%s, 0)), 0)::%s", v.Name, sumW, v.Type)
			selCols = append(selCols, wavgCalc)
		}
		metricsSQL.WriteString(fmt.Sprintf("SELECT %s\n", strings.Join(selCols, ", ")))
		metricsSQL.WriteString("FROM lagged\n")
		
		groupCols := []string{"1", "2"}
		for i := range m.Dims {
			groupCols = append(groupCols, fmt.Sprintf("%d", i+3))
		}
		metricsSQL.WriteString(fmt.Sprintf("GROUP BY %s;\n\n", strings.Join(groupCols, ", ")))
	}
	
	// 3. Delete Raw
	metricsSQL.WriteString(fmt.Sprintf("-- name: DeleteOld%sRaw :exec\n", upperName))
	metricsSQL.WriteString(fmt.Sprintf("DELETE FROM metrics_%s_raw WHERE time < sqlc.arg('threshold');\n\n", m.Name))
	
	// 4. Delete Intervals
	for interval := range intervals {
		upperInterval := strings.ToUpper(interval[:1]) + interval[1:]
		metricsSQL.WriteString(fmt.Sprintf("-- name: DeleteOld%s%s :exec\n", upperName, upperInterval))
		metricsSQL.WriteString(fmt.Sprintf("DELETE FROM metrics_%s_%s WHERE time_bucket < sqlc.arg('threshold');\n\n", m.Name, interval))
	}
}

func main() {
	metrics := []MetricDef{
		{"cpu", "asset_id", nil, []ValueDef{{"usage_percent", "real"}}},
		{"ram", "asset_id", nil, []ValueDef{{"used_bytes", "bigint"}, {"total_bytes", "bigint"}}},
		{"disk", "asset_id", []string{"device"}, []ValueDef{{"used_bytes", "bigint"}, {"total_bytes", "bigint"}}},
		{"network", "asset_id", []string{"interface"}, []ValueDef{{"rx_bytes", "bigint"}, {"tx_bytes", "bigint"}}},
		{"docker", "container_id", nil, []ValueDef{{"cpu_usage_percent", "real"}, {"ram_used_bytes", "bigint"}}},
	}

	for _, m := range metrics {
		applyMetricType(m)
	}

	err := os.WriteFile("../pkg/db/queries/metrics.sql", []byte(metricsSQL.String()), 0644)
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("Done generating metrics.sql")
	}
}
