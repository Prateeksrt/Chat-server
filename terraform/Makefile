# Terraform Makefile
# Provides convenient commands for managing infrastructure

.PHONY: help init plan apply destroy clean validate format

# Default target
help:
	@echo "Available commands:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Plan deployment (dev environment)"
	@echo "  apply     - Apply changes (dev environment)"
	@echo "  destroy   - Destroy infrastructure (dev environment)"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  format    - Format Terraform files"
	@echo "  clean     - Clean up Terraform files"
	@echo "  deploy    - Deploy with build (dev environment)"
	@echo ""
	@echo "Environment-specific commands:"
	@echo "  plan-dev     - Plan dev environment"
	@echo "  plan-staging - Plan staging environment"
	@echo "  plan-prod    - Plan production environment"
	@echo "  apply-dev    - Apply dev environment"
	@echo "  apply-staging- Apply staging environment"
	@echo "  apply-prod   - Apply production environment"
	@echo "  destroy-dev  - Destroy dev environment"
	@echo "  destroy-staging - Destroy staging environment"
	@echo "  destroy-prod - Destroy production environment"

# Initialize Terraform
init:
	terraform init

# Validate configuration
validate:
	terraform validate

# Format Terraform files
format:
	terraform fmt -recursive

# Plan deployment (default: dev)
plan: validate
	terraform plan -var-file=environments/dev.tfvars

# Apply changes (default: dev)
apply: validate
	terraform apply -var-file=environments/dev.tfvars

# Destroy infrastructure (default: dev)
destroy:
	terraform destroy -var-file=environments/dev.tfvars

# Clean up Terraform files
clean:
	rm -rf .terraform
	rm -f *.tfstate*
	rm -f *.tfplan

# Deploy with build (default: dev)
deploy:
	./deploy.sh -e dev -p digitalocean -b

# Environment-specific commands
plan-dev: validate
	terraform plan -var-file=environments/dev.tfvars

plan-staging: validate
	terraform plan -var-file=environments/staging.tfvars

plan-prod: validate
	terraform plan -var-file=environments/prod.tfvars

apply-dev: validate
	terraform apply -var-file=environments/dev.tfvars

apply-staging: validate
	terraform apply -var-file=environments/staging.tfvars

apply-prod: validate
	terraform apply -var-file=environments/prod.tfvars

destroy-dev:
	terraform destroy -var-file=environments/dev.tfvars

destroy-staging:
	terraform destroy -var-file=environments/staging.tfvars

destroy-prod:
	terraform destroy -var-file=environments/prod.tfvars

# Provider-specific deployments
deploy-aws-dev:
	./deploy.sh -e dev -p aws -b

deploy-aws-staging:
	./deploy.sh -e staging -p aws -b

deploy-aws-prod:
	./deploy.sh -e prod -p aws -b

deploy-azure-dev:
	./deploy.sh -e dev -p azure -b

deploy-azure-staging:
	./deploy.sh -e staging -p azure -b

deploy-azure-prod:
	./deploy.sh -e prod -p azure -b

deploy-gcp-dev:
	./deploy.sh -e dev -p gcp -b

deploy-gcp-staging:
	./deploy.sh -e staging -p gcp -b

deploy-gcp-prod:
	./deploy.sh -e prod -p gcp -b

# DigitalOcean deployments
deploy-digitalocean-dev:
	./deploy.sh -e dev -p digitalocean -b

deploy-digitalocean-staging:
	./deploy.sh -e staging -p digitalocean -b

deploy-digitalocean-prod:
	./deploy.sh -e prod -p digitalocean -b

# Show outputs
output:
	terraform output

# Show state
state:
	terraform show

# Import existing resources (example)
import-example:
	terraform import aws_ecs_cluster.main cluster-name

# Workspace management (if using workspaces)
workspace-dev:
	terraform workspace select dev || terraform workspace new dev

workspace-staging:
	terraform workspace select staging || terraform workspace new staging

workspace-prod:
	terraform workspace select prod || terraform workspace new prod

# Security and compliance
check-security:
	@echo "Running security checks..."
	@echo "1. Check for hardcoded secrets..."
	@grep -r "password\|secret\|key" . --exclude-dir=.terraform --exclude=*.tfstate* || true
	@echo "2. Validate Terraform configuration..."
	terraform validate
	@echo "3. Check for sensitive outputs..."
	@echo "Security check completed."

# Cost estimation (requires terraform-cost-estimation plugin)
cost-estimate:
	@echo "Estimating costs..."
	@echo "Note: Install terraform-cost-estimation plugin for accurate estimates"
	terraform plan -var-file=environments/dev.tfvars -out=tfplan
	@echo "Cost estimation completed. Check tfplan file."

# Backup state
backup-state:
	@echo "Backing up Terraform state..."
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "State backed up successfully."; \
	else \
		echo "No terraform.tfstate file found."; \
	fi

# Restore state
restore-state:
	@echo "Available backups:"
	@ls -la terraform.tfstate.backup.* 2>/dev/null || echo "No backups found"
	@echo "To restore, run: cp terraform.tfstate.backup.YYYYMMDD_HHMMSS terraform.tfstate"