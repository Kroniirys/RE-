# Use official Golang image as a build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum (if it exists)
COPY go.mod ./
# RUN go mod download

# Copy the rest of the code
COPY . .

# Build the application
RUN go build -o main ./cmd/api/main.go

# Final stage: minimal image
FROM alpine:latest

WORKDIR /root/

# Copy the binary from the builder stage
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
