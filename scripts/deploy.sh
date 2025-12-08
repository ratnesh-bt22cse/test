#!/bin/bash

# Deploy MERN CRUD App to GCP E2 Instance
# Run this script from the project root directory on your GCP VM

set -e

# Get the external IP of this VM
EXTERNAL_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google" 2>/dev/null || echo "localhost")

echo "========================================"
echo "Deploying MERN CRUD App"
echo "External IP: $EXTERNAL_IP"
echo "========================================"

# Update the API URL in docker-compose.prod.yml
if [ "$EXTERNAL_IP" != "localhost" ]; then
    echo "Updating API URL with external IP: $EXTERNAL_IP"
    sed -i "s|YOUR_GCP_VM_IP|$EXTERNAL_IP|g" docker-compose.prod.yml
fi

# Stop existing containers if any
echo "Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Build and start containers
echo "Building and starting containers..."
docker-compose -f docker-compose.prod.yml up -d --build

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check if services are running
echo ""
echo "========================================"
echo "Checking service status..."
echo "========================================"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Your MERN CRUD App is now running at:"
echo "  Frontend: http://$EXTERNAL_IP"
echo "  Backend API: http://$EXTERNAL_IP:5000"
echo "  Health Check: http://$EXTERNAL_IP:5000/health"
echo ""
echo "Make sure your GCP firewall rules allow:"
echo "  - HTTP traffic (port 80)"
echo "  - Custom TCP (port 5000)"
echo "========================================"
