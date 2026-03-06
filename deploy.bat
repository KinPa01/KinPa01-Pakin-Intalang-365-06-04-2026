@echo off
REM ============================================
REM Deploy Script for Nginx Proxy Server Project
REM ============================================

echo.
echo ========================================
echo   Deploying Nginx Proxy Server
echo ========================================
echo.

REM Stop existing containers
echo [1/4] Stopping existing containers...
docker-compose down
echo.

REM Build project
echo [2/4] Building project...
call build.bat
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed! Deployment aborted.
    exit /b 1
)
echo.

REM Start containers
echo [3/4] Starting containers...
docker-compose up -d
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start containers!
    exit /b 1
)
echo.

REM Wait for services to start
echo Waiting for services to start...
timeout /t 5 /nobreak >nul
echo.

REM Show status
echo [4/4] Checking status...
docker-compose ps
echo.

echo ========================================
echo   Deployment completed successfully!
echo ========================================
echo.
echo Access your application:
echo   - Frontend: http://localhost
echo   - API:      http://localhost/api/tasks
echo   - Health:   http://localhost/health
echo.
echo To view logs: docker-compose logs -f
echo To stop:      docker-compose down
echo.
