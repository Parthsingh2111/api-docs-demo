#!/bin/bash

# PayGlocal PHP Backend Server Startup Script

echo "=== PayGlocal PHP Backend Server ==="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found!"
    echo "Please copy env.php to .env and configure your credentials:"
    echo "cp env.php .env"
    echo ""
    echo "Then edit .env with your PayGlocal credentials"
    exit 1
fi

# Check if composer dependencies are installed
if [ ! -d "pg-client-sdk-php/vendor" ]; then
    echo "⚠️  Composer dependencies not installed!"
    echo "Installing dependencies..."
    cd pg-client-sdk-php
    composer install
    cd ..
fi

# Get port from .env file
PORT=$(grep PORT .env | cut -d'=' -f2)
if [ -z "$PORT" ]; then
    PORT=3001
fi

echo "🚀 Starting PHP Backend Server on port $PORT..."
echo "📱 Your Flutter app should use: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the PHP server
php -S localhost:$PORT index.php 