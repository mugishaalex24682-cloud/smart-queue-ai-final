@echo off
title Smart Queue AI - Backend
color 0A
cd /d "%~dp0backend"

echo ============================================================
echo   Smart Queue AI - Backend
echo ============================================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed.
    echo Please install Python 3.13 from https://www.python.org/downloads/
    echo IMPORTANT: Tick "Add Python to PATH" during installation.
    pause
    exit /b 1
)

echo [OK] Python is installed.
echo.

python -c "import fastapi" >nul 2>&1
if errorlevel 1 (
    echo Installing backend dependencies for the first time...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo Installation failed. Please check your internet.
        pause
        exit /b 1
    )
)

echo.
echo Starting backend at http://localhost:8000
echo Press Ctrl+C to stop.
echo.

uvicorn main:app --reload --host 0.0.0.0 --port 8000
pause
