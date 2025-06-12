# Azure Container Apps Microservices Deployment

This Terraform configuration deploys a microservices architecture on Azure Container Apps, including:
- Frontend (Next.js with SSR)
- Backend API (ASP.NET Core 8.0)
- SQLite Database (default) or SQL Server (optional)
- Redis Cache
- Application Insights

## Quick Start

```bash
# 1. Clone and navigate to this directory
cd terraform-azure-container-apps

# 2. Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# 3. Edit terraform.tfvars if needed (optional)

# 4. Deploy infrastructure
terraform init
terraform apply -auto-approve

# 5. Build and deploy applications with correct URLs
./scripts/build-and-deploy.sh  # or .ps1 for Windows
```

## Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.3.0
- Docker (for local testing)
- Azure subscription

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Configure Variables (Optional)

Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

By default, the deployment uses SQLite which requires no configuration. If you want to use SQL Server instead:

```hcl
use_sql_server = true
sql_admin_password = "YourSecurePassword123!"
```

### 3. Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### 4. Build and Deploy Applications

After the infrastructure is created, run the build script to deploy the applications with the correct configuration:

**On Linux/macOS:**
```bash
./scripts/build-and-deploy.sh
```

**On Windows:**
```powershell
.\scripts\build-and-deploy.ps1
```

This script will:
- Get the deployed backend URL from Terraform outputs
- Build the backend API container
- Build the frontend container with the correct API URL
- Update both container apps with the new images

## Why Two-Step Deployment?

The frontend needs to know the backend URL at build time (for Next.js SSR), but the backend URL is only known after deployment. The build script solves this chicken-and-egg problem by:
1. First deploying the infrastructure with placeholder images
2. Then rebuilding and redeploying with the correct URLs

## CORS Configuration

The backend automatically configures CORS to allow requests from:
- The deployed frontend URL (dynamically determined)
- `http://localhost:3000` (for local development)

## Accessing the Applications

After deployment, you can access:
- Frontend: `https://ecommerce-frontend.<environment-domain>`
- Backend API: `https://ecommerce-backend.<environment-domain>`
- Swagger UI: `https://ecommerce-backend.<environment-domain>/swagger/index.html`

The exact URLs will be displayed after running the build script.

## Database Configuration

By default, the application uses **SQLite** which:
- Requires no additional configuration
- Creates the database file automatically on first run
- Stores data in `/app/data/ecommerce.db` inside the container
- Has zero additional cost

For production scenarios, you can enable SQL Server by setting `use_sql_server = true` in your `terraform.tfvars`.

## Local Development

For local development, the applications are configured to work with:
- Frontend: http://localhost:3000
- Backend: http://localhost:5050

## Troubleshooting

1. **Frontend can't connect to backend**: Run the build-and-deploy script to ensure the frontend is built with the correct backend URL.

2. **CORS errors**: The backend reads allowed origins from environment variables. Check that the `CORS__AllowedOrigins__0` environment variable is set correctly.

3. **Database connection issues**: Ensure the SQL Server firewall rules allow connections from Azure services.

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Cost Estimation

Estimated monthly cost:
- **With SQLite (default)**: ~$25/month
  - Container Apps: ~$10-15
  - Application Insights: ~$5
  - Other resources: ~$5-10
  
- **With SQL Server**: ~$30/month
  - Adds ~$5 for SQL Server Basic tier