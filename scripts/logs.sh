#!/bin/bash

# View logs for all services
# Usage: ./logs.sh [service-name]

SERVICE=${1:-"all"}

if [ "$SERVICE" == "all" ]; then
  echo "=== MongoDB ===" && docker logs mongodb --tail 20
  echo ""
  echo "=== User Service ===" && docker logs user-service --tail 20
  echo ""
  echo "=== Task Service ===" && docker logs task-service --tail 20
  echo ""
  echo "=== Frontend ===" && docker logs frontend --tail 20
  echo ""
  echo "=== API Gateway ===" && docker logs api-gateway --tail 20
else
  docker logs $SERVICE -f
fi
