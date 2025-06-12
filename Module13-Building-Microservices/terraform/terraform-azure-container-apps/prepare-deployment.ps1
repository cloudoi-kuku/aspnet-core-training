# Module 13: Prepare Terraform Deployment
# This script helps students prepare their Terraform deployment

Write-Host "🚀 Module 13: Terraform Deployment Preparation" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Blue

# Check Azure CLI
if (Get-Command az -ErrorAction SilentlyContinue) {
    Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
    $azAccount = az account show --query name -o tsv 2>$null
    if ($azAccount) {
        Write-Host "✅ Logged in to Azure account: $azAccount" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Not logged in to Azure. Run: az login" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Azure CLI is not installed" -ForegroundColor Red
    Write-Host "   Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
}

# Check Terraform
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $tfVersion = terraform version -json | ConvertFrom-Json
    Write-Host "✅ Terraform is installed (version: $($tfVersion.terraform_version))" -ForegroundColor Green
} else {
    Write-Host "❌ Terraform is not installed" -ForegroundColor Red
    Write-Host "   Please install from: https://www.terraform.io/downloads" -ForegroundColor Yellow
}

# Check Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    if (docker info 2>$null) {
        Write-Host "✅ Docker is installed and running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Docker is installed but not running" -ForegroundColor Yellow
        Write-Host "   Please start Docker Desktop" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Docker is not installed" -ForegroundColor Red
    Write-Host "   Please install from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📝 Setting up your terraform.tfvars file..." -ForegroundColor Blue
Write-Host ""

# Check if terraform.tfvars already exists
if (Test-Path "terraform.tfvars") {
    Write-Host "⚠️  terraform.tfvars already exists" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to create a new one? (y/N)"
    if ($overwrite -ne 'y') {
        Write-Host "Keeping existing terraform.tfvars" -ForegroundColor Gray
        exit 0
    }
}

# Inform about automatic resource naming
Write-Host "🏷️  Automatic Resource Naming" -ForegroundColor Blue
Write-Host "Resources will be automatically named with a unique 8-character identifier." -ForegroundColor Gray
Write-Host "This ensures each student deployment is completely isolated." -ForegroundColor Gray
Write-Host "Example: rg-microservices-abc12xyz" -ForegroundColor Gray
Write-Host ""

# Generate SQL password
$sqlPassword = "P@ssw0rd$(Get-Random -Minimum 1000 -Maximum 9999)!"
Write-Host ""
Write-Host "🔐 Generated SQL password: $sqlPassword" -ForegroundColor Yellow
Write-Host "   (You can change this in terraform.tfvars)" -ForegroundColor Gray

# Get organization tags
Write-Host ""
Write-Host "🏢 Organization Tags (press Enter to use defaults)" -ForegroundColor Blue
$ownerName = Read-Host "Your name [default: DevOps Team]"
if ([string]::IsNullOrWhiteSpace($ownerName)) { $ownerName = "DevOps Team" }

$contactEmail = Read-Host "Your email [default: training@company.com]"
if ([string]::IsNullOrWhiteSpace($contactEmail)) { $contactEmail = "training@company.com" }

$costCenter = Read-Host "Cost center [default: IT-Training]"
if ([string]::IsNullOrWhiteSpace($costCenter)) { $costCenter = "IT-Training" }

# Create terraform.tfvars
$tfvarsContent = @"
# Module 13: Terraform Variables
# Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# Each deployment will receive a unique 8-character identifier automatically

# Azure Region
location = "westus"

# SQL Server Configuration
sql_admin_username = "sqladmin"
sql_admin_password = "$sqlPassword"

# Common Tags (Required by organization policy)
common_tags = {
  ManagedBy             = "Terraform"
  Environment           = "Training"
  Project              = "Microservices"
  Module               = "Module13"
  "enablon:client"      = "Enablon Internal"
  "enablon:cost_center" = "$costCenter"
  "enablon:owner"       = "$ownerName"
  "enablon:contact"     = "$contactEmail"
}

# Container Configuration
container_cpu    = 0.5
container_memory = "1.0Gi"

# Scaling Configuration
min_replicas = 1
max_replicas = 3

# Additional Tags
tags = {
  Purpose       = "Training"
  Course        = "ASP.NET Core Microservices"
  DeploymentDate = "$(Get-Date -Format "yyyy-MM-dd")"
}

# Feature Flags
enable_monitoring        = true
enable_auto_scaling      = true
enable_service_discovery = true
"@

$tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
Write-Host ""
Write-Host "✅ Created terraform.tfvars" -ForegroundColor Green

# Display next steps
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Blue
Write-Host ""
Write-Host "1. Review terraform.tfvars and make any needed changes" -ForegroundColor White
Write-Host "2. Initialize Terraform:" -ForegroundColor White
Write-Host "   terraform init" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Review the deployment plan:" -ForegroundColor White
Write-Host "   terraform plan" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Deploy the infrastructure:" -ForegroundColor White
Write-Host "   terraform apply" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Blue
Write-Host "  • Resources will be created with a unique random suffix" -ForegroundColor Gray
Write-Host "  • Resource group will be: rg-microservices-{unique-id}" -ForegroundColor Gray
Write-Host "  • Estimated cost: ~`$30/month (minimal usage)" -ForegroundColor Gray
Write-Host "  • To destroy all resources: terraform destroy" -ForegroundColor Gray
Write-Host "  • Save the unique ID from terraform output for reference" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Ready to deploy!" -ForegroundColor Green