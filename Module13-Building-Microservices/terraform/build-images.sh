#!/bin/bash

# E-Commerce Platform Docker Image Build Script
# This script builds the frontend and backend Docker images for deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
REGISTRY=""
TAG="latest"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--registry)
      REGISTRY="$2"
      shift 2
      ;;
    -t|--tag)
      TAG="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-r|--registry REGISTRY] [-t|--tag TAG]"
      echo "  -r, --registry  Container registry (e.g., ecommerceacrrv2i.azurecr.io)"
      echo "  -t, --tag       Image tag (default: latest)"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${CYAN}🐳 Building E-Commerce Platform Docker Images${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Configuration
FRONTEND_IMAGE="ecommerce-frontend"
BACKEND_IMAGE="ecommerce-backend"

if [ -n "$REGISTRY" ]; then
    FRONTEND_IMAGE="$REGISTRY/$FRONTEND_IMAGE"
    BACKEND_IMAGE="$REGISTRY/$BACKEND_IMAGE"
fi

echo -e "${BLUE}📋 Build Configuration:${NC}"
echo "  Registry: ${REGISTRY:-local}"
echo "  Tag: $TAG"
echo "  Frontend Image: ${FRONTEND_IMAGE}:${TAG}"
echo "  Backend Image: ${BACKEND_IMAGE}:${TAG}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Check if source directories exist
if [ ! -d "src/frontend" ]; then
    echo -e "${RED}❌ Frontend source directory not found: src/frontend${NC}"
    echo -e "${YELLOW}Make sure you're running this script from the terraform directory${NC}"
    exit 1
fi

if [ ! -d "src/backend" ]; then
    echo -e "${RED}❌ Backend source directory not found: src/backend${NC}"
    echo -e "${YELLOW}Make sure you're running this script from the terraform directory${NC}"
    exit 1
fi

# Build Frontend Image
echo -e "${BLUE}🔨 Building Frontend Docker Image...${NC}"
echo -e "${YELLOW}Building Next.js SSR application...${NC}"

cd src/frontend

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found in src/frontend${NC}"
    exit 1
fi

# Build the frontend image
echo -e "${YELLOW}Running: docker build --tag ${FRONTEND_IMAGE}:${TAG} --build-arg NODE_ENV=production --build-arg NEXT_PUBLIC_API_URL=http://ecommerce-app-backend:5050 .${NC}"

docker build \
    --tag "${FRONTEND_IMAGE}:${TAG}" \
    --file Dockerfile \
    --build-arg NODE_ENV=production \
    --build-arg NEXT_PUBLIC_API_URL=http://ecommerce-app-backend:5050 \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Frontend Docker build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend image built successfully: ${FRONTEND_IMAGE}:${TAG}${NC}"

cd ../..

# Build Backend Image
echo -e "${BLUE}🔨 Building Backend Docker Image...${NC}"
echo -e "${YELLOW}Building .NET 8 API application...${NC}"

cd src/backend/ECommerce.API

# Check if project file exists
if [ ! -f "ECommerce.API.csproj" ]; then
    echo -e "${RED}❌ ECommerce.API.csproj not found in src/backend/ECommerce.API${NC}"
    exit 1
fi

# Build the backend image
echo -e "${YELLOW}Running: docker build --tag ${BACKEND_IMAGE}:${TAG} --build-arg ASPNETCORE_ENVIRONMENT=Production .${NC}"

docker build \
    --tag "${BACKEND_IMAGE}:${TAG}" \
    --file Dockerfile \
    --build-arg ASPNETCORE_ENVIRONMENT=Production \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Backend Docker build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Backend image built successfully: ${BACKEND_IMAGE}:${TAG}${NC}"

cd ../../..

# List built images
echo ""
echo -e "${CYAN}📦 Built Images:${NC}"
docker images | grep -E "(ecommerce-frontend|ecommerce-backend)" | head -10

# Push to registry if specified
if [ -n "$REGISTRY" ]; then
    echo ""
    echo -e "${BLUE}📤 Pushing images to registry...${NC}"
    
    echo -e "${YELLOW}Pushing frontend image...${NC}"
    docker push "${FRONTEND_IMAGE}:${TAG}"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to push frontend image!${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Pushing backend image...${NC}"
    docker push "${BACKEND_IMAGE}:${TAG}"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to push backend image!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Images pushed to registry successfully!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All images built successfully!${NC}"

echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo "  1. Deploy to AKS: helm upgrade --install ecommerce-app ./helm-charts/ecommerce-app --namespace ecommerce --create-namespace --values ./helm-charts/azure-values.yaml"
echo "  2. Test locally: docker-compose up"
echo "  3. View images: docker images | grep ecommerce"

if [ -n "$REGISTRY" ]; then
    echo "  4. Registry used: $REGISTRY"
fi

echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "  • Use -r parameter to push to a registry"
echo "  • Use -t parameter to use a specific tag"
echo "  • Example: ./build-images.sh -r ecommerceacrrv2i.azurecr.io -t v1.0.0"

echo ""
echo -e "${GREEN}✅ Build process completed successfully!${NC}"
