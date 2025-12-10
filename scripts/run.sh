#!/bin/bash

# Run all microservices as separate Docker containers
# Usage: ./run.sh [EXTERNAL_IP]

EXTERNAL_IP=${1:-localhost}

echo "========================================"
echo "Starting Microservices"
echo "External IP: $EXTERNAL_IP"
echo "========================================"

# Create Docker network if not exists
docker network create microservices-net 2>/dev/null || true

# Stop existing containers
echo ""
echo "🛑 Stopping existing containers..."
docker stop mongodb user-service task-service frontend api-gateway 2>/dev/null || true
docker rm mongodb user-service task-service frontend api-gateway 2>/dev/null || true

# Start MongoDB
echo ""
echo "🍃 Starting MongoDB..."
docker run -d \
  --name mongodb \
  --network microservices-net \
  -p 27017:27017 \
  -v mongodb-data:/data/db \
  mongo:6

sleep 5

# Start User Service
echo ""
echo "👤 Starting user-service on port 3001..."
docker run -d \
  --name user-service \
  --network microservices-net \
  -p 3001:3001 \
  -e PORT=3001 \
  -e MONGODB_URI=mongodb://mongodb:27017/userdb \
  -e JWT_SECRET=your-super-secret-key \
  user-service:latest

# Start Task Service
echo ""
echo "📋 Starting task-service on port 3002..."
docker run -d \
  --name task-service \
  --network microservices-net \
  -p 3002:3002 \
  -e PORT=3002 \
  -e MONGODB_URI=mongodb://mongodb:27017/taskdb \
  task-service:latest

# Start Frontend
echo ""
echo "🌐 Starting frontend on port 3000..."
docker run -d \
  --name frontend \
  --network microservices-net \
  -p 3000:80 \
  frontend:latest

# Start API Gateway
echo ""
echo "🚪 Starting api-gateway on port 80..."
docker run -d \
  --name api-gateway \
  --network microservices-net \
  -p 80:80 \
  api-gateway:latest

echo ""
echo "========================================"
echo "✅ All services started!"
echo "========================================"
echo ""
echo "Services running:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Access your app at:"
echo "  🌐 App (via Gateway): http://$EXTERNAL_IP"
echo "  👤 User API:          http://$EXTERNAL_IP/api/users"
echo "  📋 Task API:          http://$EXTERNAL_IP/api/tasks"
echo "  ❤️  Health:            http://$EXTERNAL_IP/health"
echo ""
echo "Direct service access:"
echo "  User Service: http://$EXTERNAL_IP:3001/health"
echo "  Task Service: http://$EXTERNAL_IP:3002/health"
echo "  Frontend:     http://$EXTERNAL_IP:3000"
echo "========================================"
