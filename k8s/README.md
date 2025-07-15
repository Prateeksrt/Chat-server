# Kubernetes Deployment for TypeScript REST API

This directory contains all the Kubernetes manifests and scripts needed to deploy your TypeScript REST API to a Kubernetes cluster.

## 📁 File Structure

```
k8s/
├── namespace.yaml          # Kubernetes namespace
├── configmap.yaml          # Configuration variables
├── secret.yaml            # Sensitive environment variables
├── deployment.yaml        # Main application deployment
├── hpa.yaml              # Horizontal Pod Autoscaler
├── ingress.yaml          # Ingress for external access
├── kustomization.yaml    # Kustomize configuration
├── deploy.sh             # Deployment script
├── cleanup.sh            # Cleanup script
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes Cluster**: You need access to a Kubernetes cluster (local or cloud)
2. **kubectl**: Kubernetes command-line tool
3. **Docker**: For building and pushing images (if using `--build` flag)

### Deployment Options

#### Option 1: Using the deployment script (Recommended)

```bash
# Deploy without building new image
./k8s/deploy.sh

# Deploy with building new Docker image
./k8s/deploy.sh --build

# Deploy with custom Docker registry
export DOCKER_REGISTRY="your-registry.com"
./k8s/deploy.sh --build
```

#### Option 2: Using kubectl directly

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply all resources
kubectl apply -k k8s/

# Or apply individually
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

## 🔧 Configuration

### Environment Variables

The application uses two types of configuration:

1. **ConfigMap** (`configmap.yaml`): Non-sensitive configuration
   - `NODE_ENV`: Environment (production)
   - `PORT`: Application port (3000)
   - `API_VERSION`: API version
   - `LOG_LEVEL`: Logging level

2. **Secret** (`secret.yaml`): Sensitive configuration
   - `JWT_SECRET`: JWT signing secret
   - `DATABASE_URL`: Database connection string
   - `API_KEY`: API authentication key

### Updating Secrets

To update secrets, encode your values in base64:

```bash
echo -n "your-secret-value" | base64
```

Then update the `secret.yaml` file with the encoded values.

### Customizing the Deployment

#### Image Configuration

Update the image name and tag in `kustomization.yaml`:

```yaml
images:
- name: typescript-api
  newName: your-registry.com/typescript-api  # Optional
  newTag: v1.0.0
```

#### Resource Limits

Adjust CPU and memory limits in `deployment.yaml`:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

#### Scaling Configuration

Modify the HPA settings in `hpa.yaml`:

```yaml
minReplicas: 2
maxReplicas: 10
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 70
```

## 🌐 Accessing Your API

### LoadBalancer Service

If your cluster supports LoadBalancer services:

```bash
kubectl get svc typescript-api-service -n typescript-api
```

Look for the `EXTERNAL-IP` column.

### Ingress

1. Update the host in `ingress.yaml`:
   ```yaml
   - host: api.yourdomain.com  # Replace with your domain
   ```

2. Apply the ingress:
   ```bash
   kubectl apply -f k8s/ingress.yaml
   ```

3. Configure your DNS to point to the ingress controller's IP.

### Port Forwarding (Local Development)

```bash
kubectl port-forward svc/typescript-api-service 8080:80 -n typescript-api
```

Then access your API at `http://localhost:8080`

## 📊 Monitoring and Health Checks

The deployment includes:

- **Health Endpoint**: `/health` for liveness and readiness probes
- **Resource Monitoring**: CPU and memory usage tracking
- **Auto-scaling**: Automatic scaling based on resource usage

### Checking Application Status

```bash
# Check pod status
kubectl get pods -n typescript-api

# Check service status
kubectl get svc -n typescript-api

# Check HPA status
kubectl get hpa -n typescript-api

# View logs
kubectl logs -f deployment/typescript-api -n typescript-api

# Check events
kubectl get events -n typescript-api --sort-by='.lastTimestamp'
```

## 🧹 Cleanup

To remove all resources:

```bash
./k8s/cleanup.sh
```

Or manually:

```bash
kubectl delete namespace typescript-api
```

## 🔒 Security Considerations

1. **Secrets Management**: Use Kubernetes secrets for sensitive data
2. **Network Policies**: Consider implementing network policies for pod-to-pod communication
3. **RBAC**: Set up proper role-based access control
4. **TLS**: Enable TLS for production deployments
5. **Image Security**: Use signed images and scan for vulnerabilities

## 🚨 Troubleshooting

### Common Issues

1. **Image Pull Errors**: Ensure your image is accessible from the cluster
2. **Health Check Failures**: Verify the `/health` endpoint is working
3. **Resource Constraints**: Check if pods are being evicted due to resource limits
4. **Service Connectivity**: Verify service selectors match pod labels

### Debugging Commands

```bash
# Describe resources for detailed information
kubectl describe pod <pod-name> -n typescript-api
kubectl describe svc typescript-api-service -n typescript-api

# Check pod logs
kubectl logs <pod-name> -n typescript-api

# Execute commands in running pods
kubectl exec -it <pod-name> -n typescript-api -- /bin/sh

# Check resource usage
kubectl top pods -n typescript-api
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)