#!/bin/bash

# Kubernetes cleanup script for TypeScript REST API
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="typescript-api"

echo -e "${YELLOW}🧹 Starting cleanup of TypeScript REST API from Kubernetes...${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed.${NC}"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo -e "${YELLOW}⚠️  Namespace ${NAMESPACE} does not exist. Nothing to clean up.${NC}"
    exit 0
fi

# Delete all resources in the namespace
echo -e "${YELLOW}🗑️  Deleting all resources in namespace ${NAMESPACE}...${NC}"
kubectl delete namespace ${NAMESPACE}

echo -e "${GREEN}✅ Cleanup completed successfully!${NC}"
echo -e "${YELLOW}💡 All resources in namespace ${NAMESPACE} have been removed.${NC}"