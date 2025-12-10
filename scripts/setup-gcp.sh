#!/bin/bash

# Setup GCP VM for microservices deployment
# Run this after SSH into your GCP E2 instance

set -e

echo "========================================"
echo "GCP E2 VM Setup for Microservices"
echo "========================================"

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Install git
sudo apt-get install -y git

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "IMPORTANT: Log out and log back in, then run:"
echo "  git clone https://github.com/ratnesh-bt22cse/test.git"
echo "  cd test"
echo "  chmod +x scripts/*.sh"
echo "  ./scripts/build-all.sh"
echo "  ./scripts/run-all.sh YOUR_EXTERNAL_IP"
echo "========================================"
