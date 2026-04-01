package handler

import (
	"context"

	"go.uber.org/zap"

	"re-backend/pkg/logger"
	agentv1 "re-backend/scraper/proto/v1"
)

type GrpcAgentHandler struct {
	agentv1.UnimplementedAgentServiceServer
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
	for {
		payload, err := stream.Recv()
		if err != nil {
			logger.Server.Info("StreamMetrics connection closed or error", zap.Error(err))
			return err
		}

		logger.Server.Debug("Received Metric Payload", zap.String("asset_id", payload.AssetId), zap.Int64("timestamp", payload.Timestamp))
		
		// Batch insert logic using SQLC copyfrom will go here
	}
}
