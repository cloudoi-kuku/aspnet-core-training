#!/bin/bash

# Terraform Deployment Script for E-Commerce Microservices on Azure
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_color $YELLOW "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_color $RED "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_color $RED "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_color $RED "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_color $RED "Helm is not installed. Please install it first."
        exit 1
    fi
    
    print_color $GREEN "All prerequisites are installed."
}

# Function to login to Azure
azure_login() {
    print_color $YELLOW "Logging into Azure..."
    
    if ! az account show &> /dev/null; then
        az login
    else
        print_color $GREEN "Already logged into Azure."
    fi
    
    # Set subscription if provided
    if [ ! -z "$AZURE_SUBSCRIPTION_ID" ]; then
        az account set --subscription $AZURE_SUBSCRIPTION_ID
        print_color $GREEN "Azure subscription set to: $AZURE_SUBSCRIPTION_ID"
    fi
}

# Function to create Terraform backend storage
create_terraform_backend() {
    print_color $YELLOW "Creating Terraform backend storage..."
    
    BACKEND_RG="terraform-state-rg"
    BACKEND_STORAGE="tfstateecommerce33"
    BACKEND_CONTAINER="tfstate"
    
    # Check if resource group exists
    if ! az group show --name $BACKEND_RG &> /dev/null; then
        print_color $YELLOW "Creating resource group for Terraform state..."
        az group create --name $BACKEND_RG --location "East US"
    fi
    
    # Check if storage account exists
    if ! az storage account show --name $BACKEND_STORAGE --resource-group $BACKEND_RG &> /dev/null; then
        print_color $YELLOW "Creating storage account for Terraform state..."
        az storage account create \
            --name $BACKEND_STORAGE \
            --resource-group $BACKEND_RG \
            --location "East US" \
            --sku Standard_LRS \
            --encryption-services blob
    fi
    
    # Get storage account key
    ACCOUNT_KEY=$(az storage account keys list --resource-group $BACKEND_RG --account-name $BACKEND_STORAGE --query '[0].value' -o tsv)
    
    # Create blob container
    az storage container create \
        --name $BACKEND_CONTAINER \
        --account-name $BACKEND_STORAGE \
        --account-key $ACCOUNT_KEY \
        --auth-mode key
    
    print_color $GREEN "Terraform backend storage created successfully."
}

# Function to initialize Terraform
terraform_init() {
    print_color $YELLOW "Initializing Terraform..."
    
    cd terraform
    terraform init -upgrade
    
    print_color $GREEN "Terraform initialized successfully."
}

# Function to validate Terraform configuration
terraform_validate() {
    print_color $YELLOW "Validating Terraform configuration..."
    
    terraform fmt -check
    terraform validate
    
    print_color $GREEN "Terraform configuration is valid."
}

# Function to plan Terraform deployment
terraform_plan() {
    print_color $YELLOW "Planning Terraform deployment..."
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_color $YELLOW "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_color $RED "Please edit terraform.tfvars with your values before proceeding."
        exit 1
    fi
    
    terraform plan -out=tfplan
    
    print_color $GREEN "Terraform plan created successfully."
}

# Function to apply Terraform deployment
terraform_apply() {
    print_color $YELLOW "Applying Terraform deployment..."
    
    read -p "Do you want to proceed with the deployment? (yes/no): " -n 3 -r
    echo
    if [[ $REPLY =~ ^[Yy]es$ ]]; then
        terraform apply tfplan
        print_color $GREEN "Terraform deployment completed successfully."
    else
        print_color $YELLOW "Deployment cancelled."
        exit 0
    fi
}

# Function to get AKS credentials
get_aks_credentials() {
    print_color $YELLOW "Getting AKS credentials..."
    
    RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    AKS_NAME=$(terraform output -raw aks_cluster_name)
    
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing
    
    print_color $GREEN "AKS credentials configured successfully."
}

# Function to build and push Docker images
build_and_push_images() {
    print_color $YELLOW "Building and pushing Docker images..."
    
    ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
    
    # Login to ACR
    print_color $YELLOW "Logging into Azure Container Registry..."
    az acr login --name ${ACR_LOGIN_SERVER%%.*}
    
    # Build and push images
    cd ../SourceCode/ECommerceMS
    
    services=("ProductService" "OrderService" "CustomerService" "ApiGateway")
    
    for service in "${services[@]}"; do
        print_color $YELLOW "Building $service..."
        docker build -t $ACR_LOGIN_SERVER/${service,,}:latest -f $service/Dockerfile .
        
        print_color $YELLOW "Pushing $service..."
        docker push $ACR_LOGIN_SERVER/${service,,}:latest
    done
    
    cd ../../terraform
    print_color $GREEN "Docker images built and pushed successfully."
}

