# GitHub Actions Workflow Examples

This document provides examples of how to use the Terraform DigitalOcean Infrastructure workflow for different scenarios.

## Basic Usage Examples

### 1. Development Environment Setup

**Scenario**: Setting up a development environment for testing

**Parameters**:
- Environment: `dev`
- Action: `plan`
- Region: `nyc1`
- Domain Name: (empty)

**Command**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=dev \
  -f action=plan \
  -f region=nyc1 \
  -f domain_name=""
```

**What it does**:
- Creates a Terraform plan for development infrastructure
- Uses minimal resources (1 instance, basic sizing)
- No custom domain or production features

### 2. Production Environment Deployment

**Scenario**: Deploying to production with custom domain

**Parameters**:
- Environment: `prod`
- Action: `apply`
- Region: `sfo3`
- Domain Name: `myapp.example.com`

**Command**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=prod \
  -f action=apply \
  -f region=sfo3 \
  -f domain_name="myapp.example.com"
```

**What it does**:
- Deploys production infrastructure with high availability
- Sets up custom domain and SSL certificates
- Enables monitoring and alerting
- Creates database cluster and load balancer

### 3. Staging Environment Update

**Scenario**: Updating staging environment with new configuration

**Parameters**:
- Environment: `staging`
- Action: `plan`
- Region: `ams3`
- Domain Name: (empty)

**Command**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=staging \
  -f action=plan \
  -f region=ams3 \
  -f domain_name=""
```

**What it does**:
- Shows what changes will be made to staging
- Allows review before applying
- Uses medium-sized resources

### 4. Infrastructure Cleanup

**Scenario**: Removing all infrastructure (use with caution!)

**Parameters**:
- Environment: `dev`
- Action: `destroy`
- Region: `nyc1`
- Domain Name: (empty)

**Command**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=dev \
  -f action=destroy \
  -f region=nyc1 \
  -f domain_name=""
```

**What it does**:
- Removes all DigitalOcean resources
- Deletes containers, databases, and storage
- **Warning**: This action cannot be undone!

## Advanced Usage Examples

### 5. Multi-Region Deployment

**Scenario**: Deploying to multiple regions for global availability

**Primary Region (US)**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=prod \
  -f action=apply \
  -f region=sfo3 \
  -f domain_name="us.myapp.example.com"
```

**Secondary Region (Europe)**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=prod \
  -f action=apply \
  -f region=ams3 \
  -f domain_name="eu.myapp.example.com"
```

### 6. Blue-Green Deployment

**Scenario**: Zero-downtime deployment strategy

**Step 1: Deploy to Green Environment**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=green \
  -f action=apply \
  -f region=nyc1 \
  -f domain_name="green.myapp.example.com"
```

**Step 2: Test Green Environment**:
- Verify the new deployment works correctly
- Run integration tests

**Step 3: Switch Traffic**:
- Update DNS to point to green environment
- Monitor for any issues

**Step 4: Cleanup Blue Environment**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=blue \
  -f action=destroy \
  -f region=nyc1 \
  -f domain_name=""
```

### 7. Disaster Recovery Setup

**Scenario**: Setting up backup infrastructure in different region

**Primary Infrastructure**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=prod \
  -f action=apply \
  -f region=sfo3 \
  -f domain_name="myapp.example.com"
```

**Disaster Recovery Infrastructure**:
```bash
gh workflow run terraform-digitalocean.yml \
  -f environment=dr \
  -f action=apply \
  -f region=lon1 \
  -f domain_name="dr.myapp.example.com"
```

## Environment-Specific Configurations

### Development Environment
- **Resources**: Minimal (1 instance, basic sizing)
- **Features**: Basic monitoring, no custom domain
- **Cost**: ~$5-10/month
- **Use Case**: Development and testing

### Staging Environment
- **Resources**: Medium (2 instances, standard sizing)
- **Features**: Full monitoring, optional custom domain
- **Cost**: ~$20-40/month
- **Use Case**: Pre-production testing

### Production Environment
- **Resources**: High availability (2+ instances, premium sizing)
- **Features**: Full monitoring, custom domain, SSL, database cluster
- **Cost**: ~$50-200/month
- **Use Case**: Live production workloads

## Best Practices

### 1. Always Plan First
```bash
# Always run plan before apply
gh workflow run terraform-digitalocean.yml -f action=plan -f environment=prod
# Review the plan output
# Then run apply
gh workflow run terraform-digitalocean.yml -f action=apply -f environment=prod
```

### 2. Use Descriptive Environment Names
```bash
# Good: Clear environment names
gh workflow run terraform-digitalocean.yml -f environment=prod-us-east
gh workflow run terraform-digitalocean.yml -f environment=staging-eu

# Avoid: Generic names
gh workflow run terraform-digitalocean.yml -f environment=env1
```

### 3. Monitor Costs
- Set up billing alerts in DigitalOcean
- Use appropriate instance sizes for each environment
- Clean up unused resources regularly

### 4. Security Considerations
- Use different API tokens for different environments
- Enable security scanning in the workflow
- Review Terraform plans for security implications

## Troubleshooting Examples

### Common Issues and Solutions

**1. Authentication Error**:
```
Error: DigitalOcean API token is invalid
```
**Solution**: Verify your `DIGITALOCEAN_TOKEN` secret is correctly set

**2. Resource Limit Exceeded**:
```
Error: Droplet limit exceeded
```
**Solution**: Check your DigitalOcean account limits or upgrade your plan

**3. Region Unavailable**:
```
Error: Region not available
```
**Solution**: Choose a different DigitalOcean region from the supported list

**4. Domain Already Exists**:
```
Error: Domain already exists
```
**Solution**: Use a unique domain name or remove the existing domain first

## Integration Examples

### With CI/CD Pipeline
```yaml
# In your main CI/CD workflow
- name: Deploy to Staging
  run: |
    gh workflow run terraform-digitalocean.yml \
      -f environment=staging \
      -f action=apply \
      -f region=nyc1
  if: github.ref == 'refs/heads/develop'

- name: Deploy to Production
  run: |
    gh workflow run terraform-digitalocean.yml \
      -f environment=prod \
      -f action=apply \
      -f region=sfo3 \
      -f domain_name="myapp.example.com"
  if: github.ref == 'refs/heads/main'
```

### With Slack Notifications
```yaml
# Add to your workflow
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: '#deployments'
    text: 'Terraform deployment ${{ github.event.inputs.action }} to ${{ github.event.inputs.environment }}'
  if: always()
```

### With Jira Integration
```yaml
# Add to your workflow
- name: Update Jira
  uses: atlassian/gajira-transition@v3
  with:
    issue: ${{ github.event.inputs.jira_issue }}
    transition: 'Deploy'
  if: success()
```