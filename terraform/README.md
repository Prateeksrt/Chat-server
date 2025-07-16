# Terraform Infrastructure as Code

This directory contains Terraform configurations for deploying the TypeScript REST API to multiple cloud providers (AWS, Azure, GCP).

## 🏗️ Architecture

The infrastructure is designed to be cloud-agnostic and supports:

- **AWS**: ECS Fargate with Application Load Balancer
- **Azure**: Container Instances with Load Balancer
- **GCP**: Cloud Run with Global Load Balancer

### Common Components

- **Networking**: VPC/VNet with public and private subnets
- **Container Registry**: ECR/ACR/GCR for storing Docker images
- **Load Balancer**: Application load balancer with health checks
- **Monitoring**: CloudWatch/Application Insights/Cloud Monitoring
- **Logging**: Centralized logging with retention policies

## 📁 Directory Structure

```
terraform/
├── main.tf                 # Main Terraform configuration
├── aws.tf                  # AWS-specific resources
├── azure.tf                # Azure-specific resources
├── gcp.tf                  # GCP-specific resources
├── deploy.sh               # Deployment script
├── environments/           # Environment-specific variables
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform** (>= 1.0)
2. **Docker** (for building images)
3. **Cloud CLI tools**:
   - AWS CLI (for AWS)
   - Azure CLI (for Azure)
   - Google Cloud SDK (for GCP)

### 1. Configure Cloud Credentials

#### AWS
```bash
aws configure
```

#### Azure
```bash
az login
az account set --subscription <subscription-id>
```

#### GCP
```bash
gcloud auth login
gcloud config set project <project-id>
```

### 2. Deploy Infrastructure

Use the deployment script for easy deployment:

```bash
# Deploy to AWS dev environment
./deploy.sh -e dev -p aws -b

# Deploy to Azure staging environment
./deploy.sh -e staging -p azure -b

# Deploy to GCP production environment
./deploy.sh -e prod -p gcp -b
```

### 3. Manual Deployment

If you prefer manual deployment:

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars

# Build and push Docker image (after infrastructure is ready)
# See deployment script for provider-specific commands
```

## 🔧 Configuration

### Environment Variables

Each environment has its own `.tfvars` file in the `environments/` directory:

- `dev.tfvars` - Development environment
- `staging.tfvars` - Staging environment  
- `prod.tfvars` - Production environment

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cloud_provider` | Cloud provider (aws, azure, gcp) | aws |
| `environment` | Environment name (dev, staging, prod) | dev |
| `project_name` | Project name for resource naming | typescript-rest-api |
| `region` | Cloud region | us-east-1 |
| `instance_type` | Compute instance type | t3.micro |

### Provider-Specific Variables

#### GCP
- `billing_account` - GCP billing account ID
- `org_id` - GCP organization ID
- `alert_email` - Email for monitoring alerts

## 🌐 Cloud Provider Details

### AWS
- **Compute**: ECS Fargate (serverless containers)
- **Load Balancer**: Application Load Balancer
- **Registry**: Elastic Container Registry (ECR)
- **Monitoring**: CloudWatch
- **Networking**: VPC with public/private subnets

### Azure
- **Compute**: Container Instances
- **Load Balancer**: Standard Load Balancer
- **Registry**: Azure Container Registry (ACR)
- **Monitoring**: Application Insights
- **Networking**: Virtual Network with subnets

### GCP
- **Compute**: Cloud Run (serverless containers)
- **Load Balancer**: Global HTTP(S) Load Balancer
- **Registry**: Container Registry (GCR)
- **Monitoring**: Cloud Monitoring
- **Networking**: VPC with subnets

## 📊 Monitoring and Logging

### Health Checks
All deployments include health checks at `/health` endpoint.

### Logging
- **AWS**: CloudWatch Logs
- **Azure**: Application Insights + Storage
- **GCP**: Cloud Logging + Storage

### Monitoring
- **AWS**: CloudWatch Metrics
- **Azure**: Application Insights
- **GCP**: Cloud Monitoring

## 🔄 Deployment Workflow

1. **Infrastructure Setup**: Deploy cloud resources
2. **Image Build**: Build Docker image
3. **Image Push**: Push to container registry
4. **Service Deployment**: Deploy application service
5. **Health Verification**: Verify application health

## 🛠️ Maintenance

### Updating Infrastructure
```bash
# Plan changes
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars
```

### Updating Application
```bash
# Build and push new image
./deploy.sh -e dev -p aws -b
```

### Destroying Infrastructure
```bash
# Destroy specific environment
./deploy.sh -e dev -p aws -d

# Or manually
terraform destroy -var-file=environments/dev.tfvars
```

## 🔒 Security Considerations

- All resources are tagged for cost tracking
- Private subnets for application instances
- Security groups/firewall rules limit access
- Container registries with image scanning
- IAM roles with least privilege access

## 💰 Cost Optimization

- Use appropriate instance types for each environment
- Enable auto-scaling where available
- Set up log retention policies
- Use spot instances for non-production workloads (AWS)

## 🚨 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify cloud credentials are configured
   - Check CLI tools are installed and authenticated

2. **Resource Creation Failures**
   - Check resource quotas in your cloud account
   - Verify region availability for all services

3. **Image Push Failures**
   - Ensure container registry is created first
   - Check authentication to registry

4. **Health Check Failures**
   - Verify application is listening on correct port
   - Check security group/firewall rules

### Debug Commands

```bash
# Check Terraform state
terraform show

# Check specific resource
terraform state show aws_ecs_service.app

# View logs (provider-specific)
# AWS: CloudWatch Logs
# Azure: Application Insights
# GCP: Cloud Logging
```

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/)
- [Google Cloud Run](https://cloud.google.com/run/docs)

## 🤝 Contributing

When modifying the Terraform configuration:

1. Test changes in dev environment first
2. Update documentation for new variables
3. Ensure backward compatibility
4. Add appropriate tags and labels
5. Update deployment script if needed