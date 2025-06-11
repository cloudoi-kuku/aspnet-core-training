# 📊 E-Commerce Platform Monitoring Guide

## 🎯 Overview

This guide covers the comprehensive monitoring setup for the e-commerce platform using Prometheus and Grafana. The monitoring stack provides full observability into application performance, infrastructure health, and business metrics.

## 🏗️ Monitoring Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │────│   Prometheus    │────│     Grafana     │
│    Metrics      │    │   (Collection)  │    │ (Visualization) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │  AlertManager   │              │
         └──────────────│  (Alerting)     │──────────────┘
                        └─────────────────┘
```

## 📈 Metrics Collection

### Application Metrics (.NET 8 API)
- **HTTP Metrics**: Request rate, response time, error rate
- **Custom Metrics**: Business logic metrics (orders, products, users)
- **Health Checks**: Database, Redis, RabbitMQ connectivity
- **Performance**: Memory usage, CPU utilization, GC metrics

### Infrastructure Metrics
- **Kubernetes**: Pod status, resource usage, cluster health
- **Redis**: Operations/sec, memory usage, connections
- **RabbitMQ**: Queue depth, message rate, consumer status
- **Node Metrics**: CPU, memory, disk, network usage

### Frontend Metrics (Next.js)
- **Performance**: Page load times, bundle sizes
- **User Experience**: Core Web Vitals
- **API Calls**: Success rate, response times

## 🎛️ Grafana Dashboards

### 1. Application Overview Dashboard
**Panels:**
- Service health status
- HTTP request rate and response times
- Error rates by endpoint
- Database connection pool status
- Cache hit/miss ratios

### 2. Infrastructure Dashboard
**Panels:**
- Kubernetes cluster overview
- Pod resource utilization
- Node performance metrics
- Storage usage and I/O

### 3. Business Metrics Dashboard
**Panels:**
- Order processing metrics
- Product view statistics
- User registration trends
- Revenue tracking (if implemented)

### 4. Redis Performance Dashboard
**Panels:**
- Operations per second
- Memory usage and evictions
- Connection statistics
- Slow queries

### 5. RabbitMQ Dashboard
**Panels:**
- Queue depths and message rates
- Consumer performance
- Connection status
- Exchange statistics

## 🚨 Alerting Rules

### Critical Alerts
```yaml
# High error rate
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"

# Service down
- alert: ServiceDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Service is down"

# High memory usage
- alert: HighMemoryUsage
  expr: process_working_set_bytes / 1024 / 1024 > 500
  for: 10m
  labels:
    severity: warning
  annotations:
    summary: "High memory usage"
```

### Warning Alerts
```yaml
# High response time
- alert: HighResponseTime
  expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High response time"

# Redis connection issues
- alert: RedisConnectionIssues
  expr: redis_connected_clients < 1
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "Redis connection issues"
```

## 🔧 Setup Instructions

### Quick Setup
```bash
# Run the automated setup script
chmod +x setup-monitoring.sh
./setup-monitoring.sh
```

### Manual Setup Steps

#### 1. Install Prometheus Stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123
```

#### 2. Configure ServiceMonitors
```bash
kubectl apply -f helm-charts/ecommerce-app/templates/servicemonitor.yaml
```

#### 3. Import Dashboards
```bash
kubectl apply -f helm-charts/ecommerce-app/templates/grafana-dashboard-configmap.yaml
```

## 📊 Key Metrics to Monitor

### Application Performance
| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `http_requests_total` | Total HTTP requests | - |
| `http_request_duration_seconds` | Request duration | 95th percentile > 1s |
| `http_requests_total{status=~"5.."}` | Server errors | Rate > 0.1/sec |
| `dotnet_collection_count_total` | .NET GC collections | - |

### Infrastructure Health
| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `up` | Service availability | == 0 |
| `node_memory_MemAvailable_bytes` | Available memory | < 10% |
| `node_cpu_seconds_total` | CPU usage | > 80% |
| `node_filesystem_avail_bytes` | Disk space | < 10% |

### Business Metrics
| Metric | Description | Purpose |
|--------|-------------|---------|
| `ecommerce_orders_total` | Total orders | Business tracking |
| `ecommerce_products_viewed` | Product views | User engagement |
| `ecommerce_cart_abandonment` | Cart abandonment rate | Conversion optimization |

## 🎯 Accessing Monitoring

### Grafana
```bash
# Via Ingress (recommended)
http://grafana.ecommerce.local
Username: admin
Password: admin123

# Via Port Forward
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80
http://localhost:3001
```

### Prometheus
```bash
# Port Forward
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
http://localhost:9090
```

### AlertManager
```bash
# Port Forward
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093
http://localhost:9093
```

## 🔍 Troubleshooting

### Common Issues

#### Metrics Not Appearing
```bash
# Check if Prometheus is scraping targets
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090
# Visit: http://localhost:9090/targets

# Check ServiceMonitor configuration
kubectl get servicemonitor -n monitoring

# Verify application is exposing metrics
curl http://localhost:5000/metrics
```

#### Grafana Dashboard Issues
```bash
# Check if dashboards are loaded
kubectl get configmap -n monitoring | grep dashboard

# Restart Grafana
kubectl rollout restart deployment/prometheus-stack-grafana -n monitoring

# Check Grafana logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
```

#### Alert Not Firing
```bash
# Check AlertManager configuration
kubectl get secret -n monitoring prometheus-stack-kube-prom-alertmanager -o yaml

# View AlertManager logs
kubectl logs -n monitoring -l app.kubernetes.io/name=alertmanager
```

### Useful Commands
```bash
# Check all monitoring resources
kubectl get all -n monitoring

# View Prometheus configuration
kubectl get prometheus -n monitoring -o yaml

# Check ServiceMonitor status
kubectl describe servicemonitor -n monitoring

# View metrics from command line
kubectl exec -n monitoring prometheus-stack-kube-prom-prometheus-0 -- \
  promtool query instant 'up'
```

## 📚 Best Practices

### 1. Metric Naming
- Use consistent naming conventions
- Include units in metric names
- Use labels for dimensions

### 2. Dashboard Design
- Group related metrics together
- Use appropriate visualization types
- Include context and documentation

### 3. Alerting Strategy
- Alert on symptoms, not causes
- Use appropriate severity levels
- Include actionable information

### 4. Performance Optimization
- Set appropriate retention periods
- Use recording rules for complex queries
- Monitor monitoring system resource usage

## 🔗 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/monitoring/)
- [.NET Metrics](https://docs.microsoft.com/en-us/dotnet/core/diagnostics/metrics)

---

**Your e-commerce platform now has enterprise-grade monitoring! 📊🚀**
