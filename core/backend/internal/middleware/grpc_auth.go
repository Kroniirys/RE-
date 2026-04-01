package middleware

import (
	"context"
	"strings"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"

	"re-backend/internal/auth"
	"re-backend/pkg/logger"
)

// GrpcAuthInterceptor returns a Unary Server Interceptor for JWT authentication
func GrpcAuthInterceptor(tokenMaker *auth.TokenMaker) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		// Example: bypass Register and Health routes
		if strings.Contains(info.FullMethod, "Register") {
			return handler(ctx, req)
		}

		err := authorizeGrpcRequest(ctx, tokenMaker)
		if err != nil {
			logger.Server.Warn("gRPC Authorization Failed", zap.String("method", info.FullMethod), zap.Error(err))
			return nil, err
		}

		return handler(ctx, req)
	}
}

// GrpcAuthStreamInterceptor returns a Stream Server Interceptor for JWT authentication
func GrpcAuthStreamInterceptor(tokenMaker *auth.TokenMaker) grpc.StreamServerInterceptor {
	return func(
		srv interface{},
		stream grpc.ServerStream,
		info *grpc.StreamServerInfo,
		handler grpc.StreamHandler,
	) error {
		err := authorizeGrpcRequest(stream.Context(), tokenMaker)
		if err != nil {
			logger.Server.Warn("gRPC Stream Authorization Failed", zap.String("method", info.FullMethod), zap.Error(err))
			return err
		}

		return handler(srv, stream)
	}
}

func authorizeGrpcRequest(ctx context.Context, tokenMaker *auth.TokenMaker) error {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return status.Errorf(codes.Unauthenticated, "metadata is not provided")
	}

	values := md["authorization"]
	if len(values) == 0 {
		return status.Errorf(codes.Unauthenticated, "authorization token is not provided")
	}

	authHeader := values[0]
	fields := strings.Fields(authHeader)
	if len(fields) < 2 || strings.ToLower(fields[0]) != "bearer" {
		return status.Errorf(codes.Unauthenticated, "invalid authorization header format")
	}

	accessToken := fields[1]
	payload, err := tokenMaker.VerifyToken(accessToken)
	if err != nil {
		return status.Errorf(codes.Unauthenticated, "access token is invalid: %v", err)
	}

	// For Agents, you might verify role here if needed:
	// if payload.Role != "agent" { ... }
	
	_ = payload // Suppress unused var error since Payload exists for context injection if needed.

	return nil
}
