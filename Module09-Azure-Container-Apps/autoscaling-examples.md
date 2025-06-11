# Azure Container Apps Auto-Scaling Configuration Guide

## 🎯 Overview

Azure Container Apps provides powerful auto-scaling capabilities that can automatically adjust the number of running replicas based on various metrics and triggers.

## 📊 Scaling Triggers

### 1. HTTP Scaling (Most Common)
Scales based on the number of concurrent HTTP requests per replica.

```bash
# Basic HTTP scaling
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 1 \
  --max-replicas 10 \
  --scale-rule-name "http-scale" \
  --scale-rule-type "http" \
  --scale-rule-http-concurrency 15
```

### 2. CPU-Based Scaling
Scales based on CPU utilization percentage.

```bash
# CPU scaling at 70% utilization
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 2 \
  --max-replicas 15 \
  --scale-rule-name "cpu-scale" \
  --scale-rule-type "cpu" \
  --scale-rule-metadata "type=Utilization" "value=70"
```

### 3. Memory-Based Scaling
Scales based on memory utilization percentage.

```bash
# Memory scaling at 80% utilization
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 1 \
  --max-replicas 8 \
  --scale-rule-name "memory-scale" \
  --scale-rule-type "memory" \
  --scale-rule-metadata "type=Utilization" "value=80"
```

## 🔧 Advanced Scaling Configurations

### Multiple Scaling Rules (YAML)

```yaml
# advanced-scaling.yaml
properties:
  template:
    scale:
      minReplicas: 2
      maxReplicas: 20
      rules:
        - name: http-requests
          http:
            metadata:
              concurrentRequests: "10"
        - name: cpu-utilization
          custom:
            type: cpu
            metadata:
              type: Utilization
              value: "75"
        - name: memory-utilization
          custom:
            type: memory
            metadata:
              type: Utilization
              value: "85"
```

Apply with:
```bash
az containerapp update --name myapp --resource-group myRG --yaml advanced-scaling.yaml
```

### Event-Driven Scaling (Azure Service Bus)

```bash
# Scale based on Service Bus queue length
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --scale-rule-name "servicebus-scale" \
  --scale-rule-type "azure-servicebus" \
  --scale-rule-metadata \
    "queueName=myqueue" \
    "namespace=myservicebus" \
    "messageCount=5"
```

### Custom Metrics Scaling

```bash
# Scale based on custom Azure Monitor metrics
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --scale-rule-name "custom-metric" \
  --scale-rule-type "azure-monitor" \
  --scale-rule-metadata \
    "metricName=CustomRequestCount" \
    "targetValue=100" \
    "resourceURI=/subscriptions/.../resourceGroups/.../providers/..."
```

## 📈 Scaling Behaviors

### Scale-to-Zero Configuration
```bash
# Enable scale-to-zero (cost-effective for dev/test)
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 0 \
  --max-replicas 10
```

### Aggressive Scaling
```bash
# Fast scaling for high-traffic applications
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 5 \
  --max-replicas 50 \
  --scale-rule-http-concurrency 5  # Scale up quickly
```

### Conservative Scaling
```bash
# Slower scaling for stable workloads
az containerapp update \
  --name myapp \
  --resource-group myRG \
  --min-replicas 3 \
  --max-replicas 12 \
  --scale-rule-http-concurrency 25  # Scale up slowly
```

## 🎛️ Scaling Parameters

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| `minReplicas` | Minimum number of replicas | 0 | 0-1000 |
| `maxReplicas` | Maximum number of replicas | 10 | 1-1000 |
| `concurrentRequests` | HTTP requests per replica | 10 | 1-1000 |
| `cpu.value` | CPU utilization threshold | 80 | 1-100 |
| `memory.value` | Memory utilization threshold | 80 | 1-100 |

## 🔍 Monitoring Auto-Scaling

### View Current Replicas
```bash
az containerapp replica list \
  --name myapp \
  --resource-group myRG \
  --output table
```

### View Scaling Events
```bash
az containerapp logs show \
  --name myapp \
  --resource-group myRG \
  --type system \
  --follow
```

### Monitor Metrics
```bash
# View CPU metrics
az monitor metrics list \
  --resource "/subscriptions/.../resourceGroups/myRG/providers/Microsoft.App/containerApps/myapp" \
  --metric "CpuPercentage" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z
```

## 🚀 Best Practices

### 1. Start Conservative
- Begin with higher `concurrentRequests` values (15-25)
- Use moderate min/max replica ranges
- Monitor and adjust based on actual usage

### 2. Consider Your Workload
- **Web APIs**: Use HTTP scaling
- **Background Processing**: Use queue-based scaling
- **CPU-Intensive**: Use CPU scaling
- **Memory-Intensive**: Use memory scaling

### 3. Cost Optimization
- Use `minReplicas: 0` for dev/test environments
- Set appropriate `maxReplicas` to control costs
- Monitor scaling patterns and adjust thresholds

### 4. Performance Optimization
- Lower `concurrentRequests` for faster scaling
- Use multiple scaling rules for complex workloads
- Set higher `minReplicas` for consistent performance

## 🛠️ Troubleshooting

### Common Issues

1. **Slow Scaling Response**
   - Lower the `concurrentRequests` threshold
   - Check if CPU/memory limits are too low

2. **Excessive Scaling**
   - Increase the `concurrentRequests` threshold
   - Review application performance bottlenecks

3. **Scale-to-Zero Not Working**
   - Ensure `minReplicas: 0`
   - Check for persistent connections or background tasks

### Debugging Commands
```bash
# Check current configuration
az containerapp show --name myapp --resource-group myRG --query "properties.template.scale"

# View recent scaling events
az containerapp logs show --name myapp --resource-group myRG --type system --tail 100

# Monitor real-time metrics
az containerapp logs show --name myapp --resource-group myRG --follow
```

## 📚 Additional Resources

- [Azure Container Apps Scaling Documentation](https://docs.microsoft.com/en-us/azure/container-apps/scale-app)
- [KEDA Scalers Reference](https://keda.sh/docs/scalers/)
- [Azure Monitor Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported)
