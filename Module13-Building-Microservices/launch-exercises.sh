#!/bin/bash

# Module 13: Building Microservices - Interactive Exercise Launcher
# This script provides guided, hands-on exercises for microservices architecture and implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="AzureECommerce"
INTERACTIVE_MODE=true
SKIP_PROJECT_CREATION=false

# Function to display colored output
echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

# Function to pause for user interaction
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "Press Enter to continue..."
        read -r
        echo ""
    fi
}

# Function to explain concepts interactively
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🏗️ MICROSERVICES CONCEPT: $concept${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$explanation${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    pause_for_user
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${BLUE}🎯 Microservices Learning Objectives for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}Azure Setup and Microservices Overview:${NC}"
            echo "  ☁️  1. Set up Azure Resource Group and services"
            echo "  ☁️  2. Create Azure Container Registry"
            echo "  ☁️  3. Understand Azure Container Apps architecture"
            echo "  ☁️  4. Plan cloud-native microservices deployment"
            echo ""
            echo -e "${YELLOW}Azure concepts:${NC}"
            echo "  • Azure Container Apps fundamentals"
            echo "  • Managed services overview"
            echo "  • Cost optimization strategies"
            echo "  • Cloud-native design principles"
            ;;
        "exercise02")
            echo -e "${CYAN}Building Azure-Ready Services:${NC}"
            echo "  ☁️  1. Create cloud-native ASP.NET Core services"
            echo "  ☁️  2. Configure for Azure SQL Database"
            echo "  ☁️  3. Integrate Application Insights"
            echo "  ☁️  4. Prepare for container deployment"
            echo ""
            echo -e "${YELLOW}Azure integration concepts:${NC}"
            echo "  • Azure SQL Database configuration"
            echo "  • Application Insights telemetry"
            echo "  • Environment-based configuration"
            echo "  • Container-ready applications"
            ;;
        "exercise03")
            echo -e "${CYAN}Deploy to Azure Container Apps:${NC}"
            echo "  ☁️  1. Build and push images to Azure Container Registry"
            echo "  ☁️  2. Deploy services to Container Apps"
            echo "  ☁️  3. Configure environment variables and secrets"
            echo "  ☁️  4. Set up Application Insights monitoring"
            echo ""
            echo -e "${YELLOW}Deployment concepts:${NC}"
            echo "  • Container Apps deployment"
            echo "  • Environment configuration"
            echo "  • Service discovery in Container Apps"
            echo "  • Azure monitoring setup"
            ;;
        "exercise04")
            echo -e "${CYAN}Azure Service Communication:${NC}"
            echo "  ☁️  1. Implement Azure Service Bus messaging"
            echo "  ☁️  2. Configure service-to-service communication"
            echo "  ☁️  3. Add resilience with Polly"
            echo "  ☁️  4. Handle failures gracefully"
            echo ""
            echo -e "${YELLOW}Communication concepts:${NC}"
            echo "  • Azure Service Bus integration"
            echo "  • Resilient HTTP communication"
            echo "  • Circuit breaker patterns"
            echo "  • Message-based architecture"
            ;;
        "exercise05")
            echo -e "${CYAN}Production Features:${NC}"
            echo "  ☁️  1. Configure auto-scaling rules"
            echo "  ☁️  2. Set up Azure Front Door"
            echo "  ☁️  3. Implement comprehensive health checks"
            echo "  ☁️  4. Review costs and optimize"
            echo ""
            echo -e "${YELLOW}Production concepts:${NC}"
            echo "  • Container Apps scaling strategies"
            echo "  • Global load balancing"
            echo "  • Cost optimization techniques"
            echo "  • Production monitoring"
            ;;
    esac
    echo ""
}

