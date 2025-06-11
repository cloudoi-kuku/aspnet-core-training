#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Kind
    if ! command -v kind &> /dev/null; then
        print_error "Kind is not installed. Please install Kind first."
        echo "Visit: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check Helm
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        echo "Visit: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Build Docker images
build_images() {
    print_info "Building Docker images..."
    
    # Build backend
    print_info "Building backend image..."
    cd src/backend/ECommerce.API
    docker build -t ecommerce-backend:latest .
    if [ $? -ne 0 ]; then
        print_error "Failed to build backend image"
        exit 1
    fi
    cd ../../..
    
    # Build frontend
    print_info "Building frontend image..."
    cd src/frontend
    docker build -t ecommerce-frontend:latest .
    if [ $? -ne 0 ]; then
        print_error "Failed to build frontend image"
        exit 1
    fi
    cd ../..
    
    print_success "Docker images built successfully!"
}

# Create Kind cluster
create_kind_cluster() {
    print_info "Creating Kind cluster..."
    
    # Check if cluster already exists
    if kind get clusters | grep -q ecommerce-cluster; then
        print_warning "Kind cluster 'ecommerce-cluster' already exists. Deleting it..."
        kind delete cluster --name ecommerce-cluster
    fi
    
    # Create cluster
    kind create cluster --name ecommerce-cluster --config kind-cluster-config.yaml
    if [ $? -ne 0 ]; then
        print_error "Failed to create Kind cluster"
        exit 1
    fi
    
    # Set kubectl context
    kubectl cluster-info --context kind-ecommerce-cluster
    
    print_success "Kind cluster created successfully!"
}

# Load images into Kind
load_images() {
    print_info "Loading images into Kind cluster..."
    
    kind load docker-image ecommerce-backend:latest --name ecommerce-cluster
    kind load docker-image ecommerce-frontend:latest --name ecommerce-cluster
    
    print_success "Images loaded into Kind cluster!"
}

# Install NGINX Ingress Controller
install_ingress() {
    print_info "Installing NGINX Ingress Controller..."
    
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    # Wait for ingress controller to be ready
    print_info "Waiting for Ingress Controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    
    print_success "NGINX Ingress Controller installed!"
}

# Deploy application with Helm
deploy_application() {
    print_info "Deploying application with Helm..."
    
    # Add Helm repositories
    print_info "Adding Helm repositories..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create namespace
    kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -
    
    # Install the application
    print_info "Installing E-Commerce application..."
    helm upgrade --install ecommerce-app ./helm-charts/ecommerce-app \
        --namespace ecommerce \
        --create-namespace \
        --wait \
        --timeout 10m
    
    if [ $? -ne 0 ]; then
        print_error "Failed to deploy application"
        exit 1
    fi
    
    print_success "Application deployed successfully!"
}

# Setup monitoring (optional)
setup_monitoring() {
    read -p "Do you want to setup monitoring (Prometheus & Grafana)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setting up monitoring..."
        ./setup-monitoring.sh
        print_success "Monitoring setup complete!"
    fi
}

# Display access information
display_access_info() {
    print_info "=== ACCESS INFORMATION ==="
    echo
    echo "Frontend URL: http://localhost:3000"
    echo "Backend API URL: http://localhost:5000"
    echo "RabbitMQ Management: http://localhost:15672 (guest/guest)"
    echo "Redis Commander: http://localhost:8081"
    echo
    
    if kubectl get svc -n ecommerce | grep -q prometheus; then
        echo "Prometheus: http://localhost:9090"
        echo "Grafana: http://localhost:3001 (admin/admin)"
        echo
    fi
    
    echo "To check pod status:"
    echo "  kubectl get pods -n ecommerce"
    echo
    echo "To view logs:"
    echo "  kubectl logs -n ecommerce -l app=ecommerce-backend"
    echo "  kubectl logs -n ecommerce -l app=ecommerce-frontend"
    echo
    echo "To delete the deployment:"
    echo "  helm uninstall ecommerce-app -n ecommerce"
    echo "  kind delete cluster --name ecommerce-cluster"
}

# Main execution
main() {
    echo "=== E-Commerce Deployment to Kind Cluster ==="
    echo
    
    check_prerequisites
    build_images
    create_kind_cluster
    load_images
    install_ingress
    deploy_application
    setup_monitoring
    
    echo
    print_success "Deployment completed successfully!"
    echo
    display_access_info
}

# Run main function
main