# Function to deploy Kubernetes manifests
deploy_kubernetes() {
    print_color $YELLOW "Deploying Kubernetes manifests..."
    
    cd ../kubernetes
    
    # Get values from Terraform outputs
    ACR_LOGIN_SERVER=$(cd ../terraform && terraform output -raw acr_login_server)
    AZURE_CLIENT_ID=$(az aks show --resource-group $(cd ../terraform && terraform output -raw resource_group_name) --name $(cd ../terraform && terraform output -raw aks_cluster_name) --query identityProfile.kubeletidentity.clientId -o tsv)
    
    # Apply Kustomize with substitutions
    export ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
    export AZURE_CLIENT_ID=$AZURE_CLIENT_ID
    export IMAGE_TAG="latest"
    
    # Apply base manifests
    kubectl apply -k base/
    
    print_color $GREEN "Kubernetes manifests deployed successfully."
}

# Function to wait for deployments
wait_for_deployments() {
    print_color $YELLOW "Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=600s deployment --all -n ecommerce-apps
    
    print_color $GREEN "All deployments are ready."
}

# Function to show deployment status
show_status() {
    print_color $YELLOW "Deployment Status:"
    
    echo ""
    print_color $GREEN "=== Resource Group ==="
    terraform output resource_group_name
    
    echo ""
    print_color $GREEN "=== AKS Cluster ==="
    terraform output aks_cluster_name
    
    echo ""
    print_color $GREEN "=== Container Registry ==="
    terraform output acr_login_server
    
    echo ""
    print_color $GREEN "=== Kubernetes Deployments ==="
    kubectl get deployments -n ecommerce-apps
    
    echo ""
    print_color $GREEN "=== Kubernetes Services ==="
    kubectl get services -n ecommerce-apps
    
    echo ""
    print_color $GREEN "=== Ingress ==="
    kubectl get ingress -n ecommerce-apps
    
    echo ""
    print_color $GREEN "=== External IP ==="
    kubectl get service nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    echo ""
    
    echo ""
    print_color $GREEN "=== Grafana Dashboard ==="
    echo "URL: http://$(kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
    echo "Username: admin"
    echo "Password: $(kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)"
    echo ""
}

# Main execution
main() {
    print_color $GREEN "====================================="
    print_color $GREEN "E-Commerce Microservices Deployment"
    print_color $GREEN "====================================="
    echo ""
    
    # Parse command line arguments
    case "$1" in
        init)
            check_prerequisites
            azure_login
            create_terraform_backend
            terraform_init
            ;;
        plan)
            terraform_plan
            ;;
        apply)
            terraform_apply
            get_aks_credentials
            ;;
        deploy-k8s)
            deploy_kubernetes
            wait_for_deployments
            ;;
        build-images)
            build_and_push_images
            ;;
        status)
            show_status
            ;;
        destroy)
            print_color $RED "WARNING: This will destroy all resources!"
            read -p "Are you sure? (yes/no): " -n 3 -r
            echo
            if [[ $REPLY =~ ^[Yy]es$ ]]; then
                cd terraform
                terraform destroy
            fi
            ;;
        all)
            check_prerequisites
            azure_login
            create_terraform_backend
            terraform_init
            terraform_validate
            terraform_plan
            terraform_apply
            get_aks_credentials
            build_and_push_images
            deploy_kubernetes
            wait_for_deployments
            show_status
            ;;
        *)
            echo "Usage: $0 {init|plan|apply|deploy-k8s|build-images|status|destroy|all}"
            echo ""
            echo "Commands:"
            echo "  init         - Initialize Terraform and create backend storage"
            echo "  plan         - Create Terraform execution plan"
            echo "  apply        - Apply Terraform configuration"
            echo "  deploy-k8s   - Deploy Kubernetes manifests"
            echo "  build-images - Build and push Docker images to ACR"
            echo "  status       - Show deployment status"
            echo "  destroy      - Destroy all resources"
            echo "  all          - Run complete deployment"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"