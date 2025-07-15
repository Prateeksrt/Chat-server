#!/bin/bash

# Kubernetes deployment script for TypeScript REST API
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="typescript-api"
IMAGE_NAME="typescript-api"
IMAGE_TAG="latest"

echo -e "${GREEN}🚀 Starting Kubernetes deployment for TypeScript REST API${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if we're connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Not connected to a Kubernetes cluster. Please configure kubectl.${NC}"
    exit 1
fi

# Build and push Docker image (if needed)
if [ "$1" = "--build" ]; then
    echo -e "${YELLOW}🔨 Building Docker image...${NC}"
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    
    # Check if we need to push to a registry
    if [ -n "$DOCKER_REGISTRY" ]; then
        echo -e "${YELLOW}📤 Pushing image to registry...${NC}"
        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        # Update the image name in kustomization
        sed -i "s|newTag: latest|newName: ${DOCKER_REGISTRY}/${IMAGE_NAME}\n  newTag: ${IMAGE_TAG}|" kustomization.yaml
    fi
fi

# Create namespace if it doesn't exist
echo -e "${YELLOW}📦 Creating namespace...${NC}"
kubectl apply -f namespace.yaml

# Apply all Kubernetes resources
echo -e "${YELLOW}📋 Applying Kubernetes resources...${NC}"
kubectl apply -k .

# Wait for deployment to be ready
echo -e "${YELLOW}⏳ Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/typescript-api -n ${NAMESPACE}

# Get service information
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${YELLOW}📊 Service Information:${NC}"
kubectl get svc -n ${NAMESPACE}

echo -e "${YELLOW}🔍 Pod Status:${NC}"
kubectl get pods -n ${NAMESPACE}

echo -e "${YELLOW}📈 HPA Status:${NC}"
kubectl get hpa -n ${NAMESPACE}

echo -e "${GREEN}🎉 Your TypeScript REST API is now deployed on Kubernetes!${NC}"
echo -e "${YELLOW}💡 To access your API:${NC}"
echo -e "   - If using LoadBalancer: kubectl get svc typescript-api-service -n ${NAMESPACE}"
echo -e "   - If using Ingress: Update the host in ingress.yaml and apply"
echo -e "   - For local testing: kubectl port-forward svc/typescript-api-service 8080:80 -n ${NAMESPACE}"