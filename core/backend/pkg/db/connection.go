package db

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"re-backend/config"
	"re-backend/pkg/logger"
)

// InitPool initializes a new PostgreSQL connection pool using the provided configuration.
func InitPool(cfg *config.Config) (*pgxpool.Pool, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	poolConfig, err := pgxpool.ParseConfig(cfg.Database.GetURL())
	if err != nil {
		return nil, fmt.Errorf("unable to parse database URL: %w", err)
	}

	// Set pool parameters from config
	poolConfig.MaxConns = int32(cfg.Database.MaxOpenConns)
	poolConfig.MinConns = int32(cfg.Database.MaxIdleConns)
	poolConfig.MaxConnLifetime = cfg.Database.ConnMaxLifetime

	// Initialize pool
	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, fmt.Errorf("unable to create connection pool: %w", err)
	}

	// Ping the database to ensure connection is established
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("unable to ping database: %w", err)
	}

	logger.Server.Info("Database connection pool initialized successfully")
	return pool, nil
}
