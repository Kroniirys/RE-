package workers

import (
	"context"

	"re-backend/pkg/db/repository"
	"re-backend/pkg/logger"

	"go.uber.org/zap"
)

type WorkerManager struct {
	q *db.Queries
}

func NewWorkerManager(q *db.Queries) *WorkerManager {
	return &WorkerManager{q: q}
}

// Start initiates all background goroutines for processing timeseries data
func (w *WorkerManager) Start(ctx context.Context) {
	logger.Server.Info("Starting Background Workers system", zap.String("module", "workers"))

	go w.RunMetricsAggregator(ctx)
	go w.RunMetricsCleaner(ctx)
}
