package collector

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
	agentv1 "re-backend/scraper/proto/v1"
)

type DockerCollector struct {
	cli *client.Client
}

func NewDockerCollector() (*DockerCollector, error) {
	// FromEnv parses DOCKER_HOST, DOCKER_TLS_VERIFY, DOCKER_CERT_PATH
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return nil, err
	}
	return &DockerCollector{cli: cli}, nil
}

// CPUStats and MemoryStats structs locally to parse JSON unmarshaled from ContainerStats body.
type simpleStats struct {
	Read    string `json:"read"`
	PreRead string `json:"preread"`
	CPUStats struct {
		CPUUsage struct {
			TotalUsage uint64 `json:"total_usage"`
		} `json:"cpu_usage"`
		SystemUsage uint64 `json:"system_cpu_usage"`
		OnlineCPUs  uint32 `json:"online_cpus"`
	} `json:"cpu_stats"`
	PreCPUStats struct {
		CPUUsage struct {
			TotalUsage uint64 `json:"total_usage"`
		} `json:"cpu_usage"`
		SystemUsage uint64 `json:"system_cpu_usage"`
	} `json:"precpu_stats"`
	MemoryStats struct {
		Usage uint64 `json:"usage"`
	} `json:"memory_stats"`
}

func (c *DockerCollector) GetMetrics(ctx context.Context) ([]*agentv1.DockerMetric, error) {
	containers, err := c.cli.ContainerList(ctx, container.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("list containers: %w", err)
	}

	var metrics []*agentv1.DockerMetric

	for _, ctr := range containers {
		stats, err := c.cli.ContainerStats(ctx, ctr.ID, false)
		if err != nil {
			continue // skip error
		}

		var v simpleStats
		dec := json.NewDecoder(stats.Body)
		if err := dec.Decode(&v); err != nil {
			stats.Body.Close()
			continue
		}
		stats.Body.Close()

		cpuUsage := calculateCPUPercentUnix(&v)
		memUsage := v.MemoryStats.Usage

		name := ctr.ID
		if len(ctr.Names) > 0 {
			name = strings.TrimPrefix(ctr.Names[0], "/")
		}

		metrics = append(metrics, &agentv1.DockerMetric{
			DockerHashId:    ctr.ID,
			Name:            name,
			Image:           ctr.Image,
			State:           ctr.State,
			CpuUsagePercent: float32(cpuUsage),
			RamUsedBytes:    int64(memUsage),
		})
	}

	return metrics, nil
}

func calculateCPUPercentUnix(v *simpleStats) float64 {
	var (
		cpuPercent  = 0.0
		cpuDelta    = float64(v.CPUStats.CPUUsage.TotalUsage) - float64(v.PreCPUStats.CPUUsage.TotalUsage)
		systemDelta = float64(v.CPUStats.SystemUsage) - float64(v.PreCPUStats.SystemUsage)
		onlineCPUs  = float64(v.CPUStats.OnlineCPUs)
	)

	if onlineCPUs == 0.0 {
		onlineCPUs = 1.0 // fallback
	}

	if systemDelta > 0.0 && cpuDelta > 0.0 {
		cpuPercent = (cpuDelta / systemDelta) * onlineCPUs * 100.0
	}
	return cpuPercent
}
