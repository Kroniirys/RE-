# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Copy go.mod and go.sum
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and config templates
COPY . .

# Build the application
RUN go build -o main .

# Final stage
FROM alpine:latest

WORKDIR /root/

# Install runtime dependencies (like ca-certificates for networking)
RUN apk add --no-cache ca-certificates

# Copy the binary from the builder stage
COPY --from=builder /app/main .

# Copy necessary directories for runtime
COPY --from=builder /app/config ./config
COPY --from=builder /app/pkg/db/migrations ./pkg/db/migrations

# Expose the API port
EXPOSE 8080

# Run the server
CMD ["./main", "serve"]
