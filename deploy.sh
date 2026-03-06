#!/bin/bash
# ============================================
# Deploy Script for Nginx Proxy Server Project
# ============================================

echo ""
echo "========================================"
echo "  Deploying Nginx Proxy Server"
echo "========================================"
echo ""

# Stop existing containers
echo "[1/4] Stopping existing containers..."
docker-compose down
echo ""

# Build project
echo "[2/4] Building project..."
./build.sh
if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed! Deployment aborted."
    exit 1
fi
echo ""

# Start containers
echo "[3/4] Starting containers..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to start containers!"
    exit 1
fi
echo ""

# Wait for services to start
echo "Waiting for services to start..."
sleep 5
echo ""

# Show status
echo "[4/4] Checking status..."
docker-compose ps
echo ""

echo "========================================"
echo "  Deployment completed successfully!"
echo "========================================"
echo ""
echo "Access your application:"
echo "  - Frontend: http://localhost"
echo "  - API:      http://localhost/api/tasks"
echo "  - Health:   http://localhost/health"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop:      docker-compose down"
echo ""
