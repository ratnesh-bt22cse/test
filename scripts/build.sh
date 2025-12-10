#!/bin/bash

# Build all microservices Docker images

echo "========================================"
echo "Building Microservices Docker Images"
echo "========================================"

# Build User Service
echo ""
echo "📦 Building user-service..."
docker build -t user-service:latest ./user-service

# Build Task Service
echo ""
echo "📦 Building task-service..."
docker build -t task-service:latest ./task-service

# Build Frontend
echo ""
echo "📦 Building frontend..."
docker build -t frontend:latest ./frontend

# Build API Gateway
echo ""
echo "📦 Building api-gateway..."
docker build -t api-gateway:latest ./api-gateway

echo ""
echo "========================================"
echo "✅ All images built successfully!"
echo "========================================"
echo ""
echo "Images created:"
docker images | grep -E "user-service|task-service|frontend|api-gateway"
