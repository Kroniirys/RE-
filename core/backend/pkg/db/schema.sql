CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS assets (
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

-- metrics_cpu_raw
CREATE TABLE IF NOT EXISTS metrics_cpu_raw (
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    usage_percent REAL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_raw_time ON metrics_cpu_raw (asset_id, time DESC);

CREATE TABLE IF NOT EXISTS metrics_cpu_1m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_usage_percent REAL NOT NULL,
    min_usage_percent REAL NOT NULL,
    max_usage_percent REAL NOT NULL,
    wavg_usage_percent REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_1m_time ON metrics_cpu_1m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_cpu_5m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_usage_percent REAL NOT NULL,
    min_usage_percent REAL NOT NULL,
    max_usage_percent REAL NOT NULL,
    wavg_usage_percent REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_5m_time ON metrics_cpu_5m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_cpu_10m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_usage_percent REAL NOT NULL,
    min_usage_percent REAL NOT NULL,
    max_usage_percent REAL NOT NULL,
    wavg_usage_percent REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_10m_time ON metrics_cpu_10m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_cpu_1h (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_usage_percent REAL NOT NULL,
    min_usage_percent REAL NOT NULL,
    max_usage_percent REAL NOT NULL,
    wavg_usage_percent REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_1h_time ON metrics_cpu_1h (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_cpu_1d (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_usage_percent REAL NOT NULL,
    min_usage_percent REAL NOT NULL,
    max_usage_percent REAL NOT NULL,
    wavg_usage_percent REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_cpu_1d_time ON metrics_cpu_1d (asset_id, time_bucket DESC);

-- metrics_ram_raw
CREATE TABLE IF NOT EXISTS metrics_ram_raw (
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    used_bytes BIGINT,
    total_bytes BIGINT
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_raw_time ON metrics_ram_raw (asset_id, time DESC);

CREATE TABLE IF NOT EXISTS metrics_ram_1m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_1m_time ON metrics_ram_1m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_ram_5m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_5m_time ON metrics_ram_5m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_ram_10m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_10m_time ON metrics_ram_10m (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_ram_1h (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_1h_time ON metrics_ram_1h (asset_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_ram_1d (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_ram_1d_time ON metrics_ram_1d (asset_id, time_bucket DESC);

-- metrics_disk_raw
CREATE TABLE IF NOT EXISTS metrics_disk_raw (
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    used_bytes BIGINT,
    total_bytes BIGINT
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_raw_time ON metrics_disk_raw (asset_id, device, time DESC);

CREATE TABLE IF NOT EXISTS metrics_disk_1m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_1m_time ON metrics_disk_1m (asset_id, device, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_disk_5m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_5m_time ON metrics_disk_5m (asset_id, device, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_disk_10m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_10m_time ON metrics_disk_10m (asset_id, device, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_disk_1h (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_1h_time ON metrics_disk_1h (asset_id, device, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_disk_1d (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    device VARCHAR(255),
    avg_used_bytes BIGINT NOT NULL,
    min_used_bytes BIGINT NOT NULL,
    max_used_bytes BIGINT NOT NULL,
    wavg_used_bytes BIGINT NOT NULL,
    avg_total_bytes BIGINT NOT NULL,
    min_total_bytes BIGINT NOT NULL,
    max_total_bytes BIGINT NOT NULL,
    wavg_total_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_disk_1d_time ON metrics_disk_1d (asset_id, device, time_bucket DESC);

-- metrics_network_raw
CREATE TABLE IF NOT EXISTS metrics_network_raw (
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    rx_bytes BIGINT,
    tx_bytes BIGINT
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_raw_time ON metrics_network_raw (asset_id, interface, time DESC);

CREATE TABLE IF NOT EXISTS metrics_network_1m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    avg_rx_bytes BIGINT NOT NULL,
    min_rx_bytes BIGINT NOT NULL,
    max_rx_bytes BIGINT NOT NULL,
    wavg_rx_bytes BIGINT NOT NULL,
    avg_tx_bytes BIGINT NOT NULL,
    min_tx_bytes BIGINT NOT NULL,
    max_tx_bytes BIGINT NOT NULL,
    wavg_tx_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_1m_time ON metrics_network_1m (asset_id, interface, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_network_5m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    avg_rx_bytes BIGINT NOT NULL,
    min_rx_bytes BIGINT NOT NULL,
    max_rx_bytes BIGINT NOT NULL,
    wavg_rx_bytes BIGINT NOT NULL,
    avg_tx_bytes BIGINT NOT NULL,
    min_tx_bytes BIGINT NOT NULL,
    max_tx_bytes BIGINT NOT NULL,
    wavg_tx_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_5m_time ON metrics_network_5m (asset_id, interface, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_network_10m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    avg_rx_bytes BIGINT NOT NULL,
    min_rx_bytes BIGINT NOT NULL,
    max_rx_bytes BIGINT NOT NULL,
    wavg_rx_bytes BIGINT NOT NULL,
    avg_tx_bytes BIGINT NOT NULL,
    min_tx_bytes BIGINT NOT NULL,
    max_tx_bytes BIGINT NOT NULL,
    wavg_tx_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_10m_time ON metrics_network_10m (asset_id, interface, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_network_1h (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    avg_rx_bytes BIGINT NOT NULL,
    min_rx_bytes BIGINT NOT NULL,
    max_rx_bytes BIGINT NOT NULL,
    wavg_rx_bytes BIGINT NOT NULL,
    avg_tx_bytes BIGINT NOT NULL,
    min_tx_bytes BIGINT NOT NULL,
    max_tx_bytes BIGINT NOT NULL,
    wavg_tx_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_1h_time ON metrics_network_1h (asset_id, interface, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_network_1d (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    interface VARCHAR(255),
    avg_rx_bytes BIGINT NOT NULL,
    min_rx_bytes BIGINT NOT NULL,
    max_rx_bytes BIGINT NOT NULL,
    wavg_rx_bytes BIGINT NOT NULL,
    avg_tx_bytes BIGINT NOT NULL,
    min_tx_bytes BIGINT NOT NULL,
    max_tx_bytes BIGINT NOT NULL,
    wavg_tx_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_network_1d_time ON metrics_network_1d (asset_id, interface, time_bucket DESC);

-- metrics_docker_raw
CREATE TABLE IF NOT EXISTS metrics_docker_raw (
    time TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    cpu_usage_percent REAL,
    ram_used_bytes BIGINT
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_raw_time ON metrics_docker_raw (container_id, time DESC);

CREATE TABLE IF NOT EXISTS metrics_docker_1m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    avg_cpu_usage_percent REAL NOT NULL,
    min_cpu_usage_percent REAL NOT NULL,
    max_cpu_usage_percent REAL NOT NULL,
    wavg_cpu_usage_percent REAL NOT NULL,
    avg_ram_used_bytes BIGINT NOT NULL,
    min_ram_used_bytes BIGINT NOT NULL,
    max_ram_used_bytes BIGINT NOT NULL,
    wavg_ram_used_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_1m_time ON metrics_docker_1m (container_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_docker_5m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    avg_cpu_usage_percent REAL NOT NULL,
    min_cpu_usage_percent REAL NOT NULL,
    max_cpu_usage_percent REAL NOT NULL,
    wavg_cpu_usage_percent REAL NOT NULL,
    avg_ram_used_bytes BIGINT NOT NULL,
    min_ram_used_bytes BIGINT NOT NULL,
    max_ram_used_bytes BIGINT NOT NULL,
    wavg_ram_used_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_5m_time ON metrics_docker_5m (container_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_docker_10m (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    avg_cpu_usage_percent REAL NOT NULL,
    min_cpu_usage_percent REAL NOT NULL,
    max_cpu_usage_percent REAL NOT NULL,
    wavg_cpu_usage_percent REAL NOT NULL,
    avg_ram_used_bytes BIGINT NOT NULL,
    min_ram_used_bytes BIGINT NOT NULL,
    max_ram_used_bytes BIGINT NOT NULL,
    wavg_ram_used_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_10m_time ON metrics_docker_10m (container_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_docker_1h (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    avg_cpu_usage_percent REAL NOT NULL,
    min_cpu_usage_percent REAL NOT NULL,
    max_cpu_usage_percent REAL NOT NULL,
    wavg_cpu_usage_percent REAL NOT NULL,
    avg_ram_used_bytes BIGINT NOT NULL,
    min_ram_used_bytes BIGINT NOT NULL,
    max_ram_used_bytes BIGINT NOT NULL,
    wavg_ram_used_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_1h_time ON metrics_docker_1h (container_id, time_bucket DESC);

CREATE TABLE IF NOT EXISTS metrics_docker_1d (
    time_bucket TIMESTAMP WITH TIME ZONE NOT NULL,
    container_id UUID REFERENCES containers(id) ON DELETE CASCADE,
    avg_cpu_usage_percent REAL NOT NULL,
    min_cpu_usage_percent REAL NOT NULL,
    max_cpu_usage_percent REAL NOT NULL,
    wavg_cpu_usage_percent REAL NOT NULL,
    avg_ram_used_bytes BIGINT NOT NULL,
    min_ram_used_bytes BIGINT NOT NULL,
    max_ram_used_bytes BIGINT NOT NULL,
    wavg_ram_used_bytes BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_metrics_docker_1d_time ON metrics_docker_1d (container_id, time_bucket DESC);

