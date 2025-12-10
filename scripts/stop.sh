#!/bin/bash

# Stop all microservices containers

echo "========================================"
echo "Stopping Microservices"
echo "========================================"

docker stop api-gateway frontend task-service user-service mongodb 2>/dev/null
docker rm api-gateway frontend task-service user-service mongodb 2>/dev/null

echo ""
echo "✅ All containers stopped and removed"
echo ""
docker ps
