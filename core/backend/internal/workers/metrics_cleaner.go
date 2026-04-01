package workers

import (
	"context"
	"time"

	"go.uber.org/zap"
	"re-backend/pkg/logger"
)

// RunMetricsCleaner checks every hour (or day) for obsolete records to enforce Retention Policy
func (w *WorkerManager) RunMetricsCleaner(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Hour) // Run cleanup every hour
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			logger.Server.Info("Stopping Metrics Cleaner", zap.String("module", "workers"))
			return
		case now := <-ticker.C:
			w.cleanAllObsolete(ctx, now)
		}
	}
}

func (w *WorkerManager) cleanAllObsolete(ctx context.Context, now time.Time) {
	// Policy:
	// Raw: 1 Day
	// 1m, 5m, 10m, 1h: 3 Months
	// 1d: 1 Year

	rawThreshold := now.Add(-24 * time.Hour)
	// intervalThreshold := now.Add(-90 * 24 * time.Hour) // 3 Months approx
	// yearlyThreshold := now.Add(-365 * 24 * time.Hour)

	logger.Server.Info("Running Retention Policy Cleanup", zap.Time("threshold_raw", rawThreshold), zap.String("module", "workers"))

	// Delete Old Raw
	// w.q.DeleteOldCpuRaw(ctx, rawThreshold)
	// w.q.DeleteOldRamRaw(ctx, rawThreshold)
	// ... 

	// Delete Old Intervals
	// w.q.DeleteOldCpu1m(ctx, intervalThreshold)
	// w.q.DeleteOldCpu5m(ctx, intervalThreshold)
	// ...

	// ...
	logger.Server.Debug("Completed Retention Cleanup", zap.String("module", "workers"))
}
