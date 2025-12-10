#!/bin/bash

# Run all microservices using individual Docker commands (NO docker-compose)
# Usage: ./run-all.sh [EXTERNAL_IP]

set -e

EXTERNAL_IP=${1:-"localhost"}
MONGODB_URI=${MONGODB_URI:-"mongodb://host.docker.internal:27017"}

echo "========================================"
echo "Starting Microservices"
echo "External IP: $EXTERNAL_IP"
echo "========================================"

# Create Docker network if not exists
docker network create microservices-net 2>/dev/null || true

# Stop existing containers
echo "Stopping existing containers..."
docker stop mongodb user-service task-service api-gateway frontend 2>/dev/null || true
docker rm mongodb user-service task-service api-gateway frontend 2>/dev/null || true

# 1. Start MongoDB
echo ""
echo "Starting MongoDB..."
docker run -d \
  --name mongodb \
  --network microservices-net \
  -p 27017:27017 \
  -v mongodb-data:/data/db \
  mongo:6

sleep 5

# 2. Start User Service
echo ""
echo "Starting User Service (Port 3001)..."
docker run -d \
  --name user-service \
  --network microservices-net \
  -p 3001:3001 \
  -e PORT=3001 \
  -e MONGODB_URI=mongodb://mongodb:27017/userdb \
  -e JWT_SECRET=your-secret-key-change-in-production \
  user-service:latest

# 3. Start Task Service
echo ""
echo "Starting Task Service (Port 3002)..."
docker run -d \
  --name task-service \
  --network microservices-net \
  -p 3002:3002 \
  -e PORT=3002 \
  -e MONGODB_URI=mongodb://mongodb:27017/taskdb \
  task-service:latest

# 4. Start Frontend
echo ""
echo "Starting Frontend (Port 3000)..."
docker run -d \
  --name frontend \
  --network microservices-net \
  -p 3000:3000 \
  frontend:latest

# 5. Start API Gateway
echo ""
echo "Starting API Gateway (Port 80)..."

# Update nginx config with service hosts
docker run -d \
  --name api-gateway \
  --network microservices-net \
  -p 80:80 \
  -e USER_SERVICE_HOST=user-service \
  -e TASK_SERVICE_HOST=task-service \
  -e FRONTEND_HOST=frontend \
  api-gateway:latest

sleep 3

echo ""
echo "========================================"
echo "All Services Started!"
echo "========================================"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "Access your app:"
echo "  Frontend:      http://$EXTERNAL_IP"
echo "  User Service:  http://$EXTERNAL_IP:3001/health"
echo "  Task Service:  http://$EXTERNAL_IP:3002/health"
echo "  API Gateway:   http://$EXTERNAL_IP/health"
echo "========================================"
