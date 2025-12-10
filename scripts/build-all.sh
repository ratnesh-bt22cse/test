#!/bin/bash

# Build all microservice Docker images
# Usage: ./build-all.sh

set -e

echo "========================================"
echo "Building Microservices Docker Images"
echo "========================================"

# Set your Docker Hub username or registry
REGISTRY=${DOCKER_REGISTRY:-""}
TAG=${TAG:-"latest"}

# Build User Service
echo ""
echo "Building user-service..."
docker build -t ${REGISTRY}user-service:${TAG} ./user-service

# Build Task Service
echo ""
echo "Building task-service..."
docker build -t ${REGISTRY}task-service:${TAG} ./task-service

# Build API Gateway
echo ""
echo "Building api-gateway..."
docker build -t ${REGISTRY}api-gateway:${TAG} ./api-gateway

# Build Frontend
echo ""
echo "Building frontend..."
docker build -t ${REGISTRY}frontend:${TAG} ./frontend

echo ""
echo "========================================"
echo "All images built successfully!"
echo "========================================"
docker images | grep -E "user-service|task-service|api-gateway|frontend"
