# 🚀 E-Commerce Platform Deployment Guide

This guide walks you through building and deploying the full-stack e-commerce platform to a Kind Kubernetes cluster using Helm charts.

## 📋 Prerequisites

### Required Tools
```bash
# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install .NET 8 SDK
# Download from: https://dotnet.microsoft.com/download/dotnet/8.0

# Install Node.js 18+
# Download from: https://nodejs.org/
```

### Verify Installation
```bash
docker --version
kind --version
kubectl version --client
helm version
dotnet --version
node --version
npm --version
```

## 🏗️ Step 1: Build the Frontend

### Navigate to Frontend Directory
```bash
cd src/frontend
```

### Install Dependencies
```bash
npm install
```

### Build the Application
```bash
npm run build
```

### Build Docker Image
```bash
docker build -t ecommerce-frontend:latest .
```

### Verify Frontend Image
```bash
docker images | grep ecommerce-frontend
```

## 🔧 Step 2: Build the Backend

### Navigate to Backend Directory
```bash
cd ../backend
```

### Restore Dependencies
```bash
dotnet restore ECommerce.API/ECommerce.API.csproj
```

### Build the Application
```bash
dotnet build ECommerce.API/ECommerce.API.csproj -c Release
```

### Publish the Application
```bash
dotnet publish ECommerce.API/ECommerce.API.csproj -c Release -o ECommerce.API/out
```

### Build Docker Image
```bash
docker build -t ecommerce-backend:latest -f ECommerce.API/Dockerfile .
```

### Verify Backend Image
```bash
docker images | grep ecommerce-backend
```

## ☸️ Step 3: Create Kind Cluster

### Create Cluster with Custom Configuration
```bash
cd ../../  # Back to project root
kind create cluster --config kind-cluster-config.yaml --name ecommerce
```

### Verify Cluster
```bash
kubectl cluster-info --context kind-ecommerce
kubectl get nodes
```

### Load Images into Kind
```bash
# Load frontend image
kind load docker-image ecommerce-frontend:latest --name ecommerce

# Load backend image  
kind load docker-image ecommerce-backend:latest --name ecommerce

# Verify images are loaded
docker exec -it ecommerce-control-plane crictl images | grep ecommerce
```

## 📦 Step 4: Install NGINX Ingress Controller

### Install NGINX Ingress
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### Wait for Ingress Controller
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## 🎯 Step 5: Deploy with Helm

### Add Helm Repositories
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Create Namespace
```bash
kubectl create namespace ecommerce
```

### Deploy the Application
```bash
helm install ecommerce-app ./helm-charts/ecommerce-app \
  --namespace ecommerce \
  --wait \
  --timeout=10m
```

### Check Deployment Status
```bash
# Check all resources
kubectl get all -n ecommerce

# Check pods
kubectl get pods -n ecommerce

# Check services
kubectl get svc -n ecommerce

# Check ingress
kubectl get ingress -n ecommerce
```

## 📊 Step 6: Setup Monitoring (Prometheus & Grafana)

### Automated Setup
```bash
# Make setup script executable
chmod +x setup-monitoring.sh

# Run monitoring setup
./setup-monitoring.sh
```

### Manual Setup (Alternative)
```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus Stack
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.hosts[0]=grafana.ecommerce.local \
  --wait

# Install Redis Exporter
helm install redis-exporter prometheus-community/prometheus-redis-exporter \
  --namespace ecommerce \
  --set redisAddress=redis://ecommerce-app-redis-master:6379 \
  --set serviceMonitor.enabled=true
```

### Verify Monitoring Setup
```bash
# Check monitoring pods
kubectl get pods -n monitoring

# Check if Prometheus is scraping targets
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090 &
# Visit: http://localhost:9090/targets

# Check Grafana
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80 &
# Visit: http://localhost:3001 (admin/admin123)
```

## 🌐 Step 7: Access the Application

### Port Forward Services (Option 1)
```bash
# Frontend
kubectl port-forward -n ecommerce svc/ecommerce-app-frontend 3000:3000 &

# Backend API
kubectl port-forward -n ecommerce svc/ecommerce-app-backend 5050:5050 &

# Access applications:
# Frontend: http://localhost:3000
# Backend API: http://localhost:5050/swagger
```

### Use Ingress (Option 2)
```bash
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
echo "127.0.0.1 ecommerce.local api.ecommerce.local" | sudo tee -a /etc/hosts

# Access applications:
# Frontend: http://ecommerce.local
# Backend API: http://api.ecommerce.local/swagger
# Grafana: http://grafana.ecommerce.local (admin/admin123)
```

### Access Monitoring Dashboards
```bash
# Grafana (if using ingress)
open http://grafana.ecommerce.local
# Username: admin, Password: admin123

# Prometheus (port forward)
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090:9090 &
open http://localhost:9090

# AlertManager (port forward)
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-alertmanager 9093:9093 &
open http://localhost:9093
```

