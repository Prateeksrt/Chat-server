# Infrastructure Setup with GitHub Actions and Terraform

This project includes a complete infrastructure automation setup using Terraform and GitHub Actions for deploying to DigitalOcean.

## 🚀 What's Included

### 1. GitHub Actions Workflow
- **File**: `.github/workflows/terraform-digitalocean.yml`
- **Features**:
  - Manual trigger with customizable parameters
  - Support for multiple environments (dev, staging, prod)
  - Support for all DigitalOcean regions
  - Security scanning with Trivy
  - Plan review and artifact upload
  - Comprehensive logging and notifications

### 2. Terraform Configuration
- **Main Configuration**: `terraform/main.tf`
- **DigitalOcean Resources**: `terraform/digitalocean.tf`
- **Features**:
  - Multi-cloud provider support
  - Environment-specific configurations
  - Container registry and app platform
  - Database clusters and load balancers
  - Firewall and monitoring
  - Custom domain support

### 3. Setup Scripts
- **Setup Script**: `scripts/setup-github-actions.sh`
- **Features**:
  - Automated GitHub secret configuration
  - DigitalOcean token validation
  - Workflow testing capabilities
  - Interactive setup process

### 4. Documentation
- **Workflow Documentation**: `.github/workflows/README.md`
- **Usage Examples**: `examples/workflow-examples.md`
- **Infrastructure Overview**: This document

## 🏗️ Infrastructure Components

### DigitalOcean Resources Created

1. **Container Registry**
   - Stores Docker images
   - Basic tier subscription
   - Region-specific deployment

2. **App Platform**
   - Containerized application hosting
   - Auto-scaling capabilities
   - Health checks and monitoring
   - Environment-specific sizing

3. **Database Cluster** (Production Only)
   - PostgreSQL 15
   - Managed database service
   - Automated backups
   - Maintenance windows

4. **Load Balancer** (Production Only)
   - Traffic distribution
   - Health checks
   - SSL termination

5. **Firewall**
   - Network security rules
   - HTTP/HTTPS access
   - Application port access
   - Outbound traffic rules

6. **Spaces Bucket**
   - Object storage for logs
   - Lifecycle policies
   - 30-day retention

7. **Monitoring & Alerting**
   - CPU utilization alerts
   - Memory usage monitoring
   - 5-minute windows
   - 80% threshold

8. **Domain & DNS** (Production Only)
   - Custom domain support
   - CNAME records
   - SSL certificates

## 🔧 Quick Start

### Prerequisites
1. GitHub repository with Actions enabled
2. DigitalOcean account with API token
3. GitHub CLI (optional, for automated setup)

### Step 1: Setup Secrets
```bash
# Run the automated setup script
./scripts/setup-github-actions.sh
```

Or manually:
1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add `DIGITALOCEAN_TOKEN` secret with your DigitalOcean API token

### Step 2: Test the Workflow
1. Go to Actions tab in your GitHub repository
2. Select "Terraform DigitalOcean Infrastructure"
3. Click "Run workflow"
4. Choose parameters:
   - Environment: `dev`
   - Action: `plan`
   - Region: `nyc1`
   - Domain Name: (leave empty)

### Step 3: Deploy Infrastructure
1. Review the plan output
2. Run workflow again with Action: `apply`
3. Monitor the deployment progress

## 📋 Workflow Parameters

| Parameter | Description | Options | Default |
|-----------|-------------|---------|---------|
| `environment` | Target environment | dev, staging, prod | dev |
| `action` | Terraform action | plan, apply, destroy | plan |
| `region` | DigitalOcean region | nyc1, sfo3, ams3, etc. | nyc1 |
| `domain_name` | Custom domain (optional) | Any valid domain | "" |

## 🌍 Supported Regions

- **US East**: `nyc1`, `nyc3`
- **US West**: `sfo2`, `sfo3`
- **Europe**: `ams2`, `ams3`, `fra1`, `lon1`
- **Asia**: `sgp1`
- **Canada**: `tor1`

## 🔒 Security Features

1. **Secret Management**
   - API tokens stored in GitHub secrets
   - No hardcoded credentials

2. **Vulnerability Scanning**
   - Trivy scanner integration
   - SARIF output for GitHub Security tab

3. **Network Security**
   - Firewall rules for access control
   - HTTPS-only production traffic

4. **Environment Isolation**
   - Separate configurations per environment
   - Production-specific security measures

## 💰 Cost Optimization

### Development Environment
- **Estimated Cost**: $5-10/month
- **Resources**: 1 instance, basic sizing
- **Features**: Basic monitoring only

### Staging Environment
- **Estimated Cost**: $20-40/month
- **Resources**: 2 instances, standard sizing
- **Features**: Full monitoring, optional domain

### Production Environment
- **Estimated Cost**: $50-200/month
- **Resources**: 2+ instances, premium sizing
- **Features**: Full monitoring, custom domain, database, load balancer

## 🚨 Best Practices

### 1. Always Plan First
```bash
# Run plan before apply
gh workflow run terraform-digitalocean.yml -f action=plan -f environment=prod
# Review output, then apply
gh workflow run terraform-digitalocean.yml -f action=apply -f environment=prod
```

### 2. Use Environment-Specific Configurations
- Development: Minimal resources for cost savings
- Staging: Medium resources for testing
- Production: High availability with monitoring

### 3. Monitor and Alert
- Set up DigitalOcean billing alerts
- Monitor resource usage
- Review security scan results

### 4. Backup and Recovery
- Use managed database backups
- Consider cross-region replication
- Document recovery procedures

## 🔧 Customization

### Adding New Environments
1. Update the workflow parameters
2. Modify Terraform variables
3. Add environment-specific configurations

### Adding New Resources
1. Update `terraform/digitalocean.tf`
2. Add new variables if needed
3. Test with plan action first

### Customizing Monitoring
1. Modify alert thresholds
2. Add custom metrics
3. Configure notification channels

## 🐛 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify `DIGITALOCEAN_TOKEN` secret
   - Check token permissions

2. **Resource Limits**
   - Check DigitalOcean account limits
   - Verify sufficient credits

3. **Region Issues**
   - Ensure region is available
   - Check resource availability

4. **Terraform Errors**
   - Review workflow logs
   - Validate Terraform configuration
   - Check variable values

### Getting Help

1. Check workflow logs in GitHub Actions
2. Review Terraform documentation
3. Consult DigitalOcean support
4. Open an issue in the repository

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Documentation](https://www.terraform.io/docs)
- [DigitalOcean API Documentation](https://docs.digitalocean.com/reference/api/)
- [DigitalOcean App Platform](https://docs.digitalocean.com/products/app-platform/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with plan action
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.