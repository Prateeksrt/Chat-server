# TypeScript REST API

A modern, production-ready REST API built with TypeScript, Express.js, and Docker. This project provides a solid foundation for building scalable web services with comprehensive testing, validation, and security features.

## 🚀 Features

- **TypeScript**: Full type safety and modern JavaScript features
- **Express.js**: Fast, unopinionated web framework
- **Docker**: Containerized deployment with multi-stage builds
- **Security**: Helmet, CORS, rate limiting, and input validation
- **Testing**: Jest with supertest for comprehensive API testing
- **Code Quality**: ESLint with TypeScript support
- **API Documentation**: OpenAPI/Swagger-style documentation
- **Health Checks**: Docker health checks and monitoring endpoints
- **Error Handling**: Centralized error handling with proper HTTP status codes

## 📋 Prerequisites

- Node.js 18+ 
- Docker and Docker Compose
- npm or yarn

## 🛠️ Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd typescript-rest-api
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create environment file**
   ```bash
   cp .env.example .env
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

The API will be available at `http://localhost:3000`

### Docker Development

1. **Build and run with Docker Compose**
   ```bash
   docker-compose --profile dev up --build
   ```

2. **Or run individual containers**
   ```bash
   # Build the image
   docker build -f Dockerfile.dev -t typescript-api-dev .
   
   # Run the container
   docker run -p 3001:3000 -v $(pwd)/src:/app/src typescript-api-dev
   ```

## 🐳 Production Deployment

### Docker Production

```bash
# Build production image
docker build -t typescript-api-prod .

# Run production container
docker run -p 3000:3000 -e NODE_ENV=production typescript-api-prod
```

### Docker Compose Production

```bash
docker-compose up --build
```

## ☁️ Cloud Deployment with Terraform

This project includes comprehensive Terraform configurations for deploying to multiple cloud providers (AWS, Azure, GCP).

### Quick Deploy

```bash
# Deploy to AWS dev environment
cd terraform
./deploy.sh -e dev -p aws -b

# Deploy to Azure staging environment
./deploy.sh -e staging -p azure -b

# Deploy to GCP production environment
./deploy.sh -e prod -p gcp -b
```

### Supported Cloud Providers

- **AWS**: ECS Fargate with Application Load Balancer
- **Azure**: Container Instances with Load Balancer  
- **GCP**: Cloud Run with Global Load Balancer

### Prerequisites

1. **Terraform** (>= 1.0)
2. **Docker** (for building images)
3. **Cloud CLI tools**:
   - AWS CLI (for AWS)
   - Azure CLI (for Azure)
   - Google Cloud SDK (for GCP)

### Manual Deployment

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars
```

For detailed instructions, see the [Terraform README](terraform/README.md).

## 📚 API Documentation

### Base URL
- Development: `http://localhost:3000`
- Production: `https://your-domain.com`

### Endpoints

#### Health Check
```http
GET /health
```

#### API Information
```http
GET /api/v1
```

#### API Documentation
```http
GET /api/v1/docs
```

#### Users API

**Get all users**
```http
GET /api/v1/users
```

**Get user by ID**
```http
GET /api/v1/users/{id}
```

**Create user**
```http
POST /api/v1/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}
```

**Update user**
```http
PUT /api/v1/users/{id}
Content-Type: application/json

{
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

**Delete user**
```http
DELETE /api/v1/users/{id}
```

### Response Format

All API responses follow a consistent format:

```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

Error responses:
```json
{
  "success": false,
  "error": "Error message",
  "details": ["Validation errors"]
}
```

## 🧪 Testing

### Run all tests
```bash
npm test
```

### Run tests in watch mode
```bash
npm run test:watch
```

### Run tests with coverage
```bash
npm test -- --coverage
```

## 🔧 Development Scripts

```bash
# Development
npm run dev          # Start development server with hot reload
npm run build        # Build for production
npm run start        # Start production server

# Testing
npm test             # Run tests
npm run test:watch   # Run tests in watch mode

# Code Quality
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint errors

# Utilities
npm run clean        # Clean build directory
```

## 🌐 Deployment Options

### Google Cloud Platform (GCP)

1. **Cloud Run** (Recommended)
   ```bash
   # Build and push to Google Container Registry
   gcloud builds submit --tag gcr.io/PROJECT-ID/typescript-api
   
   # Deploy to Cloud Run
   gcloud run deploy typescript-api \
     --image gcr.io/PROJECT-ID/typescript-api \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

2. **Google Kubernetes Engine (GKE)**
   ```bash
   # Apply Kubernetes manifests
   kubectl apply -f k8s/
   ```

### AWS

1. **Amazon ECS**
   ```bash
   # Build and push to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
   docker tag typescript-api:latest ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/typescript-api:latest
   docker push ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/typescript-api:latest
   ```

2. **AWS App Runner**
   - Connect your GitHub repository
   - Configure build settings
   - Deploy automatically

### Azure

1. **Azure Container Instances**
   ```bash
   # Deploy to ACI
   az container create \
     --resource-group myResourceGroup \
     --name typescript-api \
     --image typescript-api:latest \
     --ports 3000
   ```

## 🔒 Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing configuration
- **Rate Limiting**: Protection against brute force attacks
- **Input Validation**: Request validation using express-validator
- **Error Handling**: Secure error responses (no stack traces in production)

## 📁 Project Structure

```
src/
├── controllers/          # Business logic controllers
├── middleware/           # Custom middleware
├── routes/              # API route definitions
├── types/               # TypeScript type definitions
├── test/                # Test setup and utilities
├── health.ts            # Health check logic
└── index.ts             # Application entry point
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
NODE_ENV=development
PORT=3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

### Docker Environment

For Docker deployments, set environment variables in your deployment configuration or use Docker secrets for sensitive data.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the API documentation at `/api/v1/docs`
- Review the health check endpoint at `/health`

## 🔄 Roadmap

- [ ] Database integration (PostgreSQL/MongoDB)
- [ ] Authentication & Authorization
- [ ] API versioning
- [ ] Caching layer (Redis)
- [ ] Monitoring & logging (Prometheus, ELK)
- [ ] CI/CD pipelines
- [ ] OpenAPI/Swagger UI
- [ ] GraphQL support