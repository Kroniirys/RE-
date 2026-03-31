package app

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
	"re-backend/config"
	"re-backend/internal/auth"
	"re-backend/internal/handler"
	"re-backend/internal/middleware"
	db "re-backend/pkg/db/repository"
	"re-backend/pkg/logger"
)

// App structure holds all dependencies and configuration for the application.
type App struct {
	Config     *config.Config
	DB         *pgxpool.Pool
	Queries    *db.Queries
	TokenMaker *auth.TokenMaker
	Router     *gin.Engine
}

// NewApp initializes the application components and returns an App instance.
func NewApp(cfg *config.Config, pool *pgxpool.Pool) *App {
	if cfg.Server.Mode == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()
	router.Use(gin.Recovery())
	router.Use(middleware.RequestID())
	router.Use(middleware.CORS())
	router.Use(middleware.ZapLogger(cfg.Logger.APILogEnabled))

	tokenMaker := auth.NewTokenMaker(cfg.Auth.JWTSecret, cfg.Auth.AccessTokenExpiry, cfg.Auth.RefreshTokenExpiry)
	queries := db.New(pool)

	app := &App{
		Config:     cfg,
		DB:         pool,
		Queries:    queries,
		TokenMaker: tokenMaker,
		Router:     router,
	}

	app.registerRoutes()
	return app
}

func (a *App) registerRoutes() {
	// Auth Handlers
	authHandler := handler.NewAuthHandler(a.Config, a.Queries, a.TokenMaker)

	v1 := a.Router.Group("/api/v1")
	{
		authRoutes := v1.Group("/auth")
		{
			authRoutes.POST("/register", authHandler.Register)
			authRoutes.POST("/login", authHandler.Login)
			authRoutes.POST("/refresh", authHandler.Refresh)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware(a.TokenMaker))
		{
			protected.GET("/health", func(c *gin.Context) {
				payload, _ := c.Get("authorization_payload")
				c.JSON(http.StatusOK, gin.H{
					"status": "up",
					"mode":   a.Config.Server.Mode,
					"user":   payload,
				})
			})
		}
	}
}

// Run starts the HTTP server with graceful shutdown handling.
func (a *App) Run() error {
	addr := fmt.Sprintf(":%d", a.Config.Server.Port)
	srv := &http.Server{
		Addr:    addr,
		Handler: a.Router,
	}

	// Initializing the server in a goroutine so that
	// it won't block the graceful shutdown handling below
	go func() {
		logger.Server.Info(fmt.Sprintf("Server starting on %s in %s mode", addr, a.Config.Server.Mode))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Server.Fatal(fmt.Sprintf("listen: %s\n", err))
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server with
	// a timeout of 5 seconds.
	quit := make(chan os.Signal, 1)
	// kill (no param) default send syscall.SIGTERM
	// kill -2 is syscall.SIGINT
	// kill -9 is syscall.SIGKILL but can't be caught, so no need to add it
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Server.Info("Shutting down server...")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Server.Fatal("Server forced to shutdown:", zap.Error(err))
	}

	// Close DB pool
	logger.Server.Info("Closing database connection pool...")
	a.DB.Close()

	logger.Server.Info("Server exiting")
	return nil
}
