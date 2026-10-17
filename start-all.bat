@echo off
title Smart Queue AI - Launcher
color 0E

echo ============================================================
echo   Smart Queue AI - Starting everything
echo ============================================================
echo.

echo [1/2] Opening Backend window...
start "Smart Queue AI - Backend" cmd /k "%~dp0start-backend.bat"

echo [2/2] Opening Frontend window...
timeout /t 3 /nobreak >nul
start "Smart Queue AI - Frontend" cmd /k "%~dp0start-frontend.bat"

echo.
echo ============================================================
echo   Both servers are starting in separate windows.
echo.
echo   Wait for:
echo     Backend:  "Application startup complete"
echo     Frontend: "lib\main.dart is being served"
echo.
echo   Then open Chrome to:  http://localhost:5000
echo ============================================================
echo.
pause
