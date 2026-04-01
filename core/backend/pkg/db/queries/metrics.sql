-- name: InsertCpuRaw :copyfrom
INSERT INTO metrics_cpu_raw (time, asset_id, usage_percent) VALUES ($1, $2, $3);

-- name: AggregateCpuRawTo1m :exec
WITH lagged AS (
  SELECT time, asset_id, usage_percent,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_cpu_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_cpu_1m (time_bucket, asset_id, avg_usage_percent, min_usage_percent, max_usage_percent, wavg_usage_percent)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(usage_percent), 0)::real, COALESCE(MIN(usage_percent), 0)::real, COALESCE(MAX(usage_percent), 0)::real, COALESCE((SUM(usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real
FROM lagged
GROUP BY 1, 2;

-- name: AggregateCpuRawTo5m :exec
WITH lagged AS (
  SELECT time, asset_id, usage_percent,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_cpu_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_cpu_5m (time_bucket, asset_id, avg_usage_percent, min_usage_percent, max_usage_percent, wavg_usage_percent)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(usage_percent), 0)::real, COALESCE(MIN(usage_percent), 0)::real, COALESCE(MAX(usage_percent), 0)::real, COALESCE((SUM(usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real
FROM lagged
GROUP BY 1, 2;

-- name: AggregateCpuRawTo10m :exec
WITH lagged AS (
  SELECT time, asset_id, usage_percent,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_cpu_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_cpu_10m (time_bucket, asset_id, avg_usage_percent, min_usage_percent, max_usage_percent, wavg_usage_percent)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(usage_percent), 0)::real, COALESCE(MIN(usage_percent), 0)::real, COALESCE(MAX(usage_percent), 0)::real, COALESCE((SUM(usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real
FROM lagged
GROUP BY 1, 2;

-- name: AggregateCpuRawTo1h :exec
WITH lagged AS (
  SELECT time, asset_id, usage_percent,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_cpu_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_cpu_1h (time_bucket, asset_id, avg_usage_percent, min_usage_percent, max_usage_percent, wavg_usage_percent)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(usage_percent), 0)::real, COALESCE(MIN(usage_percent), 0)::real, COALESCE(MAX(usage_percent), 0)::real, COALESCE((SUM(usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real
FROM lagged
GROUP BY 1, 2;

-- name: AggregateCpuRawTo1d :exec
WITH lagged AS (
  SELECT time, asset_id, usage_percent,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_cpu_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_cpu_1d (time_bucket, asset_id, avg_usage_percent, min_usage_percent, max_usage_percent, wavg_usage_percent)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(usage_percent), 0)::real, COALESCE(MIN(usage_percent), 0)::real, COALESCE(MAX(usage_percent), 0)::real, COALESCE((SUM(usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real
FROM lagged
GROUP BY 1, 2;

-- name: DeleteOldCpuRaw :exec
DELETE FROM metrics_cpu_raw WHERE time < sqlc.arg('threshold');

-- name: DeleteOldCpu10m :exec
DELETE FROM metrics_cpu_10m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldCpu1h :exec
DELETE FROM metrics_cpu_1h WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldCpu1d :exec
DELETE FROM metrics_cpu_1d WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldCpu1m :exec
DELETE FROM metrics_cpu_1m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldCpu5m :exec
DELETE FROM metrics_cpu_5m WHERE time_bucket < sqlc.arg('threshold');

-- name: InsertRamRaw :copyfrom
INSERT INTO metrics_ram_raw (time, asset_id, used_bytes, total_bytes) VALUES ($1, $2, $3, $4);

-- name: AggregateRamRawTo1d :exec
WITH lagged AS (
  SELECT time, asset_id, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_ram_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_ram_1d (time_bucket, asset_id, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateRamRawTo1m :exec
WITH lagged AS (
  SELECT time, asset_id, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_ram_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_ram_1m (time_bucket, asset_id, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateRamRawTo5m :exec
WITH lagged AS (
  SELECT time, asset_id, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_ram_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_ram_5m (time_bucket, asset_id, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateRamRawTo10m :exec
WITH lagged AS (
  SELECT time, asset_id, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_ram_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_ram_10m (time_bucket, asset_id, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateRamRawTo1h :exec
WITH lagged AS (
  SELECT time, asset_id, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id ORDER BY time))) AS duration
  FROM metrics_ram_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_ram_1h (time_bucket, asset_id, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: DeleteOldRamRaw :exec
DELETE FROM metrics_ram_raw WHERE time < sqlc.arg('threshold');

-- name: DeleteOldRam1m :exec
DELETE FROM metrics_ram_1m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldRam5m :exec
DELETE FROM metrics_ram_5m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldRam10m :exec
DELETE FROM metrics_ram_10m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldRam1h :exec
DELETE FROM metrics_ram_1h WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldRam1d :exec
DELETE FROM metrics_ram_1d WHERE time_bucket < sqlc.arg('threshold');

-- name: InsertDiskRaw :copyfrom
INSERT INTO metrics_disk_raw (time, asset_id, device, used_bytes, total_bytes) VALUES ($1, $2, $3, $4, $5);

-- name: AggregateDiskRawTo1m :exec
WITH lagged AS (
  SELECT time, asset_id, device, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, device ORDER BY time))) AS duration
  FROM metrics_disk_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_disk_1m (time_bucket, asset_id, device, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, device, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateDiskRawTo5m :exec
WITH lagged AS (
  SELECT time, asset_id, device, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, device ORDER BY time))) AS duration
  FROM metrics_disk_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_disk_5m (time_bucket, asset_id, device, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, device, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateDiskRawTo10m :exec
WITH lagged AS (
  SELECT time, asset_id, device, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, device ORDER BY time))) AS duration
  FROM metrics_disk_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_disk_10m (time_bucket, asset_id, device, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, device, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateDiskRawTo1h :exec
WITH lagged AS (
  SELECT time, asset_id, device, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, device ORDER BY time))) AS duration
  FROM metrics_disk_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_disk_1h (time_bucket, asset_id, device, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, device, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateDiskRawTo1d :exec
WITH lagged AS (
  SELECT time, asset_id, device, used_bytes, total_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, device ORDER BY time))) AS duration
  FROM metrics_disk_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_disk_1d (time_bucket, asset_id, device, avg_used_bytes, min_used_bytes, max_used_bytes, wavg_used_bytes, avg_total_bytes, min_total_bytes, max_total_bytes, wavg_total_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, device, COALESCE(AVG(used_bytes), 0)::bigint, COALESCE(MIN(used_bytes), 0)::bigint, COALESCE(MAX(used_bytes), 0)::bigint, COALESCE((SUM(used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(total_bytes), 0)::bigint, COALESCE(MIN(total_bytes), 0)::bigint, COALESCE(MAX(total_bytes), 0)::bigint, COALESCE((SUM(total_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: DeleteOldDiskRaw :exec
DELETE FROM metrics_disk_raw WHERE time < sqlc.arg('threshold');

-- name: DeleteOldDisk1m :exec
DELETE FROM metrics_disk_1m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDisk5m :exec
DELETE FROM metrics_disk_5m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDisk10m :exec
DELETE FROM metrics_disk_10m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDisk1h :exec
DELETE FROM metrics_disk_1h WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDisk1d :exec
DELETE FROM metrics_disk_1d WHERE time_bucket < sqlc.arg('threshold');

-- name: InsertNetworkRaw :copyfrom
INSERT INTO metrics_network_raw (time, asset_id, interface, rx_bytes, tx_bytes) VALUES ($1, $2, $3, $4, $5);

-- name: AggregateNetworkRawTo1m :exec
WITH lagged AS (
  SELECT time, asset_id, interface, rx_bytes, tx_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, interface ORDER BY time))) AS duration
  FROM metrics_network_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_network_1m (time_bucket, asset_id, interface, avg_rx_bytes, min_rx_bytes, max_rx_bytes, wavg_rx_bytes, avg_tx_bytes, min_tx_bytes, max_tx_bytes, wavg_tx_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, interface, COALESCE(AVG(rx_bytes), 0)::bigint, COALESCE(MIN(rx_bytes), 0)::bigint, COALESCE(MAX(rx_bytes), 0)::bigint, COALESCE((SUM(rx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(tx_bytes), 0)::bigint, COALESCE(MIN(tx_bytes), 0)::bigint, COALESCE(MAX(tx_bytes), 0)::bigint, COALESCE((SUM(tx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateNetworkRawTo5m :exec
WITH lagged AS (
  SELECT time, asset_id, interface, rx_bytes, tx_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, interface ORDER BY time))) AS duration
  FROM metrics_network_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_network_5m (time_bucket, asset_id, interface, avg_rx_bytes, min_rx_bytes, max_rx_bytes, wavg_rx_bytes, avg_tx_bytes, min_tx_bytes, max_tx_bytes, wavg_tx_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, interface, COALESCE(AVG(rx_bytes), 0)::bigint, COALESCE(MIN(rx_bytes), 0)::bigint, COALESCE(MAX(rx_bytes), 0)::bigint, COALESCE((SUM(rx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(tx_bytes), 0)::bigint, COALESCE(MIN(tx_bytes), 0)::bigint, COALESCE(MAX(tx_bytes), 0)::bigint, COALESCE((SUM(tx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateNetworkRawTo10m :exec
WITH lagged AS (
  SELECT time, asset_id, interface, rx_bytes, tx_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, interface ORDER BY time))) AS duration
  FROM metrics_network_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_network_10m (time_bucket, asset_id, interface, avg_rx_bytes, min_rx_bytes, max_rx_bytes, wavg_rx_bytes, avg_tx_bytes, min_tx_bytes, max_tx_bytes, wavg_tx_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, interface, COALESCE(AVG(rx_bytes), 0)::bigint, COALESCE(MIN(rx_bytes), 0)::bigint, COALESCE(MAX(rx_bytes), 0)::bigint, COALESCE((SUM(rx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(tx_bytes), 0)::bigint, COALESCE(MIN(tx_bytes), 0)::bigint, COALESCE(MAX(tx_bytes), 0)::bigint, COALESCE((SUM(tx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateNetworkRawTo1h :exec
WITH lagged AS (
  SELECT time, asset_id, interface, rx_bytes, tx_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, interface ORDER BY time))) AS duration
  FROM metrics_network_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_network_1h (time_bucket, asset_id, interface, avg_rx_bytes, min_rx_bytes, max_rx_bytes, wavg_rx_bytes, avg_tx_bytes, min_tx_bytes, max_tx_bytes, wavg_tx_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, interface, COALESCE(AVG(rx_bytes), 0)::bigint, COALESCE(MIN(rx_bytes), 0)::bigint, COALESCE(MAX(rx_bytes), 0)::bigint, COALESCE((SUM(rx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(tx_bytes), 0)::bigint, COALESCE(MIN(tx_bytes), 0)::bigint, COALESCE(MAX(tx_bytes), 0)::bigint, COALESCE((SUM(tx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: AggregateNetworkRawTo1d :exec
WITH lagged AS (
  SELECT time, asset_id, interface, rx_bytes, tx_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY asset_id, interface ORDER BY time))) AS duration
  FROM metrics_network_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_network_1d (time_bucket, asset_id, interface, avg_rx_bytes, min_rx_bytes, max_rx_bytes, wavg_rx_bytes, avg_tx_bytes, min_tx_bytes, max_tx_bytes, wavg_tx_bytes)
SELECT sqlc.arg('time_bucket'), asset_id, interface, COALESCE(AVG(rx_bytes), 0)::bigint, COALESCE(MIN(rx_bytes), 0)::bigint, COALESCE(MAX(rx_bytes), 0)::bigint, COALESCE((SUM(rx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint, COALESCE(AVG(tx_bytes), 0)::bigint, COALESCE(MIN(tx_bytes), 0)::bigint, COALESCE(MAX(tx_bytes), 0)::bigint, COALESCE((SUM(tx_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2, 3;

-- name: DeleteOldNetworkRaw :exec
DELETE FROM metrics_network_raw WHERE time < sqlc.arg('threshold');

-- name: DeleteOldNetwork1h :exec
DELETE FROM metrics_network_1h WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldNetwork1d :exec
DELETE FROM metrics_network_1d WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldNetwork1m :exec
DELETE FROM metrics_network_1m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldNetwork5m :exec
DELETE FROM metrics_network_5m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldNetwork10m :exec
DELETE FROM metrics_network_10m WHERE time_bucket < sqlc.arg('threshold');

-- name: InsertDockerRaw :copyfrom
INSERT INTO metrics_docker_raw (time, container_id, cpu_usage_percent, ram_used_bytes) VALUES ($1, $2, $3, $4);

-- name: AggregateDockerRawTo1m :exec
WITH lagged AS (
  SELECT time, container_id, cpu_usage_percent, ram_used_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY container_id ORDER BY time))) AS duration
  FROM metrics_docker_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_docker_1m (time_bucket, container_id, avg_cpu_usage_percent, min_cpu_usage_percent, max_cpu_usage_percent, wavg_cpu_usage_percent, avg_ram_used_bytes, min_ram_used_bytes, max_ram_used_bytes, wavg_ram_used_bytes)
SELECT sqlc.arg('time_bucket'), container_id, COALESCE(AVG(cpu_usage_percent), 0)::real, COALESCE(MIN(cpu_usage_percent), 0)::real, COALESCE(MAX(cpu_usage_percent), 0)::real, COALESCE((SUM(cpu_usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real, COALESCE(AVG(ram_used_bytes), 0)::bigint, COALESCE(MIN(ram_used_bytes), 0)::bigint, COALESCE(MAX(ram_used_bytes), 0)::bigint, COALESCE((SUM(ram_used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateDockerRawTo5m :exec
WITH lagged AS (
  SELECT time, container_id, cpu_usage_percent, ram_used_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY container_id ORDER BY time))) AS duration
  FROM metrics_docker_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_docker_5m (time_bucket, container_id, avg_cpu_usage_percent, min_cpu_usage_percent, max_cpu_usage_percent, wavg_cpu_usage_percent, avg_ram_used_bytes, min_ram_used_bytes, max_ram_used_bytes, wavg_ram_used_bytes)
SELECT sqlc.arg('time_bucket'), container_id, COALESCE(AVG(cpu_usage_percent), 0)::real, COALESCE(MIN(cpu_usage_percent), 0)::real, COALESCE(MAX(cpu_usage_percent), 0)::real, COALESCE((SUM(cpu_usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real, COALESCE(AVG(ram_used_bytes), 0)::bigint, COALESCE(MIN(ram_used_bytes), 0)::bigint, COALESCE(MAX(ram_used_bytes), 0)::bigint, COALESCE((SUM(ram_used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateDockerRawTo10m :exec
WITH lagged AS (
  SELECT time, container_id, cpu_usage_percent, ram_used_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY container_id ORDER BY time))) AS duration
  FROM metrics_docker_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_docker_10m (time_bucket, container_id, avg_cpu_usage_percent, min_cpu_usage_percent, max_cpu_usage_percent, wavg_cpu_usage_percent, avg_ram_used_bytes, min_ram_used_bytes, max_ram_used_bytes, wavg_ram_used_bytes)
SELECT sqlc.arg('time_bucket'), container_id, COALESCE(AVG(cpu_usage_percent), 0)::real, COALESCE(MIN(cpu_usage_percent), 0)::real, COALESCE(MAX(cpu_usage_percent), 0)::real, COALESCE((SUM(cpu_usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real, COALESCE(AVG(ram_used_bytes), 0)::bigint, COALESCE(MIN(ram_used_bytes), 0)::bigint, COALESCE(MAX(ram_used_bytes), 0)::bigint, COALESCE((SUM(ram_used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateDockerRawTo1h :exec
WITH lagged AS (
  SELECT time, container_id, cpu_usage_percent, ram_used_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY container_id ORDER BY time))) AS duration
  FROM metrics_docker_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_docker_1h (time_bucket, container_id, avg_cpu_usage_percent, min_cpu_usage_percent, max_cpu_usage_percent, wavg_cpu_usage_percent, avg_ram_used_bytes, min_ram_used_bytes, max_ram_used_bytes, wavg_ram_used_bytes)
SELECT sqlc.arg('time_bucket'), container_id, COALESCE(AVG(cpu_usage_percent), 0)::real, COALESCE(MIN(cpu_usage_percent), 0)::real, COALESCE(MAX(cpu_usage_percent), 0)::real, COALESCE((SUM(cpu_usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real, COALESCE(AVG(ram_used_bytes), 0)::bigint, COALESCE(MIN(ram_used_bytes), 0)::bigint, COALESCE(MAX(ram_used_bytes), 0)::bigint, COALESCE((SUM(ram_used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: AggregateDockerRawTo1d :exec
WITH lagged AS (
  SELECT time, container_id, cpu_usage_percent, ram_used_bytes,
         EXTRACT(EPOCH FROM (time - LAG(time) OVER (PARTITION BY container_id ORDER BY time))) AS duration
  FROM metrics_docker_raw
  WHERE time >= sqlc.arg('start_time') AND time < sqlc.arg('end_time')
)
INSERT INTO metrics_docker_1d (time_bucket, container_id, avg_cpu_usage_percent, min_cpu_usage_percent, max_cpu_usage_percent, wavg_cpu_usage_percent, avg_ram_used_bytes, min_ram_used_bytes, max_ram_used_bytes, wavg_ram_used_bytes)
SELECT sqlc.arg('time_bucket'), container_id, COALESCE(AVG(cpu_usage_percent), 0)::real, COALESCE(MIN(cpu_usage_percent), 0)::real, COALESCE(MAX(cpu_usage_percent), 0)::real, COALESCE((SUM(cpu_usage_percent * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::real, COALESCE(AVG(ram_used_bytes), 0)::bigint, COALESCE(MIN(ram_used_bytes), 0)::bigint, COALESCE(MAX(ram_used_bytes), 0)::bigint, COALESCE((SUM(ram_used_bytes * COALESCE(duration, 1)) / NULLIF(SUM(COALESCE(duration, 1)), 0)), 0)::bigint
FROM lagged
GROUP BY 1, 2;

-- name: DeleteOldDockerRaw :exec
DELETE FROM metrics_docker_raw WHERE time < sqlc.arg('threshold');

-- name: DeleteOldDocker1h :exec
DELETE FROM metrics_docker_1h WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDocker1d :exec
DELETE FROM metrics_docker_1d WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDocker1m :exec
DELETE FROM metrics_docker_1m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDocker5m :exec
DELETE FROM metrics_docker_5m WHERE time_bucket < sqlc.arg('threshold');

-- name: DeleteOldDocker10m :exec
DELETE FROM metrics_docker_10m WHERE time_bucket < sqlc.arg('threshold');

