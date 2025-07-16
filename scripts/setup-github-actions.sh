#!/bin/bash

# GitHub Actions Setup Script for Terraform DigitalOcean Infrastructure
# This script helps you set up the required secrets and test the workflow

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

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  https://cli.github.com/"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_warning "Terraform is not installed. It will be installed by the workflow."
    fi
    
    print_success "Requirements check completed"
}

# Check if user is authenticated with GitHub CLI
check_github_auth() {
    print_status "Checking GitHub authentication..."
    
    if ! gh auth status &> /dev/null; then
        print_error "You are not authenticated with GitHub CLI. Please run:"
        echo "  gh auth login"
        exit 1
    fi
    
    print_success "GitHub authentication verified"
}

# Get repository information
get_repo_info() {
    print_status "Getting repository information..."
    
    # Get current repository
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    if [ -z "$REPO" ]; then
        print_error "Could not determine repository. Make sure you're in a git repository."
        exit 1
    fi
    
    print_success "Repository: $REPO"
}

# Check if secrets already exist
check_existing_secrets() {
    print_status "Checking existing secrets..."
    
    if gh secret list 2>/dev/null | grep -q "DIGITALOCEAN_TOKEN"; then
        print_warning "DIGITALOCEAN_TOKEN secret already exists"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping secret setup"
            return 0
        fi
    fi
}

# Setup DigitalOcean token
setup_digitalocean_token() {
    print_status "Setting up DigitalOcean API token..."
    
    echo "To get your DigitalOcean API token:"
    echo "1. Go to https://cloud.digitalocean.com/account/api/tokens"
    echo "2. Click 'Generate New Token'"
    echo "3. Give it a name (e.g., 'GitHub Actions Terraform')"
    echo "4. Select 'Write' scope"
    echo "5. Copy the token"
    echo
    
    read -p "Enter your DigitalOcean API token: " -s DO_TOKEN
    echo
    
    if [ -z "$DO_TOKEN" ]; then
        print_error "Token cannot be empty"
        exit 1
    fi
    
    # Test the token
    print_status "Testing DigitalOcean token..."
    if curl -s -H "Authorization: Bearer $DO_TOKEN" https://api.digitalocean.com/v2/account | grep -q "account"; then
        print_success "DigitalOcean token is valid"
    else
        print_error "Invalid DigitalOcean token. Please check your token and try again."
        exit 1
    fi
    
    # Set the secret
    print_status "Setting GitHub secret..."
    echo "$DO_TOKEN" | gh secret set DIGITALOCEAN_TOKEN
    
    print_success "DigitalOcean token secret has been set"
}

# Test the workflow
test_workflow() {
    print_status "Testing workflow..."
    
    echo "The workflow will be triggered manually. You can:"
    echo "1. Go to https://github.com/$REPO/actions"
    echo "2. Select 'Terraform DigitalOcean Infrastructure'"
    echo "3. Click 'Run workflow'"
    echo "4. Choose parameters:"
    echo "   - Environment: dev"
    echo "   - Action: plan"
    echo "   - Region: nyc1"
    echo "   - Domain Name: (leave empty)"
    echo
    
    read -p "Do you want to trigger a test workflow now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Triggering test workflow..."
        gh workflow run terraform-digitalocean.yml \
            -f environment=dev \
            -f action=plan \
            -f region=nyc1 \
            -f domain_name=""
        
        print_success "Workflow triggered! Check the Actions tab to monitor progress."
    fi
}

# Show next steps
show_next_steps() {
    echo
    print_success "Setup completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Monitor your first workflow run in the Actions tab"
    echo "2. Review the Terraform plan before applying"
    echo "3. For production deployments, consider:"
    echo "   - Setting up remote state storage"
    echo "   - Configuring domain names"
    echo "   - Setting up monitoring and alerting"
    echo "4. Review the workflow documentation at .github/workflows/README.md"
    echo
    echo "Useful commands:"
    echo "  gh workflow list                    # List all workflows"
    echo "  gh workflow run terraform-digitalocean.yml  # Trigger workflow"
    echo "  gh secret list                     # List secrets"
    echo
}

# Main execution
main() {
    echo "GitHub Actions Setup for Terraform DigitalOcean Infrastructure"
    echo "=============================================================="
    echo
    
    check_requirements
    check_github_auth
    get_repo_info
    check_existing_secrets
    setup_digitalocean_token
    test_workflow
    show_next_steps
}

# Run main function
main "$@"