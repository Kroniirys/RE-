package logger

import (
	"os"
	"path/filepath"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
	"re-backend/config"
)

var (
	Server *zap.Logger
	API    *zap.Logger
	Backup *zap.Logger
	DB     *zap.Logger
)

func Init(cfg *config.Config) {
	Server = createLogger("server", cfg.Logger.ServerLevel, cfg.Logger.ServerLogEnabled, cfg)
	API = createLogger("api", cfg.Logger.APILevel, cfg.Logger.APILogEnabled, cfg)
	Backup = createLogger("backup", cfg.Logger.BackupLevel, cfg.Logger.BackupLogEnabled, cfg)
	DB = createLogger("database", cfg.Logger.DBLevel, cfg.Logger.DBLogEnabled, cfg)

	zap.ReplaceGlobals(Server)
}

func createLogger(name string, levelStr string, enabled int, cfg *config.Config) *zap.Logger {
	level := getLevel(levelStr)

	// Encoder config - Text format as requested
	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
	encoder := zapcore.NewConsoleEncoder(encoderConfig)

	var cores []zapcore.Core

	// Console output (always on for now, or we could add a toggle)
	cores = append(cores, zapcore.NewCore(encoder, zapcore.AddSync(os.Stdout), level))

	// File output if enabled (1)
	if enabled == 1 {
		logPath := filepath.Join("log", name+".log")
		
		w := zapcore.AddSync(&lumberjack.Logger{
			Filename:   logPath,
			MaxSize:    cfg.Logger.MaxSize,
			MaxBackups: cfg.Logger.MaxBackups,
			MaxAge:     cfg.Logger.MaxAge,
			Compress:   cfg.Logger.Compress,
		})
		
		cores = append(cores, zapcore.NewCore(encoder, w, level))
	}

	core := zapcore.NewTee(cores...)
	return zap.New(core, zap.AddCaller())
}

func getLevel(levelStr string) zapcore.Level {
	switch levelStr {
	case "debug":
		return zap.DebugLevel
	case "info":
		return zap.InfoLevel
	case "warn":
		return zap.WarnLevel
	case "error":
		return zap.ErrorLevel
	default:
		return zap.InfoLevel
	}
}
