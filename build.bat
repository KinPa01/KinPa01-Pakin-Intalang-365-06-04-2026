@echo off
REM ============================================
REM Build Script for Nginx Proxy Server Project
REM ============================================

echo.
echo ========================================
echo   Building Nginx Proxy Server Project
echo ========================================
echo.

REM Check if frontend directory exists
if not exist "frontend" (
    echo [ERROR] Frontend directory not found!
    exit /b 1
)

REM Build frontend
echo [1/2] Building frontend...
cd frontend
call npm run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend build failed!
    cd ..
    exit /b 1
)
cd ..

REM Check if build succeeded
if not exist "frontend\dist\spa" (
    echo [ERROR] Frontend build output not found!
    exit /b 1
)

echo [SUCCESS] Frontend built successfully!
echo.

REM Build Docker images
echo [2/2] Building Docker images...
docker-compose build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker build failed!
    exit /b 1
)

echo.
echo ========================================
echo   Build completed successfully!
echo ========================================
echo.
