@echo off
title Smart Queue AI - Setup
color 0E
cd /d "%~dp0"

set FLUTTER_BIN=C:\src\flutter\bin\flutter.bat

echo ============================================================
echo   SMART QUEUE AI - SETUP
echo ============================================================
echo.
echo This will check that all required software is installed.
echo.

REM ---------- Check Python ----------
echo [Step 1 of 2] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [X] Python is NOT installed.
    echo   Opening Python download page in your browser...
    start "" "https://www.python.org/downloads/"
    echo.
    echo   Please install Python 3.13 and TICK "Add Python to PATH".
    echo   When done, come back to this window and press any key.
    pause
    python --version >nul 2>&1
    if errorlevel 1 (
        echo   [X] Python is still not installed. Run SETUP.bat again.
        pause
        exit /b 1
    )
)
echo   [OK] Python is installed.
echo.

REM ---------- Check Flutter ----------
echo [Step 2 of 2] Checking Flutter...

if not exist "%FLUTTER_BIN%" (
    echo.
    echo   [X] Flutter is NOT installed at %FLUTTER_BIN%.
    echo   Opening Flutter install page in your browser...
    start "" "https://docs.flutter.dev/get-started/install/windows"
    echo.
    echo   Please install Flutter to C:\src\flutter
    echo   When done, come back to this window and press any key.
    pause
    if not exist "%FLUTTER_BIN%" (
        echo   [X] Flutter is still not installed. Run SETUP.bat again.
        pause
        exit /b 1
    )
)
echo   [OK] Flutter found at %FLUTTER_BIN%
echo.

echo ============================================================
echo   All requirements installed successfully!
echo ============================================================
echo.
echo   Starting the app now...
echo.

call "%~dp0START_APP.bat"
