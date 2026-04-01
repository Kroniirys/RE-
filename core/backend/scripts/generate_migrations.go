package main

import (
	"fmt"
	"os"
	"strings"
)

var intervals = []string{"1m", "5m", "10m", "1h", "1d"}

var upSQL strings.Builder
var downSQL strings.Builder

func applyBaseTables() {
	upSQL.WriteString(`CREATE TABLE IF NOT EXISTS assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hostname VARCHAR(255) NOT NULL,
    ip_address VARCHAR(50) NOT NULL,
    port INT,
    status VARCHAR(50) DEFAULT 'offline',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS containers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    docker_container_id VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    image VARCHAR(255),
    state VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

`)
	downSQL.WriteString("DROP TABLE IF EXISTS containers CASCADE;\n")
	downSQL.WriteString("DROP TABLE IF EXISTS assets CASCADE;\n\n")
}

func applyMetricType(name string, dimensions []string, values []string, target string) {
	// RAW TABLE
	rawName := fmt.Sprintf("metrics_%s_raw", name)
	upSQL.WriteString(fmt.Sprintf("-- %s\nCREATE TABLE IF NOT EXISTS %s (\n", rawName, rawName))
	upSQL.WriteString("    time TIMESTAMP WITH TIME ZONE NOT NULL,\n")
	if target == "container" {
		upSQL.WriteString("    container_id UUID REFERENCES containers(id) ON DELETE CASCADE")
	} else {
		upSQL.WriteString("    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE")
	}
	for _, dim := range dimensions {
		upSQL.WriteString(fmt.Sprintf(",\n    %s", dim))
	}
	for _, val := range values {
		upSQL.WriteString(fmt.Sprintf(",\n    %s", val))
	}
	upSQL.WriteString("\n);\n")
	idxCols := "asset_id"
	if target == "container" {
		idxCols = "container_id"
	}
	for _, dim := range dimensions {
		idxCols += ", " + strings.Split(dim, " ")[0]
	}
	upSQL.WriteString(fmt.Sprintf("CREATE INDEX IF NOT EXISTS idx_%s_time ON %s (%s, time DESC);\n\n", rawName, rawName, idxCols))

	downSQL.WriteString(fmt.Sprintf("DROP TABLE IF EXISTS %s CASCADE;\n", rawName))

	// INTERVAL TABLES
	for _, interval := range intervals {
		tableName := fmt.Sprintf("metrics_%s_%s", name, interval)
		upSQL.WriteString(fmt.Sprintf("CREATE TABLE IF NOT EXISTS %s (\n", tableName))
		upSQL.WriteString("    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,\n")
		if target == "container" {
			upSQL.WriteString("    container_id UUID REFERENCES containers(id) ON DELETE CASCADE")
		} else {
			upSQL.WriteString("    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE")
		}
		for _, dim := range dimensions {
			upSQL.WriteString(fmt.Sprintf(",\n    %s", dim))
		}
		for _, val := range values {
			parts := strings.Split(val, " ")
			colName := parts[0]
			colType := parts[1]
			upSQL.WriteString(fmt.Sprintf(",\n    avg_%[1]s %[2]s NOT NULL,\n    min_%[1]s %[2]s NOT NULL,\n    max_%[1]s %[2]s NOT NULL,\n    wavg_%[1]s %[2]s NOT NULL", colName, colType))
		}
		upSQL.WriteString("\n);\n")
		upSQL.WriteString(fmt.Sprintf("CREATE INDEX IF NOT EXISTS idx_%s_time ON %s (%s, time_bucket DESC);\n\n", tableName, tableName, idxCols))
		
		downSQL.WriteString(fmt.Sprintf("DROP TABLE IF EXISTS %s CASCADE;\n", tableName))
	}
}

func main() {
	applyBaseTables()

	// CPU
	applyMetricType("cpu", nil, []string{"usage_percent REAL"}, "asset")
	// RAM
	applyMetricType("ram", nil, []string{"used_bytes BIGINT", "total_bytes BIGINT"}, "asset")
	// DISK
	applyMetricType("disk", []string{"device VARCHAR(255)"}, []string{"used_bytes BIGINT", "total_bytes BIGINT"}, "asset")
	// NETWORK
	applyMetricType("network", []string{"interface VARCHAR(255)"}, []string{"rx_bytes BIGINT", "tx_bytes BIGINT"}, "asset")
	// DOCKER
	applyMetricType("docker", nil, []string{"cpu_usage_percent REAL", "ram_used_bytes BIGINT"}, "container")

	os.MkdirAll("../pkg/db/migrations", 0755)
	
	err := os.WriteFile("../pkg/db/migrations/000002_init_assets_metrics.up.sql", []byte(upSQL.String()), 0644)
	if err != nil {
		fmt.Println("Error write up:", err)
	}
	
	// append to schema.sql
	schemaBytes, _ := os.ReadFile("../pkg/db/schema.sql")
	schemaStr := string(schemaBytes)
	if !strings.Contains(schemaStr, "CREATE TABLE IF NOT EXISTS assets") {
		os.WriteFile("../pkg/db/schema.sql", []byte(schemaStr+"\n\n"+upSQL.String()), 0644)
	}

	// For down.sql we should write them in reverse order (to respect foreign keys)
	// Actually down.sql drops are CASCADE so reverse order is nice but cascade works anyway.
	// But let's reverse the downSQL lines:
	var downLinesReversed []string
	lines := strings.Split(strings.TrimSpace(downSQL.String()), "\n")
	for i := len(lines) - 1; i >= 0; i-- {
		if lines[i] != "" {
			downLinesReversed = append(downLinesReversed, lines[i])
		}
	}
	os.WriteFile("../pkg/db/migrations/000002_init_assets_metrics.down.sql", []byte(strings.Join(downLinesReversed, "\n")+"\n"), 0644)
	
	fmt.Println("Done generating SQL files.")
}
