package client

import (
	"context"
	"fmt"
	"time"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"

	"re-backend/config"
	"re-backend/pkg/logger"
	"re-backend/scraper/collector"
	agentv1 "re-backend/scraper/proto/v1"
)

type ScraperClient struct {
	conn       *grpc.ClientConn
	agent      agentv1.AgentServiceClient
	collector  *collector.DockerCollector
	cfg        *config.Config
	token      string
	cancelFunc context.CancelFunc
}

func NewScraperClient(cfg *config.Config, token string) (*ScraperClient, error) {
	addr := fmt.Sprintf("localhost:%d", cfg.Server.GrpcPort)
	// Using NewClient as Dial is deprecated
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	dc, err := collector.NewDockerCollector()
	if err != nil {
		logger.Server.Warn("Failed to initialize Docker collector (is Docker running?)", zap.Error(err))
	} else {
		logger.Server.Info("Docker collector initialized successfully")
	}

	return &ScraperClient{
		conn:      conn,
		agent:     agentv1.NewAgentServiceClient(conn),
		collector: dc,
		cfg:       cfg,
		token:     token,
	}, nil
}

func (s *ScraperClient) Start(ctx context.Context) {
	logger.Server.Info("Starting Internal Scraper Client loop", zap.Int("interval_s", s.cfg.Scraper.IntervalSecond))

	ctx, cancel := context.WithCancel(ctx)
	s.cancelFunc = cancel

	// Add auth token to context
	md := metadata.Pairs("authorization", "Bearer "+s.token)
	ctx = metadata.NewOutgoingContext(ctx, md)

	// Keep trying to connect stream
	for {
		select {
		case <-ctx.Done():
			logger.Server.Info("Scraper loop returning on context cancellation")
			return
		default:
			s.runStream(ctx)
			// Wait before reconnect
			time.Sleep(2 * time.Second)
		}
	}
}

func (s *ScraperClient) runStream(ctx context.Context) {
	stream, err := s.agent.StreamMetrics(ctx)
	if err != nil {
		logger.Server.Debug("Scraper failed to connect to gRPC Stream", zap.Error(err))
		return
	}
	logger.Server.Info("Scraper connected to gRPC Stream successfully")

	interval := time.Duration(s.cfg.Scraper.IntervalSecond) * time.Second
	if interval < 1*time.Second {
		interval = 5 * time.Second // default fallback
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			stream.CloseSend()
			return
		case t := <-ticker.C:
			payload := &agentv1.MetricPayload{
				AssetId:   "internal-server-agent",
				Timestamp: t.Unix(),
			}

			if s.collector != nil {
				dockerMetrics, err := s.collector.GetMetrics(ctx)
				if err != nil {
					logger.Server.Warn("Scraper failed to get docker metrics", zap.Error(err))
				} else {
					payload.Docker = dockerMetrics
				}
			}

			if err := stream.Send(payload); err != nil {
				logger.Server.Error("Scraper failed to send stream payload", zap.Error(err))
				return // Break and reconnect
			}
		}
	}
}

func (s *ScraperClient) Stop() {
	if s.cancelFunc != nil {
		s.cancelFunc()
	}
	if s.conn != nil {
		s.conn.Close()
	}
}
