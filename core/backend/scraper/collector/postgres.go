package collector

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	"re-backend/config"
	agentv1 "re-backend/scraper/proto/v1"
)

type PostgresCollector struct {
	cfg        config.RemoteDBConfig
	db         *sql.DB
	lastSample time.Time
	lastXacts  int64
}

func NewPostgresCollector(cfg config.RemoteDBConfig) (*PostgresCollector, error) {
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable",
		cfg.User, cfg.Pass, cfg.Host, cfg.Port, cfg.Database)

	db, err := sql.Open("pgx", connStr)
	if err != nil {
		return nil, fmt.Errorf("open connection: %w", err)
	}

	// Set conservative connection limits for monitoring
	db.SetMaxOpenConns(2)
	db.SetMaxIdleConns(1)
	db.SetConnMaxLifetime(5 * time.Minute)

	return &PostgresCollector{
		cfg: cfg,
		db:  db,
	}, nil
}

func (c *PostgresCollector) Close() error {
	if c.db != nil {
		return c.db.Close()
	}
	return nil
}

func (c *PostgresCollector) GetMetrics(ctx context.Context) (*agentv1.DatabaseMetric, error) {
	// Ping to check if connection is still alive before querying
	if err := c.db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("database is unreachable: %w", err)
	}

	metric := &agentv1.DatabaseMetric{
		DbId:      c.cfg.ID,
		DbType:    "postgres",
		Host:      c.cfg.Host,
		Timestamp: time.Now().Unix(),
	}

	// 1. Session Stats
	var active, idle int
	rows, err := c.db.QueryContext(ctx, "SELECT count(*), state FROM pg_stat_activity GROUP BY state")
	if err != nil {
		return nil, fmt.Errorf("query sessions: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var count int
		var state sql.NullString
		if err := rows.Scan(&count, &state); err != nil {
			continue
		}
		if !state.Valid {
			continue
		}
		switch state.String {
		case "active":
			active += count
		case "idle":
			idle += count
		}
	}
	metric.ActiveSessions = int32(active)
	metric.IdleSessions = int32(idle)

	// 2. Database Size
	var size int64
	err = c.db.QueryRowContext(ctx, "SELECT pg_database_size(current_database())").Scan(&size)
	if err == nil {
		metric.SizeBytes = size
	}

	// 3. Cache Hit Ratio
	var cacheHit float32
	err = c.db.QueryRowContext(ctx, `
		SELECT 
			COALESCE(sum(blks_hit) * 100.0 / NULLIF(sum(blks_hit + blks_read), 0), 0)
		FROM pg_stat_database 
		WHERE datname = current_database()
	`).Scan(&cacheHit)
	if err == nil {
		metric.CacheHitRatio = cacheHit
	}

	// 4. TPS (Transactions Per Second) calculation
	var currentXacts int64
	err = c.db.QueryRowContext(ctx, `
		SELECT sum(xact_commit + xact_rollback) 
		FROM pg_stat_database 
		WHERE datname = current_database()
	`).Scan(&currentXacts)
	
	if err == nil {
		now := time.Now()
		if !c.lastSample.IsZero() {
			duration := now.Sub(c.lastSample).Seconds()
			if duration > 0 {
				metric.Tps = float32(float64(currentXacts-c.lastXacts) / duration)
			}
		}
		c.lastSample = now
		c.lastXacts = currentXacts
	}

	return metric, nil
}
