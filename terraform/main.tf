# Main Terraform configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

# Variables
variable "cloud_provider" {
  description = "Cloud provider to use (aws, azure, gcp, digitalocean)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp", "digitalocean"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp, digitalocean."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "typescript-rest-api"
}

variable "region" {
  description = "Cloud region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance type for compute resources"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Provider configurations
provider "aws" {
  region = var.region
  alias  = "main"
}

provider "azurerm" {
  features {}
  alias = "main"
}

provider "google" {
  project = var.project_name
  region  = var.region
  alias   = "main"
}

provider "digitalocean" {
  alias = "main"
}

# Outputs
output "deployment_info" {
  description = "Deployment information"
  value = {
    cloud_provider = var.cloud_provider
    environment    = var.environment
    region         = var.region
    project_name   = var.project_name
  }
}