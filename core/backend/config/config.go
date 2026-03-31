package config

import (
	"bytes"
	_ "embed"
	"fmt"
	"strings"
	"time"

	"github.com/spf13/viper"
)

//go:embed config_origin.toml
var defaultConfigFile []byte

type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Auth     AuthConfig     `mapstructure:"auth"`
	Logger   LoggerConfig   `mapstructure:"logger"`
}

type ServerConfig struct {
	Port int    `mapstructure:"port"`
	Mode string `mapstructure:"mode"`
}

type DatabaseConfig struct {
	URL             string        `mapstructure:"url"`
	MaxOpenConns    int           `mapstructure:"max_open_conns"`
	MaxIdleConns    int           `mapstructure:"max_idle_conns"`
	ConnMaxLifetime time.Duration `mapstructure:"conn_max_lifetime"`
}

type AuthConfig struct {
	JWTSecret          string        `mapstructure:"jwt_secret"`
	AccessTokenExpiry  time.Duration `mapstructure:"access_token_expiry"`
	RefreshTokenExpiry time.Duration `mapstructure:"refresh_token_expiry"`
	BcryptCost         int           `mapstructure:"bcrypt_cost"`
}

type LoggerConfig struct {
	ServerLevel       string `mapstructure:"server_level"`
	ServerLogEnabled  int    `mapstructure:"server_log_enabled"`
	APILevel          string `mapstructure:"api_level"`
	APILogEnabled     int    `mapstructure:"api_log_enabled"`
	BackupLevel       string `mapstructure:"backup_level"`
	BackupLogEnabled  int    `mapstructure:"backup_log_enabled"`
	DBLevel           string `mapstructure:"db_level"`
	DBLogEnabled      int    `mapstructure:"db_log_enabled"`
	MaxSize           int    `mapstructure:"max_size"`
	MaxBackups        int    `mapstructure:"max_backups"`
	MaxAge            int    `mapstructure:"max_age"`
	Compress          bool   `mapstructure:"compress"`
}

// Load reads configuration from file or defaults to embedded config.
func Load(cfgFile string) (*Config, error) {
	v := viper.New()

	v.SetConfigType("toml")

	if cfgFile != "" {
		v.SetConfigFile(cfgFile)
	} else {
		v.SetConfigName("config")
		v.AddConfigPath("./config")
		v.AddConfigPath(".")
	}

	v.AutomaticEnv()
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// Try reading from external file
	if err := v.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// File not found, fall back to embedded config
			fmt.Println("Warning: External config file not found. Falling back to embedded defaults.")
			if err := v.ReadConfig(bytes.NewBuffer(defaultConfigFile)); err != nil {
				return nil, fmt.Errorf("error reading embedded config: %w", err)
			}
		} else {
			// Other reading error
			return nil, fmt.Errorf("error reading config file: %w", err)
		}
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("unable to decode into struct: %w", err)
	}

	return &cfg, nil
}
