.PHONY: help install build start dev test test-watch lint lint-fix clean docker-build docker-run docker-dev docker-compose-up docker-compose-down

# Default target
help:
	@echo "Available commands:"
	@echo "  install        - Install dependencies"
	@echo "  build          - Build for production"
	@echo "  start          - Start production server"
	@echo "  dev            - Start development server"
	@echo "  test           - Run tests"
	@echo "  test-watch     - Run tests in watch mode"
	@echo "  lint           - Run ESLint"
	@echo "  lint-fix       - Fix ESLint errors"
	@echo "  clean          - Clean build directory"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-run     - Run Docker container"
	@echo "  docker-dev     - Run Docker development container"
	@echo "  docker-compose-up    - Start with Docker Compose"
	@echo "  docker-compose-down  - Stop Docker Compose"

# Development commands
install:
	npm install

build:
	npm run build

start:
	npm start

dev:
	npm run dev

test:
	npm test

test-watch:
	npm run test:watch

lint:
	npm run lint

lint-fix:
	npm run lint:fix

clean:
	npm run clean

# Docker commands
docker-build:
	docker build -t typescript-api .

docker-run:
	docker run -p 3000:3000 typescript-api

docker-dev:
	docker build -f Dockerfile.dev -t typescript-api-dev .
	docker run -p 3001:3000 -v $(PWD)/src:/app/src typescript-api-dev

docker-compose-up:
	docker-compose up --build

docker-compose-down:
	docker-compose down

# Production deployment helpers
deploy-gcp:
	@echo "Deploying to Google Cloud Platform..."
	gcloud builds submit --tag gcr.io/$(PROJECT_ID)/typescript-api
	gcloud run deploy typescript-api \
		--image gcr.io/$(PROJECT_ID)/typescript-api \
		--platform managed \
		--region us-central1 \
		--allow-unauthenticated

deploy-aws:
	@echo "Deploying to AWS ECS..."
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(AWS_ACCOUNT).dkr.ecr.us-east-1.amazonaws.com
	docker tag typescript-api:latest $(AWS_ACCOUNT).dkr.ecr.us-east-1.amazonaws.com/typescript-api:latest
	docker push $(AWS_ACCOUNT).dkr.ecr.us-east-1.amazonaws.com/typescript-api:latest