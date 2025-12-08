# MERN CRUD App - Task Manager

A simple MERN (MongoDB, Express, React, Node.js) CRUD application designed for learning GCP E2 instance deployment.

## 📁 Project Structure

```
test_project/
├── backend/                 # Express.js API Server
│   ├── controllers/         # Route controllers
│   ├── models/              # MongoDB models
│   ├── routes/              # API routes
│   ├── server.js            # Entry point
│   ├── Dockerfile           # Backend Docker config
│   └── package.json
├── frontend/                # React Application
│   ├── public/              # Static files
│   ├── src/
│   │   ├── api/             # API service
│   │   ├── components/      # React components
│   │   ├── App.js           # Main component
│   │   └── index.js         # Entry point
│   ├── Dockerfile           # Frontend Docker config
│   ├── nginx.conf           # Nginx configuration
│   └── package.json
├── scripts/                 # Deployment scripts
│   ├── setup-gcp-vm.sh      # GCP VM setup script
│   └── deploy.sh            # Deployment script
├── docker-compose.yml       # Local development
├── docker-compose.prod.yml  # Production deployment
└── README.md
```

## 🚀 Quick Start (Local Development)

### Prerequisites
- Node.js 18+ installed
- MongoDB installed locally OR Docker
- npm or yarn

### Option 1: Without Docker

**Start Backend:**
```bash
cd backend
npm install
npm run dev
```

**Start Frontend (in a new terminal):**
```bash
cd frontend
npm install
npm start
```

The frontend will be available at `http://localhost:3000` and backend at `http://localhost:5000`.

### Option 2: With Docker Compose

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

The frontend will be available at `http://localhost` and backend at `http://localhost:5000`.

---

## ☁️ GCP E2 Instance Deployment Guide

This guide will help you deploy the MERN app to a GCP Compute Engine E2 instance.

### Step 1: Create GCP E2 VM Instance

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Compute Engine** > **VM instances**
3. Click **Create Instance**
4. Configure the VM:
   - **Name**: `mern-crud-app`
   - **Region/Zone**: Choose closest to your users
   - **Machine configuration**: 
     - Series: **E2**
     - Machine type: **e2-small** (2 vCPU, 2 GB memory) - sufficient for learning
   - **Boot disk**: 
     - Click **Change**
     - Operating System: **Debian** or **Ubuntu**
     - Version: **Debian 11** or **Ubuntu 22.04 LTS**
     - Size: **20 GB**
   - **Firewall**: 
     - ✅ Allow HTTP traffic
     - ✅ Allow HTTPS traffic
5. Click **Create**

### Step 2: Configure Firewall Rules

1. Go to **VPC Network** > **Firewall**
2. Click **Create Firewall Rule**
3. Create rule for backend API:
   - **Name**: `allow-mern-backend`
   - **Direction**: Ingress
   - **Targets**: All instances in the network
   - **Source IP ranges**: `0.0.0.0/0`
   - **Protocols and ports**: 
     - TCP: `5000`
4. Click **Create**

### Step 3: Connect to Your VM

```bash
# Using gcloud CLI
gcloud compute ssh mern-crud-app --zone=YOUR_ZONE

# Or click "SSH" button in Cloud Console
```

### Step 4: Setup VM Environment

Once connected to your VM, run:

```bash
# Download and run setup script
curl -O https://raw.githubusercontent.com/YOUR_REPO/main/scripts/setup-gcp-vm.sh
chmod +x setup-gcp-vm.sh
./setup-gcp-vm.sh

# Log out and log back in for docker group changes
exit
```

Then SSH back into the VM.

### Step 5: Clone and Deploy

```bash
# Clone your repository (or upload files)
git clone YOUR_REPO_URL
cd test_project

# Or if you're uploading files manually:
# Use gcloud compute scp or the Cloud Console file upload

# Make deploy script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

### Step 6: Access Your Application

After deployment completes, access your app:
- **Frontend**: `http://YOUR_EXTERNAL_IP`
- **Backend API**: `http://YOUR_EXTERNAL_IP:5000`
- **Health Check**: `http://YOUR_EXTERNAL_IP:5000/health`

Find your external IP in the GCP Console under VM instances.

---

## 🔧 Manual Deployment (Alternative)

If you prefer to deploy manually without the script:

```bash
# SSH into your GCP VM
gcloud compute ssh mern-crud-app

# Clone repo
git clone YOUR_REPO_URL
cd test_project

# Update the API URL in docker-compose.prod.yml
# Replace YOUR_GCP_VM_IP with your actual external IP
nano docker-compose.prod.yml

# Build and run
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
docker-compose -f docker-compose.prod.yml ps
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks |
| GET | `/api/tasks/:id` | Get single task |
| POST | `/api/tasks` | Create new task |
| PUT | `/api/tasks/:id` | Update task |
| DELETE | `/api/tasks/:id` | Delete task |
| GET | `/health` | Health check |

### Example API Requests

```bash
# Create a task
curl -X POST http://YOUR_IP:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn GCP", "description": "Deploy MERN app to E2"}'

# Get all tasks
curl http://YOUR_IP:5000/api/tasks

# Update a task
curl -X PUT http://YOUR_IP:5000/api/tasks/TASK_ID \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Delete a task
curl -X DELETE http://YOUR_IP:5000/api/tasks/TASK_ID
```

---

## 🛠️ Troubleshooting

### Check Container Logs

```bash
# View all logs
docker-compose -f docker-compose.prod.yml logs

# View specific service logs
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs frontend
docker-compose -f docker-compose.prod.yml logs mongo
```

### Restart Services

```bash
docker-compose -f docker-compose.prod.yml restart
```

### Common Issues

1. **Cannot connect to frontend/backend**
   - Check GCP firewall rules (ports 80 and 5000)
   - Verify containers are running: `docker ps`

2. **MongoDB connection error**
   - Check mongo container is running
   - View mongo logs: `docker logs mern-mongo`

3. **Frontend shows API errors**
   - Verify the API URL is correctly set with your VM's external IP
   - Check backend is accessible: `curl http://YOUR_IP:5000/health`

---

## 📦 Useful Commands

```bash
# Stop all containers
docker-compose -f docker-compose.prod.yml down

# Stop and remove volumes (clears database)
docker-compose -f docker-compose.prod.yml down -v

# Rebuild containers
docker-compose -f docker-compose.prod.yml up -d --build

# View running containers
docker ps

# Enter container shell
docker exec -it mern-backend sh
docker exec -it mern-frontend sh

# View resource usage
docker stats
```

---

## 💰 GCP Cost Optimization Tips

For learning purposes:
- Use **e2-micro** or **e2-small** instances
- Use **Standard persistent disk** (not SSD)
- Consider using **Preemptible VMs** for even lower costs
- Remember to **stop** your VM when not in use
- Set up **budget alerts** in GCP

---

## 🔐 Security Notes (For Production)

This is a learning project. For production, consider:
- Use environment variables for sensitive data
- Set up HTTPS with SSL certificates
- Use MongoDB Atlas or Cloud MongoDB
- Implement authentication/authorization
- Set up proper firewall rules (restrict IP ranges)
- Use GCP Secret Manager for credentials

---

## 📝 License

MIT License - Feel free to use this for learning!
