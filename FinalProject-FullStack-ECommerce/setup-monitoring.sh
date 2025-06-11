#!/bin/bash

# E-Commerce Platform Monitoring Setup Script
# This script sets up Prometheus and Grafana monitoring for the e-commerce platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 Setting up Monitoring Stack for E-Commerce Platform${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if Kind cluster exists
if ! kind get clusters | grep -q "ecommerce"; then
    echo -e "${RED}❌ Kind cluster 'ecommerce' not found. Please create the cluster first.${NC}"
    echo -e "${YELLOW}Run: kind create cluster --config kind-cluster-config.yaml --name ecommerce${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kind cluster 'ecommerce' found${NC}"

# Set kubectl context
kubectl config use-context kind-ecommerce

# Create monitoring namespace
echo -e "${BLUE}📦 Creating monitoring namespace...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
echo -e "${BLUE}📦 Adding Helm repositories...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Prometheus Stack (includes Prometheus, Grafana, AlertManager, Node Exporter)
echo -e "${BLUE}🔍 Installing Prometheus Stack...${NC}"
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.retention=15d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName="" \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]="ReadWriteOnce" \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
  --set grafana.adminPassword=admin123 \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.size=1Gi \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.ingressClassName=nginx \
  --set grafana.ingress.hosts[0]=grafana.ecommerce.local \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName="" \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.accessModes[0]="ReadWriteOnce" \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=2Gi \
  --wait \
  --timeout=10m

# Wait for Prometheus Stack to be ready
echo -e "${YELLOW}⏳ Waiting for Prometheus Stack to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Install Redis Exporter for Redis monitoring
echo -e "${BLUE}📊 Installing Redis Exporter...${NC}"
helm upgrade --install redis-exporter prometheus-community/prometheus-redis-exporter \
  --namespace ecommerce \
  --set redisAddress=redis://ecommerce-app-redis-master:6379 \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.namespace=monitoring \
  --wait

# Install RabbitMQ Exporter for RabbitMQ monitoring
echo -e "${BLUE}📊 Installing RabbitMQ Exporter...${NC}"
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rabbitmq-exporter
  namespace: ecommerce
  labels:
    app: rabbitmq-exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rabbitmq-exporter
  template:
    metadata:
      labels:
        app: rabbitmq-exporter
    spec:
      containers:
      - name: rabbitmq-exporter
        image: kbudde/rabbitmq-exporter:latest
        ports:
        - containerPort: 9419
          name: metrics
        env:
        - name: RABBIT_URL
          value: "http://ecommerce-app-rabbitmq:15672"
        - name: RABBIT_USER
          value: "admin"
        - name: RABBIT_PASSWORD
          value: "admin123"
        - name: PUBLISH_PORT
          value: "9419"
        - name: LOG_LEVEL
          value: "info"
---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq-exporter
  namespace: ecommerce
  labels:
    app: rabbitmq-exporter
spec:
  ports:
  - port: 9419
    targetPort: 9419
    name: metrics
  selector:
    app: rabbitmq-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: rabbitmq-exporter
  namespace: monitoring
  labels:
    app: rabbitmq-exporter
spec:
  selector:
    matchLabels:
      app: rabbitmq-exporter
  namespaceSelector:
    matchNames:
    - ecommerce
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF

# Create custom Grafana dashboards
echo -e "${BLUE}📊 Creating custom Grafana dashboards...${NC}"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-dashboards
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  ecommerce-overview.json: |
    {
      "dashboard": {
        "id": null,
        "title": "E-Commerce Platform Overview",
        "tags": ["ecommerce"],
        "style": "dark",
        "timezone": "browser",
        "panels": [
          {
            "id": 1,
            "title": "Service Health",
            "type": "stat",
            "targets": [
              {
                "expr": "up{job=~\"ecommerce.*\"}",
                "legendFormat": "{{job}}"
              }
            ],
            "gridPos": {"h": 8, "w": 24, "x": 0, "y": 0}
          },
          {
            "id": 2,
            "title": "HTTP Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])",
                "legendFormat": "{{job}} - {{method}} {{status}}"
              }
            ],
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
          },
          {
            "id": 3,
            "title": "Response Time (95th percentile)",
            "type": "graph",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
                "legendFormat": "{{job}}"
              }
            ],
            "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
          }
        ],
        "time": {"from": "now-1h", "to": "now"},
        "refresh": "30s"
      }
    }
EOF

# Add hosts entries for local access
echo -e "${BLUE}🌐 Setting up local access...${NC}"
if ! grep -q "grafana.ecommerce.local" /etc/hosts; then
    echo "127.0.0.1 grafana.ecommerce.local" | sudo tee -a /etc/hosts
    echo -e "${GREEN}✅ Added grafana.ecommerce.local to /etc/hosts${NC}"
fi

# Display access information
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Monitoring Stack Setup Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📊 Access Information:${NC}"
echo ""
echo -e "${BLUE}Grafana Dashboard:${NC}"
echo -e "  URL: http://grafana.ecommerce.local"
echo -e "  Username: admin"
echo -e "  Password: admin123"
echo ""
echo -e "${BLUE}Prometheus:${NC}"
echo -e "  Port Forward: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090"
echo -e "  URL: http://localhost:9090"
echo ""
echo -e "${BLUE}AlertManager:${NC}"
echo -e "  Port Forward: kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093"
echo -e "  URL: http://localhost:9093"
echo ""
echo -e "${YELLOW}🔧 Useful Commands:${NC}"
echo -e "  Check monitoring pods: ${CYAN}kubectl get pods -n monitoring${NC}"
echo -e "  View Grafana logs: ${CYAN}kubectl logs -n monitoring -l app.kubernetes.io/name=grafana${NC}"
echo -e "  View Prometheus logs: ${CYAN}kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus${NC}"
echo -e "  Port forward Grafana: ${CYAN}kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80${NC}"
echo ""
echo -e "${GREEN}✅ Monitoring is now ready! Visit Grafana to view your dashboards.${NC}"
