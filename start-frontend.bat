@echo off
title Smart Queue AI - Frontend
color 0B
cd /d "%~dp0frontend"

set FLUTTER_BIN=C:\src\flutter\bin\flutter.bat

echo ============================================================
echo   Smart Queue AI - Frontend
echo ============================================================
echo.

if not exist "%FLUTTER_BIN%" (
    echo Flutter is not installed at expected path:
    echo    %FLUTTER_BIN%
    echo.
    echo Please install Flutter from https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo [OK] Flutter found at %FLUTTER_BIN%
echo.

if not exist ".dart_tool" (
    echo Installing frontend dependencies for the first time...
    call "%FLUTTER_BIN%" pub get
    if errorlevel 1 (
        echo Installation failed. Please check your internet.
        pause
        exit /b 1
    )
)

echo.
echo Starting frontend at http://localhost:5000
echo WAIT for "lib\main.dart is being served" then open Chrome to http://localhost:5000
echo.

call "%FLUTTER_BIN%" run -d web-server --web-port=5000
pause
