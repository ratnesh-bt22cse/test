const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const taskRoutes = require('./routes/taskRoutes');

const app = express();
const PORT = process.env.PORT || 3002;
const SERVICE_NAME = process.env.SERVICE_NAME || 'task-service';

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    service: SERVICE_NAME,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/tasks', taskRoutes);

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/taskdb';

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log(`[${SERVICE_NAME}] Connected to MongoDB`);
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`[${SERVICE_NAME}] Running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error(`[${SERVICE_NAME}] MongoDB connection error:`, error);
    process.exit(1);
  });