# Function to show what will be created
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}📋 Microservices Components for $exercise:${NC}"
    
    case $exercise in
        "exercise01")
            echo "• Azure resource setup script"
            echo "• Cost estimation documentation"
            echo "• Azure CLI configuration"
            echo "• Resource group and services setup"
            echo "• Container Registry creation"
            ;;
        "exercise02")
            echo "• Product Service (Azure-ready)"
            echo "• Order Service (Azure-ready)"
            echo "• Dockerfile configurations"
            echo "• Application Insights integration"
            echo "• Azure SQL Database setup"
            ;;
        "exercise03")
            echo "• Container Registry deployment scripts"
            echo "• Container Apps deployment configuration"
            echo "• Environment variable setup"
            echo "• Service-to-service communication"
            echo "• Monitoring configuration"
            ;;
        "exercise04")
            echo "• Azure Service Bus setup"
            echo "• Resilient HTTP communication"
            echo "• Circuit breaker implementation"
            echo "• Message-based architecture"
            echo "• Health check endpoints"
            ;;
        "exercise05")
            echo "• Auto-scaling configuration"
            echo "• Azure Front Door setup"
            echo "• Cost monitoring dashboard"
            echo "• Production health checks"
            echo "• Security best practices"
            ;;
    esac
    echo ""
}

# Function to create files interactively
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if [ "$PREVIEW_ONLY" = true ]; then
        echo -e "${CYAN}📄 Would create: $file_path${NC}"
        echo -e "${YELLOW}   Description: $description${NC}"
        return
    fi
    
    echo -e "${CYAN}📄 Creating: $file_path${NC}"
    echo -e "${YELLOW}   $description${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -n "   File created. Press Enter to continue..."
        read -r
    fi
    echo ""
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 13 - Building Microservices with Azure${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Azure Setup and Microservices Overview"
    echo "  - exercise02: Building Azure-Ready Services"
    echo "  - exercise03: Deploy to Azure Container Apps"
    echo "  - exercise04: Azure Service Communication"
    echo "  - exercise05: Production Features"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo_error "Usage: $0 <exercise-name> [options]"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03"|"exercise04"|"exercise05")
        ;;
    *)
        echo_error "Unknown exercise: $EXERCISE_NAME"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome message
echo -e "${MAGENTA}☁️ Module 13: Building Microservices with Azure${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show what will be created
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo_info "Preview mode - no files will be created"
    echo ""
fi

# Check prerequisites
echo_info "Checking microservices prerequisites..."

# Check .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo_error ".NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo_error "Azure CLI is not installed. Please install Azure CLI to continue."
    echo_info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo_success "Prerequisites check completed"
echo ""

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]] || [[ $EXERCISE_NAME == "exercise05" ]]; then
        echo_success "Found existing $PROJECT_NAME from previous exercise"
        echo_info "This exercise will build on your existing work"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo_warning "Project '$PROJECT_NAME' already exists!"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise implementations
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Azure Setup and Microservices Overview

    explain_concept "Azure Container Apps for Microservices" \
"Azure Container Apps - Serverless Microservices:
• No Infrastructure Management: Focus on code, not servers
• Auto-scaling: Scale to zero, scale based on demand
• Built-in Features: Load balancing, HTTPS, service discovery
• Cost-Effective: Pay only for what you use
• Integrated Services: Azure SQL, Service Bus, Key Vault"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_info "Setting up Azure resources..."
        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"
    fi

    # Create Azure setup script
    create_file_interactive "setup-azure.sh" \
'#!/bin/bash
# Azure Microservices Setup Script

echo "Setting up Azure resources for microservices..."

# Variables
RESOURCE_GROUP="rg-microservices-demo"
LOCATION="eastus"
RANDOM_SUFFIX=$((RANDOM % 9000 + 1000))
ACR_NAME="acrmicroservices${RANDOM_SUFFIX}"
ENVIRONMENT="microservices-env"
SQL_SERVER="sql-microservices-${RANDOM_SUFFIX}"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd${RANDOM_SUFFIX}!"
APP_INSIGHTS="appi-microservices"

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Login check
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login
fi

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION --tags Environment=Training Project=Microservices Module=Module13 StudentID=$STUDENT_ID CreatedBy=TrainingScript

echo "Creating Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

echo "Creating Container Apps Environment..."
az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

echo "Creating SQL Server..."
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD

az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

echo "Creating databases..."
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name ProductDb --edition Basic
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name OrderDb --edition Basic

echo "Creating Application Insights..."
az monitor app-insights component create \
  --app $APP_INSIGHTS \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web

