#!/bin/bash

# Terraform Deployment Script
# This script builds, pushes, and deploys the application to the selected cloud provider

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment to deploy (dev, staging, prod) [default: dev]"
    echo "  -p, --provider PROVIDER  Cloud provider (aws, azure, gcp) [default: aws]"
    echo "  -r, --region REGION      Cloud region [default: us-east-1]"
    echo "  -b, --build              Build and push Docker image"
    echo "  -d, --destroy            Destroy infrastructure"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -p aws -b                    # Deploy to AWS dev with build"
    echo "  $0 -e staging -p azure                 # Deploy to Azure staging"
    echo "  $0 -e prod -p gcp -b                   # Deploy to GCP prod with build"
    echo "  $0 -e dev -d                           # Destroy dev infrastructure"
}

# Default values
ENVIRONMENT="dev"
PROVIDER="aws"
REGION="us-east-1"
BUILD_IMAGE=false
DESTROY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--provider)
            PROVIDER="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_IMAGE=true
            shift
            ;;
        -d|--destroy)
            DESTROY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

# Validate provider
if [[ ! "$PROVIDER" =~ ^(aws|azure|gcp)$ ]]; then
    print_error "Invalid provider: $PROVIDER. Must be aws, azure, or gcp."
    exit 1
fi

# Check if tfvars file exists
TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"
if [[ ! -f "$TFVARS_FILE" ]]; then
    print_error "Environment file not found: $TFVARS_FILE"
    exit 1
fi

# Function to build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    # Get project name from tfvars
    PROJECT_NAME=$(grep -E '^project_name\s*=' "$TFVARS_FILE" | cut -d'=' -f2 | tr -d ' "#' || echo "typescript-rest-api")
    
    case $PROVIDER in
        aws)
            # Get ECR repository URL
            ECR_URL=$(terraform output -raw aws_ecr_repository_url 2>/dev/null || echo "")
            if [[ -z "$ECR_URL" ]]; then
                print_error "ECR repository URL not found. Run terraform apply first."
                exit 1
            fi
            
            # Login to ECR
            print_status "Logging in to ECR..."
            aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_URL"
            
            # Build and push
            docker build -t "$ECR_URL:latest" ..
            docker push "$ECR_URL:latest"
            ;;
            
        azure)
            # Get ACR login server
            ACR_URL=$(terraform output -raw azure_container_registry_url 2>/dev/null || echo "")
            if [[ -z "$ACR_URL" ]]; then
                print_error "ACR URL not found. Run terraform apply first."
                exit 1
            fi
            
            # Login to ACR
            print_status "Logging in to ACR..."
            az acr login --name "$ACR_URL"
            
            # Build and push
            docker build -t "$ACR_URL/${PROJECT_NAME}:latest" ..
            docker push "$ACR_URL/${PROJECT_NAME}:latest"
            ;;
            
        gcp)
            # Get project ID
            PROJECT_ID=$(terraform output -raw gcp_project_id 2>/dev/null || echo "")
            if [[ -z "$PROJECT_ID" ]]; then
                print_error "GCP project ID not found. Run terraform apply first."
                exit 1
            fi
            
            # Configure Docker for GCR
            print_status "Configuring Docker for GCR..."
            gcloud auth configure-docker
            
            # Build and push
            docker build -t "gcr.io/$PROJECT_ID/${PROJECT_NAME}:latest" ..
            docker push "gcr.io/$PROJECT_ID/${PROJECT_NAME}:latest"
            ;;
    esac
    
    print_success "Docker image built and pushed successfully!"
}

# Function to run terraform commands
run_terraform() {
    local action=$1
    
    print_status "Running terraform $action..."
    
    # Initialize terraform if needed
    if [[ ! -d ".terraform" ]]; then
        print_status "Initializing Terraform..."
        terraform init
    fi
    
    # Plan and apply
    if [[ "$action" == "apply" ]]; then
        terraform plan -var-file="$TFVARS_FILE" -out=tfplan
        terraform apply tfplan
        rm -f tfplan
    elif [[ "$action" == "destroy" ]]; then
        terraform plan -var-file="$TFVARS_FILE" -destroy -out=tfplan
        terraform apply tfplan
        rm -f tfplan
    fi
}

# Main execution
print_status "Starting deployment..."
print_status "Environment: $ENVIRONMENT"
print_status "Provider: $PROVIDER"
print_status "Region: $REGION"

# Change to terraform directory
cd "$(dirname "$0")"

if [[ "$DESTROY" == true ]]; then
    print_warning "Destroying infrastructure..."
    run_terraform "destroy"
    print_success "Infrastructure destroyed successfully!"
else
    # Deploy infrastructure
    run_terraform "apply"
    print_success "Infrastructure deployed successfully!"
    
    # Build and push image if requested
    if [[ "$BUILD_IMAGE" == true ]]; then
        build_and_push_image
    fi
    
    # Show outputs
    print_status "Deployment outputs:"
    terraform output
fi

print_success "Deployment completed successfully!"