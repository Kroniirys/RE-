package handler

import (
	"context"
	"encoding/json"
	"os"
	"sync"

	"go.uber.org/zap"

	"re-backend/pkg/logger"
	agentv1 "re-backend/scraper/proto/v1"
)

type GrpcAgentHandler struct {
	agentv1.UnimplementedAgentServiceServer
	mu sync.Mutex // Mutex for debug file writing
}

func NewGrpcAgentHandler() *GrpcAgentHandler {
	return &GrpcAgentHandler{}
}

func (h *GrpcAgentHandler) Register(ctx context.Context, req *agentv1.RegisterRequest) (*agentv1.RegisterResponse, error) {
	logger.Server.Info("Agent Register called via gRPC", zap.String("hostname", req.Hostname))
	
	// Create Asset in DB here

	return &agentv1.RegisterResponse{
		AssetId: "test-asset-id",
		Status:  "success",
	}, nil
}

func (h *GrpcAgentHandler) Heartbeat(ctx context.Context, req *agentv1.HeartbeatRequest) (*agentv1.HeartbeatResponse, error) {
	logger.Server.Debug("Agent Heartbeat", zap.String("asset_id", req.AssetId))
	
	// Update Asset status in DB here

	return &agentv1.HeartbeatResponse{
		Acknowledged: true,
	}, nil
}

func (h *GrpcAgentHandler) StreamMetrics(stream agentv1.AgentService_StreamMetricsServer) error {
	logger.Server.Info("StreamMetrics connection established")

	// Open or create debug file
	f, err := os.OpenFile("scraped_data_debug.jsonl", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		logger.Server.Error("Failed to open debug log file", zap.Error(err))
	} else {
		defer f.Close()
	}

	for {
		payload, err := stream.Recv()
		if err != nil {
			logger.Server.Info("StreamMetrics connection closed or error", zap.Error(err))
			return err
		}

		logger.Server.Debug("Received Metric Payload", zap.String("asset_id", payload.AssetId), zap.Int64("timestamp", payload.Timestamp))

		// Temporary debug logging to file
		if f != nil {
			h.mu.Lock()
			data, _ := json.Marshal(payload)
			f.Write(append(data, '\n'))
			h.mu.Unlock()
		}

		// Batch insert logic using SQLC copyfrom will go here
	}
}
