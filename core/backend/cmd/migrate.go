package cmd

import (
	"fmt"
	"os"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"re-backend/pkg/logger"
)

var migrateCmd = &cobra.Command{
	Use:   "migrate",
	Short: "Run database migrations",
	Long:  `Manage database schema versions using up and down migrations.`,
}

var migrateUpCmd = &cobra.Command{
	Use:   "up",
	Short: "Apply all up migrations",
	Run: func(cmd *cobra.Command, args []string) {
		runMigration("up")
	},
}

var migrateDownCmd = &cobra.Command{
	Use:   "down",
	Short: "Rollback all migrations",
	Run: func(cmd *cobra.Command, args []string) {
		runMigration("down")
	},
}

func init() {
	rootCmd.AddCommand(migrateCmd)
	migrateCmd.AddCommand(migrateUpCmd)
	migrateCmd.AddCommand(migrateDownCmd)
}

func runMigration(direction string) {
	if cfg == nil {
		fmt.Println("Error: configuration not loaded")
		os.Exit(1)
	}

	migrationsPath := "file://pkg/db/migrations"
	
	m, err := migrate.New(migrationsPath, cfg.Database.GetURL())
	if err != nil {
		logger.Server.Fatal("Could not create migrate instance", zap.Error(err))
		return
	}

	var migErr error
	if direction == "up" {
		logger.Server.Info("Running migrations up...")
		migErr = m.Up()
	} else if direction == "down" {
		logger.Server.Info("Running migrations down...")
		migErr = m.Down()
	}

	if migErr != nil && migErr != migrate.ErrNoChange {
		logger.Server.Fatal("Migration failed", zap.Error(migErr))
		return
	}

	if migErr == migrate.ErrNoChange {
		logger.Server.Info("No migrations to apply")
	} else {
		logger.Server.Info("Migrations applied successfully")
	}
}
