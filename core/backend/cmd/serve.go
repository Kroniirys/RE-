package cmd

import (
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"re-backend/internal/app"
	"re-backend/pkg/db"
	"re-backend/pkg/logger"
)

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Start the API and gRPC server",
	Run: func(cmd *cobra.Command, args []string) {
		startServer()
	},
}

func init() {
	rootCmd.AddCommand(serveCmd)
}

func startServer() {
	// Initialize Database Pool
	pool, err := db.InitPool(cfg)
	if err != nil {
		logger.Server.Fatal("Failed to initialize database pool", zap.Error(err))
	}

	// Create and Run App
	application := app.NewApp(cfg, pool)
	if err := application.Run(); err != nil {
		logger.Server.Fatal("Application failed to run", zap.Error(err))
	}
}
