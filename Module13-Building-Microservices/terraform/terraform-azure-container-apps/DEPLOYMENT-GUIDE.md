# Complete Deployment Guide: From PowerShell to Terraform

This guide provides step-by-step instructions for deploying Module 13 microservices using Terraform instead of PowerShell scripts.

## Table of Contents
1. [Prerequisites Check](#prerequisites-check)
2. [Initial Setup](#initial-setup)
3. [Configuration](#configuration)
4. [Deployment](#deployment)
5. [Validation](#validation)
6. [Troubleshooting](#troubleshooting)
7. [Cleanup](#cleanup)

## Prerequisites Check

### Required Tools
```bash
# Check Azure CLI
az --version

# Check Terraform
terraform --version

# Check Docker
docker --version

# Check .NET SDK
dotnet --version
```

### Azure Login
```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name"

# Verify current subscription
az account show
```

## Initial Setup

### 1. Navigate to Terraform Directory
```bash
cd Module13-Building-Microservices/terraform/terraform-azure-container-apps
```

### 2. Initialize Terraform
```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

## Configuration

### 1. Create Variables File
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars
```hcl
# REQUIRED: Your unique student ID
student_id = "student123"

# REQUIRED: Organization tags
cost_center = "IT-Training"
owner       = "John Doe"
contact     = "john.doe@company.com"

# REQUIRED: SQL Server password (make it secure!)
sql_admin_password = "SecureP@ssw0rd2024!"

# Optional: Change region if needed
location = "westus"

# Optional: Adjust resources
container_cpu    = 0.5
container_memory = "1.0Gi"
min_replicas     = 1
max_replicas     = 3
```

### 3. Validate Configuration
```bash
terraform validate
```

## Deployment

### 1. Plan Deployment
```bash
terraform plan -out=tfplan
```

Review the plan carefully. You should see:
- 15-20 resources to be created
- No resources to be destroyed (on first run)

### 2. Apply Deployment
```bash
terraform apply tfplan
```

Or for interactive apply:
```bash
terraform apply
```

### 3. Monitor Progress
The deployment will take approximately 10-15 minutes:
- Resource Group: ~30 seconds
- Container Registry: ~2 minutes
- SQL Server: ~3 minutes
- Container Apps Environment: ~3 minutes
- Building Docker images: ~3-5 minutes
- Container Apps: ~2 minutes

## Validation

### 1. Check Outputs
```bash
terraform output
```

### 2. Get Service URLs
```bash
# Backend API URL
terraform output backend_url

# Frontend URL
terraform output frontend_url
```

### 3. Test Services
```bash
# Test Backend API health
curl $(terraform output -raw backend_url)/api/health

# Test Frontend health
curl $(terraform output -raw frontend_url)/api/health

# Access Frontend in browser
echo "Frontend URL: $(terraform output -raw frontend_url)"

# Access API documentation
echo "API Docs: $(terraform output -raw backend_url)/swagger"
```

### 4. Verify in Azure Portal
1. Navigate to [Azure Portal](https://portal.azure.com)
2. Find resource group: `rg-microservices-{your-student-id}`
3. Check all resources are created and healthy

## Troubleshooting

### Common Issues and Solutions

#### 1. Docker Build Fails
```bash
# Ensure Docker is running
docker ps

# Manually test build
cd ../src/backend/ProductService
docker build -t test .
```

#### 2. Authentication Issues
```bash
# Re-login to Azure
az login

# Check ACR credentials
az acr credential show --name $(terraform output -raw acr_name)
```

#### 3. Container App Deployment Fails
```bash
# Check Container Apps Environment
az containerapp env show \
  --name $(terraform output -raw container_apps_environment_name) \
  --resource-group $(terraform output -raw resource_group_name)

# Check backend logs
az containerapp logs show \
  --name ecommerce-backend \
  --resource-group $(terraform output -raw resource_group_name)

# Check frontend logs
az containerapp logs show \
  --name ecommerce-frontend \
  --resource-group $(terraform output -raw resource_group_name)
```

#### 4. SQL Connection Issues
```bash
# Test SQL connectivity
az sql db show \
  --name ProductDb \
  --server $(terraform output -raw sql_server_name) \
  --resource-group $(terraform output -raw resource_group_name)
```

### Debugging Commands

Enable detailed Terraform logging:
```bash
export TF_LOG=DEBUG
terraform apply
```

Check Terraform state:
```bash
terraform state list
terraform state show azurerm_container_app.product_service
```

## Updating Configuration

### 1. Modify Variables
Edit `terraform.tfvars` with new values

### 2. Plan Changes
```bash
terraform plan
```

### 3. Apply Changes
```bash
terraform apply
```

### Common Updates

#### Scale Container Apps
```hcl
# In terraform.tfvars
min_replicas = 2
max_replicas = 5
```

#### Update Container Resources
```hcl
# In terraform.tfvars
container_cpu    = 1.0
container_memory = "2.0Gi"
```

## Cleanup

### Complete Cleanup
```bash
# This will destroy ALL resources
terraform destroy
```

### Selective Cleanup
```bash
# Remove specific resources
terraform destroy -target=azurerm_container_app.product_service
```

### Backup State Before Cleanup
```bash
cp terraform.tfstate terraform.tfstate.backup
```

## Migration from PowerShell

If you have an existing PowerShell deployment:

### 1. Run Migration Helper
```powershell
.\migrate-to-terraform.ps1 -GenerateTfvars
```

### 2. Import Existing Resources (Optional)
```bash
# Example: Import existing resource group
terraform import azurerm_resource_group.main \
  /subscriptions/{sub-id}/resourceGroups/rg-microservices-{student-id}
```

## Cost Management

### View Estimated Costs
```bash
terraform output estimated_monthly_cost
```

### Cost Optimization Tips
1. Use `min_replicas = 0` for dev/test
2. Schedule scaling for business hours
3. Use Basic tier for SQL in non-production
4. Monitor with cost alerts

## Next Steps

1. **Add CI/CD Pipeline**
   - GitHub Actions
   - Azure DevOps
   - GitLab CI

2. **Enhance Security**
   - Enable managed identities
   - Use Key Vault for secrets
   - Implement network policies

3. **Add Monitoring**
   - Configure alerts
   - Create dashboards
   - Set up log analytics

4. **Implement GitOps**
   - Use Flux or ArgoCD
   - Automate deployments
   - Version control everything

## Support Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Container Apps Docs](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Module 13 Original Scripts](../setup-module13.ps1)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

---

**Remember**: Always run `terraform plan` before `terraform apply` to review changes!