## 🔍 Step 8: Verify Deployment

### Check Application Health
```bash
# Frontend health
curl http://localhost:3000/api/health

# Backend health
curl http://localhost:5050/health
```

### Check Database
```bash
# Get backend pod name
BACKEND_POD=$(kubectl get pods -n ecommerce -l app.kubernetes.io/component=backend -o jsonpath='{.items[0].metadata.name}')

# Check database file
kubectl exec -n ecommerce $BACKEND_POD -- ls -la /app/data/
```

### Check Redis
```bash
# Get Redis pod name
REDIS_POD=$(kubectl get pods -n ecommerce -l app.kubernetes.io/name=redis -o jsonpath='{.items[0].metadata.name}')

# Test Redis connection
kubectl exec -n ecommerce $REDIS_POD -- redis-cli ping
```

### Check RabbitMQ
```bash
# Port forward RabbitMQ management UI
kubectl port-forward -n ecommerce svc/ecommerce-app-rabbitmq 15672:15672 &

# Access RabbitMQ Management: http://localhost:15672
# Username: admin, Password: admin123
```

## 📊 Step 9: Monitor the Application

### View Logs
```bash
# Frontend logs
kubectl logs -n ecommerce -l app.kubernetes.io/component=frontend -f

# Backend logs
kubectl logs -n ecommerce -l app.kubernetes.io/component=backend -f

# Redis logs
kubectl logs -n ecommerce -l app.kubernetes.io/name=redis -f
```

### Check Resource Usage
```bash
# Pod resource usage
kubectl top pods -n ecommerce

# Node resource usage
kubectl top nodes
```

## 🧪 Step 10: Test the Application

### Test API Endpoints
```bash
# Get products
curl http://localhost:5050/api/products

# Health check
curl http://localhost:5050/health

# Swagger UI
open http://localhost:5050/swagger
```

### Test Frontend
```bash
# Open in browser
open http://localhost:3000

# Test SSR
curl -I http://localhost:3000
```

### Test Monitoring
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check if metrics are being collected
curl http://localhost:5050/metrics

# Test Grafana API
curl -u admin:admin123 http://localhost:3001/api/health

# View application metrics in Grafana
open http://grafana.ecommerce.local
```

## 🔧 Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod -n ecommerce <pod-name>

# Check events
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

#### Image Pull Errors
```bash
# Reload images into Kind
kind load docker-image ecommerce-frontend:latest --name ecommerce
kind load docker-image ecommerce-backend:latest --name ecommerce
```

#### Service Connection Issues
```bash
# Check service endpoints
kubectl get endpoints -n ecommerce

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm -- /bin/sh
# Inside pod: nc -zv ecommerce-app-backend 5050
```

#### Database Issues
```bash
# Check persistent volume
kubectl get pv,pvc -n ecommerce

# Check database logs
kubectl logs -n ecommerce -l app.kubernetes.io/component=backend | grep -i database
```

### Useful Commands
```bash
# Restart deployment
kubectl rollout restart deployment/ecommerce-app-backend -n ecommerce

# Scale deployment
kubectl scale deployment/ecommerce-app-frontend --replicas=3 -n ecommerce

# Update Helm release
helm upgrade ecommerce-app ./helm-charts/ecommerce-app -n ecommerce

# Uninstall application
helm uninstall ecommerce-app -n ecommerce

# Delete cluster
kind delete cluster --name ecommerce
```

## 🎉 Success!

If everything is working correctly, you should have:

✅ **Frontend**: Next.js SSR app running on port 3000
✅ **Backend**: .NET 8 API running on port 5050
✅ **Database**: SQLite with persistent storage
✅ **Cache**: Redis for performance
✅ **Queue**: RabbitMQ for background tasks
✅ **Monitoring**: Prometheus metrics collection
✅ **Dashboards**: Grafana with custom dashboards
✅ **Alerting**: AlertManager for notifications
✅ **Observability**: Full application and infrastructure monitoring
✅ **Security**: JWT authentication and HTTPS

### 📊 **Monitoring Stack Includes:**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notifications
- **Node Exporter**: System metrics
- **Redis Exporter**: Redis performance metrics
- **RabbitMQ Exporter**: Message queue metrics
- **Custom Dashboards**: Application-specific monitoring

### 🔗 **Access URLs:**
- **Application**: http://ecommerce.local
- **API Documentation**: http://api.ecommerce.local/swagger
- **Grafana**: http://grafana.ecommerce.local (admin/admin123)
- **Prometheus**: http://localhost:9090 (port-forward)
- **AlertManager**: http://localhost:9093 (port-forward)

Your production-ready, fully-monitored e-commerce platform is now running on Kubernetes! 🚀
