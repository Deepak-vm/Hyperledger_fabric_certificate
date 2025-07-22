// Hyperledger Fabric Certificate Management System - Main Application
const express = require('express');
const cors = require('cors');
const path = require('path');
const { appConfig } = require('./src/config/organizations');

// Import API routes
const apiRoutes = require('./src/routes/api');

// Create Express application
const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));

// API routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Serve main application page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: 'The requested resource was not found'
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Application error:', err.message);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
    });
});

// Start the server
const PORT = appConfig.port;
app.listen(PORT, () => {
    console.log(`🚀 Certificate Management System started on port ${PORT}`);
    console.log(`📍 Application URL: http://localhost:${PORT}`);
    console.log(`🔗 API Base URL: http://localhost:${PORT}/api`);
    console.log(`💡 Channel: ${appConfig.channelName}`);
    console.log(`📦 Chaincode: ${appConfig.chaincodeName}`);
});
