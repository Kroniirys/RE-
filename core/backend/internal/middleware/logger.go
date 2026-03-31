package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"re-backend/pkg/logger"
)

// ZapLogger returns a middleware that logs HTTP requests using the Zap API logger.
func ZapLogger(enabled int) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		if enabled == 1 {
			latency := time.Since(start)
			status := c.Writer.Status()
			requestID, _ := c.Get("RequestID")

			logger.API.Info("API Request",
				zap.Int("status", status),
				zap.String("method", c.Request.Method),
				zap.String("path", path),
				zap.String("query", query),
				zap.String("ip", c.ClientIP()),
				zap.String("user-agent", c.Request.UserAgent()),
				zap.Duration("latency", latency),
				zap.Any("request_id", requestID),
			)
		}
	}
}
