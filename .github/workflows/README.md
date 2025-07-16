# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated infrastructure deployment and management.

## Terraform DigitalOcean Infrastructure Workflow

The `terraform-digitalocean.yml` workflow provides manual deployment of infrastructure to DigitalOcean using Terraform.

### Features

- **Manual Trigger**: Workflow can be triggered manually with customizable parameters
- **Multiple Environments**: Support for dev, staging, and production environments
- **Multiple Regions**: Support for all major DigitalOcean regions
- **Security Scanning**: Integrated Trivy vulnerability scanning
- **Plan Review**: Terraform plans are uploaded as artifacts and commented on issues
- **Comprehensive Logging**: Detailed logging and notification system

### Prerequisites

1. **DigitalOcean API Token**: You need a DigitalOcean API token with appropriate permissions
2. **GitHub Secrets**: Configure the following secrets in your GitHub repository:
   - `DIGITALOCEAN_TOKEN`: Your DigitalOcean API token

### Setup Instructions

1. **Create DigitalOcean API Token**:
   - Go to [DigitalOcean API Tokens](https://cloud.digitalocean.com/account/api/tokens)
   - Click "Generate New Token"
   - Give it a name (e.g., "GitHub Actions Terraform")
   - Select "Write" scope
   - Copy the token

2. **Add GitHub Secret**:
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `DIGITALOCEAN_TOKEN`
   - Value: Paste your DigitalOcean API token

### Usage

1. **Trigger the Workflow**:
   - Go to the "Actions" tab in your GitHub repository
   - Select "Terraform DigitalOcean Infrastructure"
   - Click "Run workflow"

2. **Configure Parameters**:
   - **Environment**: Choose dev, staging, or prod
   - **Action**: Choose plan, apply, or destroy
   - **Region**: Select your preferred DigitalOcean region
   - **Domain Name**: (Optional) Enter your domain for production

3. **Workflow Actions**:
   - **Plan**: Creates a Terraform plan without applying changes
   - **Apply**: Applies the Terraform configuration to create/update infrastructure
   - **Destroy**: Removes all infrastructure (use with caution)

### Workflow Steps

1. **Checkout**: Downloads the repository code
2. **Setup Terraform**: Installs Terraform with the specified version
3. **Format Check**: Validates Terraform code formatting
4. **Init**: Initializes Terraform working directory
5. **Validate**: Validates Terraform configuration
6. **Plan**: Creates execution plan (for plan/apply actions)
7. **Apply/Destroy**: Executes Terraform commands
8. **Security Scan**: Runs Trivy vulnerability scanner
9. **Notify**: Provides status notifications

### Security Features

- **Secret Management**: Uses GitHub secrets for sensitive data
- **Vulnerability Scanning**: Integrated Trivy scanner for security issues
- **Plan Review**: Plans are saved as artifacts for review
- **Environment Isolation**: Separate configurations for different environments

### Supported DigitalOcean Regions

- `nyc1` - New York 1
- `nyc3` - New York 3
- `sfo2` - San Francisco 2
- `sfo3` - San Francisco 3
- `ams2` - Amsterdam 2
- `ams3` - Amsterdam 3
- `fra1` - Frankfurt 1
- `lon1` - London 1
- `sgp1` - Singapore 1
- `tor1` - Toronto 1

### Infrastructure Components

The workflow deploys the following DigitalOcean resources:

- **Container Registry**: For storing Docker images
- **App Platform**: For running containerized applications
- **Database Cluster**: PostgreSQL database (production only)
- **Load Balancer**: For traffic distribution (production only)
- **Firewall**: Security rules for network access
- **Spaces Bucket**: Object storage for logs
- **Monitoring**: CPU and memory alerts
- **Domain & DNS**: Custom domain configuration (production only)

### Troubleshooting

1. **Authentication Errors**:
   - Verify your `DIGITALOCEAN_TOKEN` secret is correctly set
   - Ensure the token has "Write" permissions

2. **Terraform Errors**:
   - Check the workflow logs for detailed error messages
   - Verify your Terraform configuration files are valid
   - Ensure all required variables are provided

3. **Resource Limits**:
   - Check your DigitalOcean account limits
   - Verify you have sufficient credits/balance

### Best Practices

1. **Always Plan First**: Run a plan before applying changes
2. **Use Separate Environments**: Keep dev, staging, and prod isolated
3. **Review Changes**: Always review Terraform plans before applying
4. **Monitor Costs**: Keep track of DigitalOcean resource usage
5. **Backup State**: Consider using remote state storage for production

### Cost Optimization

- Use appropriate instance sizes for each environment
- Enable auto-scaling for production workloads
- Set up monitoring alerts for resource usage
- Regularly review and clean up unused resources

### Support

For issues or questions:
1. Check the workflow logs for error details
2. Review the Terraform configuration files
3. Consult the DigitalOcean documentation
4. Open an issue in the repository