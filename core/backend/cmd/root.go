package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"re-backend/config"
	"re-backend/pkg/logger"
)

var (
	cfgFile string
	cfg     *config.Config
)

var rootCmd = &cobra.Command{
	Use:   "re-backend",
	Short: "Project Re Backend Service",
	Long:  `A robust backend service for Project Re, handling Auth and Monitoring.`,
}

const defaultConfigFile = "config/config.toml"

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	rootCmd.PersistentFlags().StringVarP(&cfgFile, "config", "c", "", "config file (default is ./config.toml)")
}

func initConfig() {
	var err error
	cfg, err = config.Load(cfgFile)
	if err != nil {
		fmt.Printf("Warning: error loading config: %v\n", err)
	}

	// Initialize Logger
	logger.Init(cfg)
}
