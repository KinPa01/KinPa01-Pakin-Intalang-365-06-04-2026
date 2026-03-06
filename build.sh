#!/bin/bash
# ============================================
# Build Script for Nginx Proxy Server Project
# ============================================

echo ""
echo "========================================"
echo "  Building Nginx Proxy Server Project"
echo "========================================"
echo ""

# Check if frontend directory exists
if [ ! -d "frontend" ]; then
    echo "[ERROR] Frontend directory not found!"
    exit 1
fi

# Build frontend
echo "[1/2] Building frontend..."
cd frontend
npm run build
if [ $? -ne 0 ]; then
    echo "[ERROR] Frontend build failed!"
    cd ..
    exit 1
fi
cd ..

# Check if build succeeded
if [ ! -d "frontend/dist/spa" ]; then
    echo "[ERROR] Frontend build output not found!"
    exit 1
fi

echo "[SUCCESS] Frontend built successfully!"
echo ""

# Build Docker images
echo "[2/2] Building Docker images..."
docker-compose build
if [ $? -ne 0 ]; then
    echo "[ERROR] Docker build failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "  Build completed successfully!"
echo "========================================"
echo ""
