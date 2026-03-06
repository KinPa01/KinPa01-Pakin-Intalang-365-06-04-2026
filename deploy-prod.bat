@echo off
REM ============================================
REM Production Deploy Script
REM ============================================

echo.
echo ========================================
echo   PRODUCTION DEPLOYMENT
echo ========================================
echo.
echo WARNING: This will deploy to PRODUCTION!
echo.
set /p confirm="Are you sure you want to continue? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo Deployment cancelled.
    exit /b 0
)

echo.
echo [1/4] Stopping existing containers...
docker-compose down
echo.

echo [2/4] Building project...
call build.bat
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed! Deployment aborted.
    exit /b 1
)
echo.

echo [3/4] Starting containers with production config...
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start containers!
    exit /b 1
)
echo.

echo Waiting for services to start...
timeout /t 10 /nobreak >nul
echo.

echo [4/4] Checking status...
docker-compose ps
echo.

echo ========================================
echo   PRODUCTION Deployment Complete!
echo ========================================
echo.
echo Production is now running with:
echo   - Resource limits enabled
echo   - Production environment variables
echo   - Optimized logging
echo.
echo Monitor: docker-compose logs -f
echo Stop:    docker-compose down
echo.