# Save configuration
cat > azure-config.sh << EOF
#!/bin/bash
# Azure Configuration
export RESOURCE_GROUP="$RESOURCE_GROUP"
export ACR_NAME="$ACR_NAME"
export ENVIRONMENT="$ENVIRONMENT"
export SQL_SERVER="$SQL_SERVER"
export SQL_ADMIN="$SQL_ADMIN"
export SQL_PASSWORD="$SQL_PASSWORD"
export APP_INSIGHTS="$APP_INSIGHTS"
EOF

chmod +x azure-config.sh

echo "\nSetup complete!"
echo "Configuration saved to azure-config.sh"
echo "Estimated monthly cost: ~\$30 (minimal usage)"
' \
"Azure resource setup script for microservices"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Building Azure-Ready Services

    explain_concept "Cloud-Native Service Design" \
"Azure-Ready Microservices:
• 12-Factor App Principles: Configuration, logging, stateless
• Azure Integration: SQL Database, Key Vault, App Insights
• Container-Ready: Dockerfile optimization for Azure
• Health Checks: Liveness and readiness probes
• Resilience: Built-in retry and circuit breaker patterns"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 2 requires Exercise 1 to be completed first!"
        echo_info "Please run: ./launch-exercises.sh exercise01"
        exit 1
    fi

    echo_info "Creating Azure-ready microservices..."
    
    # Create solution structure
    mkdir -p SourceCode
    cd SourceCode
    dotnet new sln -n AzureECommerce

    # Create shared library
    mkdir -p src/SharedLibraries
    cd src/SharedLibraries
    dotnet new classlib -n ECommerceMS.Shared --framework net8.0
    dotnet add ECommerceMS.Shared package Microsoft.Extensions.Logging
    cd ../..

    # Add shared library to solution
    dotnet sln add src/SharedLibraries/ECommerceMS.Shared/ECommerceMS.Shared.csproj

    # Create base entity
    create_file_interactive "src/SharedLibraries/ECommerceMS.Shared/Models/BaseEntity.cs" \
'using System.ComponentModel.DataAnnotations;

namespace ECommerceMS.Shared.Models;

public abstract class BaseEntity
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public string? UpdatedBy { get; set; }
}' \
"Base entity class for all microservices"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Deploy to Azure Container Apps

    explain_concept "Azure Container Apps Deployment" \
"Deploying to Azure Container Apps:
• Container Registry: Push images to Azure Container Registry
• Container Apps: Deploy without managing infrastructure
• Environment Variables: Configure services for Azure
• Service Discovery: Built-in service-to-service communication
• Monitoring: Application Insights integration"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 3 requires Exercises 1 and 2 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03"
        exit 1
    fi

    # Load Azure configuration
    echo_info "Loading Azure configuration..."
    if [ -f "azure-config.sh" ]; then
        source ./azure-config.sh
    else
        echo_error "Azure configuration not found. Please run exercise01 first!"
        exit 1
    fi
    
    # Create deployment script
    create_file_interactive "deploy-services.sh" \
'#!/bin/bash
# Deploy Services to Azure Container Apps

echo "Deploying services to Azure Container Apps..."

# Load configuration
source ./azure-config.sh

# Login to ACR
echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

# Build and push Product Service
echo "Building Product Service..."
cd SourceCode/ProductService
az acr build --registry $ACR_NAME --image product-service:v1 .

# Build and push Order Service
echo "Building Order Service..."
cd ../OrderService
az acr build --registry $ACR_NAME --image order-service:v1 .

cd ../..

# Deploy Product Service
echo "Deploying Product Service..."
az containerapp create \
  --name product-service \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image "${ACR_NAME}.azurecr.io/product-service:v1" \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 3

# Deploy Order Service
echo "Deploying Order Service..."
az containerapp create \
  --name order-service \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image "${ACR_NAME}.azurecr.io/order-service:v1" \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 3

echo "Deployment complete!"
' \
"Azure deployment script"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Azure Service Communication

    explain_concept "Azure Service Bus & Resilience" \
"Azure Service Communication:
• Service Bus: Reliable message delivery
• HTTP Communication: Service-to-service calls
• Polly Resilience: Retry, circuit breaker, timeout
• Health Checks: Monitor service availability
• Distributed Tracing: Application Insights correlation"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 4 requires Exercises 1, 2, and 3 to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04"
        exit 1
    fi

    # Create Service Bus configuration
    create_file_interactive "configure-servicebus.sh" \
