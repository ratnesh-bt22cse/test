#!/bin/bash

# AWS EC2 Setup Script (Ubuntu/Amazon Linux)
# Run this script on your AWS EC2 instance after SSH'ing into it

set -e

echo "========================================"
echo "AWS EC2 Setup for MERN CRUD App"
echo "========================================"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

echo "Detected OS: $OS"

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y 2>/dev/null || sudo yum update -y

# Install Docker based on OS
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "Installing Docker on Ubuntu/Debian..."
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
elif [ "$OS" = "amzn" ]; then
    echo "Installing Docker on Amazon Linux..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Add current user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose (standalone)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
echo "Installing Git..."
sudo apt-get install -y git 2>/dev/null || sudo yum install -y git

# Start Docker service
sudo systemctl start docker 2>/dev/null || sudo service docker start

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker-compose --version
echo ""
echo "========================================"
echo "IMPORTANT: Log out and log back in for"
echo "docker group changes to take effect!"
echo ""
echo "Then run:"
echo "  git clone https://github.com/ratnesh-bt22cse/test.git"
echo "  cd test"
echo "  chmod +x scripts/deploy-aws.sh"
echo "  ./scripts/deploy-aws.sh"
echo "========================================"
