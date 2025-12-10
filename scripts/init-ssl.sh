#!/bin/bash

# SSL Certificate Setup Script using Let's Encrypt
# Usage: ./init-ssl.sh YOUR_DOMAIN YOUR_EMAIL

set -e

DOMAIN=$1
EMAIL=$2

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: ./init-ssl.sh YOUR_DOMAIN YOUR_EMAIL"
    echo "Example: ./init-ssl.sh ratnesh-mern.duckdns.org myemail@gmail.com"
    exit 1
fi

echo "========================================"
echo "SSL Setup for: $DOMAIN"
echo "Email: $EMAIL"
echo "========================================"

# Create directories
mkdir -p certbot/conf
mkdir -p certbot/www

# Update nginx config with domain
echo "Updating nginx config with domain..."
sed -i "s|YOUR_DOMAIN|$DOMAIN|g" frontend/nginx.ssl.conf

# Update docker-compose with domain
echo "Updating docker-compose with domain..."
sed -i "s|YOUR_DOMAIN|$DOMAIN|g" docker-compose.ssl.yml

# Create initial nginx config for certificate generation (HTTP only first)
cat > frontend/nginx.init.conf << 'EOF'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
EOF

sed -i "s|DOMAIN_PLACEHOLDER|$DOMAIN|g" frontend/nginx.init.conf

# Create temporary Dockerfile for initial setup
cat > frontend/Dockerfile.init << 'EOF'
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL
RUN npm run build

FROM nginx:alpine
COPY nginx.init.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create temporary docker-compose for getting certificate
cat > docker-compose.init.yml << EOF
version: '3.8'
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.init
      args:
        - REACT_APP_API_URL=https://$DOMAIN/api
    container_name: mern-frontend-init
    ports:
      - "80:80"
    volumes:
      - ./certbot/www:/var/www/certbot
EOF

echo ""
echo "Step 1: Starting temporary nginx for certificate generation..."
docker-compose -f docker-compose.init.yml up -d --build

echo ""
echo "Waiting for nginx to start..."
sleep 5

echo ""
echo "Step 2: Requesting SSL certificate from Let's Encrypt..."
docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

echo ""
echo "Step 3: Stopping temporary nginx..."
docker-compose -f docker-compose.init.yml down

echo ""
echo "Step 4: Cleaning up temporary files..."
rm -f frontend/nginx.init.conf
rm -f frontend/Dockerfile.init
rm -f docker-compose.init.yml

echo ""
echo "========================================"
echo "SSL Certificate Generated Successfully!"
echo "========================================"
echo ""
echo "Now start your app with HTTPS:"
echo "  docker-compose -f docker-compose.ssl.yml up -d --build"
echo ""
echo "Your app will be available at:"
echo "  https://$DOMAIN"
echo "========================================"