'#!/bin/bash
# Azure Service Bus Configuration

echo "Configuring Azure Service Bus..."

# Load Azure config
source ./azure-config.sh

# Create Service Bus namespace
SERVICE_BUS="sb-microservices-${RANDOM}"

az servicebus namespace create \
  --resource-group $RESOURCE_GROUP \
  --name $SERVICE_BUS \
  --location $LOCATION \
  --sku Basic

# Create queue for order events
az servicebus queue create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $SERVICE_BUS \
  --name order-events

# Get connection string
SB_CONNECTION=$(az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $SERVICE_BUS \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString -o tsv)

echo "Service Bus created: $SERVICE_BUS"
echo "Connection string saved."

# Update services with Service Bus connection
echo "Updating services with Service Bus connection..."
' \
"Azure Service Bus configuration script"

elif [[ $EXERCISE_NAME == "exercise05" ]]; then
    # Exercise 5: Production Features

    explain_concept "Production-Ready Features" \
"Production Features for Azure:
• Auto-scaling: CPU and HTTP-based scaling rules
• Azure Front Door: Global load balancing and CDN
• Health Monitoring: Comprehensive health checks
• Cost Management: Monitoring and optimization
• Security: Managed identities and Key Vault"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo_error "Exercise 5 requires all previous exercises to be completed first!"
        echo_info "Please run exercises in order: exercise01, exercise02, exercise03, exercise04, exercise05"
        exit 1
    fi

    echo_info "Configuring production features..."

    # Create scaling configuration
    create_file_interactive "configure-scaling.sh" \
'#!/bin/bash
# Configure Auto-scaling for Container Apps

echo "Configuring auto-scaling..."

# Load Azure config
source ./azure-config.sh

# Configure Product Service scaling
echo "Setting up Product Service auto-scaling..."
az containerapp update \
  --name product-service \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 1 \
  --max-replicas 10 \
  --scale-rule-name cpu-scaling \
  --scale-rule-type cpu \
  --scale-rule-metadata type=utilization value=70

# Configure Order Service scaling
echo "Setting up Order Service auto-scaling..."
az containerapp update \
  --name order-service \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 1 \
  --max-replicas 5 \
  --scale-rule-name http-scaling \
  --scale-rule-type http \
  --scale-rule-metadata concurrentRequests=50

echo "Auto-scaling configured!"
echo "Services will now scale based on load."
' \
"Auto-scaling configuration for Container Apps"

fi

# Final completion message
echo ""
echo_success "🎉 $EXERCISE_NAME template created successfully!"
echo ""
echo_info "📋 Next steps:"

case $EXERCISE_NAME in
    "exercise01")
        echo "1. Run the setup script: ${CYAN}chmod +x setup-azure.sh && ./setup-azure.sh${NC}"
        echo "2. Verify resources in Azure Portal"
        echo "3. Review the cost estimation"
        echo "4. Save the azure-config.sh file for next exercises"
        ;;
    "exercise02")
        echo "1. Navigate to SourceCode directory"
        echo "2. Build services: ${CYAN}dotnet build${NC}"
        echo "3. Test locally (optional): ${CYAN}dotnet run${NC}"
        echo "4. Review Dockerfile configurations"
        ;;
    "exercise03")
        echo "1. Build and push images to ACR"
        echo "2. Deploy to Container Apps: ${CYAN}./deploy-services.sh${NC}"
        echo "3. Test deployed services in Azure"
        echo "4. Check Application Insights for telemetry"
        ;;
    "exercise04")
        echo "1. Configure Service Bus: ${CYAN}./configure-servicebus.sh${NC}"
        echo "2. Update services with messaging code"
        echo "3. Test service-to-service communication"
        echo "4. Verify resilience patterns are working"
        ;;
    "exercise05")
        echo "1. Configure auto-scaling: ${CYAN}./configure-scaling.sh${NC}"
        echo "2. Set up Azure Front Door (optional)"
        echo "3. Review costs in Azure Cost Management"
        echo "4. Implement production monitoring"
        ;;
esac

echo ""
echo_info "📚 For detailed instructions, refer to the exercise files in the Exercises/ directory."
echo_info "🔗 Additional microservices resources available in the Resources/ directory."
echo_info "💡 Consider using the complete SourceCode implementation as a reference."
