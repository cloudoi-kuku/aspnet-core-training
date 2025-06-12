# E-Commerce Platform Deployment Guide - SQL Server Edition

This guide covers the deployment of the E-Commerce platform using SQL Server instead of SQLite, with Redis for caching and RabbitMQ for messaging.

## Overview of Changes

### 🔄 Database Migration: SQLite → SQL Server

The platform has been updated to use SQL Server instead of SQLite for better scalability and production readiness:

1. **Backend Configuration**:
   - Updated `appsettings.json` to use SQL Server connection string
   - Program.cs already has logic to detect and use SQL Server automatically
   - Health checks updated to use SQL Server

2. **Helm Charts**:
   - Added SQL Server deployment, service, and persistent volume claim
   - Updated backend deployment to connect to SQL Server
   - Configured proper init containers to wait for SQL Server

3. **Port Standardization**:
   - Backend now uses port 5050 (matching FinalProject)
   - Frontend connects to backend on port 5050
   - Monitoring and health checks updated accordingly

## 📋 Prerequisites

- Docker Desktop running
- kubectl configured for your Kubernetes cluster
- Helm 3.x installed
- Access to a Kubernetes cluster (Kind, AKS, etc.)

## 🚀 Quick Deployment

### Step 1: Build Docker Images

```bash
# Navigate to terraform directory
cd Module13-Building-Microservices/terraform

# For macOS/Linux - Build and push to ACR
chmod +x build-images.sh
./build-images.sh -r ecommerceacrrv2i.azurecr.io -t latest

# For Windows PowerShell
# .\build-images.ps1 -Registry ecommerceacrrv2i.azurecr.io -Tag latest
```

### Step 2: Deploy to Kubernetes

For local Kind cluster:
```bash
# Deploy using default values (includes SQL Server)
helm upgrade --install ecommerce-app ./helm-charts/ecommerce-app --namespace ecommerce --create-namespace
```

For Azure AKS:
```bash
# Deploy using Azure-optimized values (macOS/Linux)
helm upgrade --install ecommerce-app ./helm-charts/ecommerce-app \
  --namespace ecommerce \
  --create-namespace \
  --values ./helm-charts/azure-values.yaml

# Or use the PowerShell script (Windows)
# pwsh ./deploy-with-helm.ps1
```

## 🗄️ Database Configuration

### SQL Server Setup

The platform now uses Microsoft SQL Server 2022 Express:

- **Image**: `mcr.microsoft.com/mssql/server:2022-latest`
- **Port**: 1433
- **Database**: ECommerceDB
- **Authentication**: SQL Server Authentication
- **Username**: sa
- **Password**: YourStrong@Passw0rd (configurable in values.yaml)

### Connection String

```
Server=sqlserver;Database=ECommerceDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;MultipleActiveResultSets=true
```

### Persistent Storage

- **Storage Class**: managed-premium (Azure) or default (local)
- **Size**: 5Gi (default) / 10Gi (Azure)
- **Access Mode**: ReadWriteOnce

## 🔧 Configuration Files

### Key Files Updated

1. **Backend Configuration**:
   - `src/backend/ECommerce.API/appsettings.json` - SQL Server connection string
   - `src/backend/ECommerce.API/Program.cs` - Already supports SQL Server detection

2. **Helm Charts**:
   - `helm-charts/ecommerce-app/values.yaml` - Default configuration
   - `helm-charts/azure-values.yaml` - Azure-optimized configuration
   - `helm-charts/ecommerce-app/templates/sqlserver-*.yaml` - New SQL Server resources

3. **Build Scripts**:
   - `build-images.ps1` - Updated for port 5050
   - `deploy-with-helm.ps1` - Deployment automation

## 🌐 Service Endpoints

After deployment, the following services will be available:

### Local Development (Kind)
- **Frontend**: http://localhost:3000 (port-forward)
- **Backend API**: http://localhost:5050 (port-forward)
- **SQL Server**: localhost:1433 (port-forward)
- **Redis**: localhost:6379 (port-forward)

### Azure AKS
- **Frontend**: https://ecommerce.azure.local
- **Backend API**: https://api.ecommerce.azure.local
- **Grafana**: https://grafana.ecommerce.azure.local

## 🔍 Verification Commands

```powershell
# Check all pods are running
kubectl get pods -n ecommerce

# Check SQL Server is ready
kubectl logs -n ecommerce deployment/ecommerce-app-sqlserver

# Check backend can connect to SQL Server
kubectl logs -n ecommerce deployment/ecommerce-app-backend

# Port forward to access services locally
kubectl port-forward -n ecommerce svc/ecommerce-app-frontend 3000:3000
kubectl port-forward -n ecommerce svc/ecommerce-app-backend 5050:5050
kubectl port-forward -n ecommerce svc/ecommerce-app-sqlserver 1433:1433
```

## 🐛 Troubleshooting

### SQL Server Issues

1. **Pod not starting**:
   ```powershell
   kubectl describe pod -n ecommerce -l app.kubernetes.io/component=sqlserver
   ```

2. **Connection issues**:
   ```powershell
   kubectl exec -n ecommerce deployment/ecommerce-app-backend -- ping ecommerce-app-sqlserver
   ```

3. **Database initialization**:
   ```powershell
   kubectl logs -n ecommerce deployment/ecommerce-app-backend | grep -i migration
   ```

### Backend Issues

1. **Check environment variables**:
   ```powershell
   kubectl exec -n ecommerce deployment/ecommerce-app-backend -- env | grep ConnectionStrings
   ```

2. **Health check status**:
   ```powershell
   kubectl get pods -n ecommerce -l app.kubernetes.io/component=backend
   ```

## 📊 Monitoring

The platform includes comprehensive monitoring:

- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **Health Checks**: SQL Server, Redis, and application health
- **Logging**: Structured logging with Serilog

Access Grafana:
```powershell
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3001:80
# Username: admin, Password: admin123
```

## 🔐 Security Considerations

1. **Change default passwords** in production
2. **Use Azure Key Vault** or Kubernetes secrets for sensitive data
3. **Enable TLS** for all communications
4. **Configure network policies** for pod-to-pod communication
5. **Use managed identities** in Azure

## 📝 Next Steps

1. **Database Migrations**: The application will automatically create the database schema
2. **Data Seeding**: Sample data is seeded automatically on first run
3. **Scaling**: Use HPA for automatic scaling based on CPU/memory
4. **Backup**: Configure SQL Server backup strategy
5. **Monitoring**: Set up alerts in Grafana for critical metrics

## 🆘 Support

For issues or questions:
1. Check pod logs: `kubectl logs -n ecommerce <pod-name>`
2. Verify configurations in values.yaml files
3. Ensure all prerequisites are met
4. Check network connectivity between services
