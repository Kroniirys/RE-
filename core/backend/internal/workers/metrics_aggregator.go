package workers

import (
	"context"
	"time"

	"go.uber.org/zap"
	"re-backend/pkg/logger"
)

// RunMetricsAggregator ticks every minute to aggregate from `_raw` tables into `_1m` tables.
// For longer intervals like `_5m`, `_10m`, `_1h`, `_1d`, the ticking logic checks if the bucket boundary is reached.
func (w *WorkerManager) RunMetricsAggregator(ctx context.Context) {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			logger.Server.Info("Stopping Metrics Aggregator", zap.String("module", "workers"))
			return
		case t := <-ticker.C:
			w.aggregateAll(ctx, t)
		}
	}
}

func (w *WorkerManager) aggregateAll(ctx context.Context, now time.Time) {
	// 1 Minute interval boundary
	// start1m := now.Add(-time.Minute).Truncate(time.Minute)
	// end1m := start1m.Add(time.Minute)
	
	// Example Call to SQLC:
	// w.q.AggregateCpuRawTo1m(ctx, db.AggregateCpuRawTo1mParams{ StartTime: start1m, EndTime: end1m, TimeBucket: start1m })
	// w.q.AggregateRamRawTo1m(ctx, ...)
	// w.q.AggregateDiskRawTo1m(ctx, ...)
	// w.q.AggregateNetworkRawTo1m(ctx, ...)
	// w.q.AggregateDockerRawTo1m(ctx, ...)

	// 5 Minute interval boundary
	if now.Minute()%5 == 0 {
		// start5m := now.Add(-5 * time.Minute).Truncate(time.Minute)
		// ... call Aggregate...RawTo5m
	}

	// 1 Hour interval boundary
	if now.Minute() == 0 {
		// start1h := now.Add(-time.Hour).Truncate(time.Hour)
		// ... call Aggregate...RawTo1h
	}

	// 1 Day interval boundary
	if now.Hour() == 0 && now.Minute() == 0 {
		// start1d := now.Add(-24 * time.Hour).Truncate(time.Hour)
		// ... call Aggregate...RawTo1d
	}
	
	logger.Server.Debug("Successfully aggregated metrics", zap.Time("at", now), zap.String("module", "workers"))
}
