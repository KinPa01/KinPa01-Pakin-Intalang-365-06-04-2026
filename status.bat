@echo off
REM ============================================
REM Status Check Script
REM ============================================

echo.
echo ========================================
echo   System Status Check
echo ========================================
echo.

echo [1/4] Container Status:
echo ----------------------------------------
docker-compose ps
echo.

echo [2/4] Nginx Configuration Test:
echo ----------------------------------------
docker-compose exec -T nginx nginx -t 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Nginx config test failed or container not running
)
echo.

echo [3/4] Service Health:
echo ----------------------------------------
echo Testing Frontend...
curl -s -o nul -w "Frontend (http://localhost): %%{http_code}\n" http://localhost
echo.
echo Testing API...
curl -s -o nul -w "API (http://localhost/api/tasks): %%{http_code}\n" http://localhost/api/tasks
echo.
echo Testing Health Check...
curl -s -o nul -w "Health (http://localhost/health): %%{http_code}\n" http://localhost/health
echo.

echo [4/4] Recent Logs (last 20 lines):
echo ----------------------------------------
docker-compose logs --tail=20
echo.

echo ========================================
echo   Status Check Complete
echo ========================================
echo.
echo Access URLs:
echo   - Frontend: http://localhost
echo   - API:      http://localhost/api/tasks
echo   - Health:   http://localhost/health
echo.
