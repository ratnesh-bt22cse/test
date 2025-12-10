#!/bin/bash

# Stop all microservice containers
# Usage: ./stop-all.sh

echo "Stopping all microservice containers..."

docker stop api-gateway frontend task-service user-service mongodb 2>/dev/null || true
docker rm api-gateway frontend task-service user-service mongodb 2>/dev/null || true

echo "All containers stopped."
docker ps
