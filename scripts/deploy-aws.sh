#!/bin/bash

# Deploy MERN CRUD App to AWS EC2 Instance
# Ports: Frontend=3003, Backend=3004, MongoDB=27017

set -e

echo "========================================"
echo "Deploying MERN CRUD App on AWS EC2"
echo "========================================"

# Get the public IP (AWS metadata)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

echo "Public IP: $PUBLIC_IP"

# Update the API URL in docker-compose.aws.yml
if [ "$PUBLIC_IP" != "localhost" ]; then
    echo "Updating API URL with public IP: $PUBLIC_IP"
    sed -i "s|YOUR_AWS_EC2_IP|$PUBLIC_IP|g" docker-compose.aws.yml
fi

# Stop existing containers if any
echo "Stopping existing containers..."
docker-compose -f docker-compose.aws.yml down 2>/dev/null || true

# Build and start containers
echo "Building and starting containers..."
docker-compose -f docker-compose.aws.yml up -d --build

# Wait for services to start
echo "Waiting for services to start..."
sleep 15

# Check if services are running
echo ""
echo "========================================"
echo "Checking service status..."
echo "========================================"
docker-compose -f docker-compose.aws.yml ps

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Your MERN CRUD App is now running at:"
echo "  Frontend:     http://$PUBLIC_IP:3003"
echo "  Backend API:  http://$PUBLIC_IP:3004"
echo "  Health Check: http://$PUBLIC_IP:3004/health"
echo ""
echo "MongoDB is running internally on port 27017"
echo ""
echo "Make sure your AWS Security Group allows:"
echo "  - TCP port 3003 (frontend)"
echo "  - TCP port 3004 (backend)"
echo "========================================"
