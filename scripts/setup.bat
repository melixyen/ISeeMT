@echo off
REM ISee Monitor Test - Setup Script for Windows
REM This script helps set up the development environment

echo =========================================
echo ISee Monitor Test - Setup Script
echo =========================================
echo.

REM Check Node.js
echo Checking Node.js...
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [OK] Node.js found: %NODE_VERSION%
) else (
    echo [ERROR] Node.js not found!
    echo   Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check npm
echo Checking npm...
where npm >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [OK] npm found: %NPM_VERSION%
) else (
    echo [ERROR] npm not found!
    pause
    exit /b 1
)

REM Check Rust
echo Checking Rust...
where rustc >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('rustc --version') do set RUST_VERSION=%%i
    echo [OK] Rust found: %RUST_VERSION%
) else (
    echo [ERROR] Rust not found!
    echo   Please install Rust from https://rustup.rs/
    pause
    exit /b 1
)

REM Check Cargo
echo Checking Cargo...
where cargo >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('cargo --version') do set CARGO_VERSION=%%i
    echo [OK] Cargo found: %CARGO_VERSION%
) else (
    echo [ERROR] Cargo not found!
    pause
    exit /b 1
)

echo.
echo All prerequisites are installed!
echo.

REM Install dependencies
echo Installing npm dependencies...
call npm install

if %ERRORLEVEL% EQU 0 (
    echo [OK] npm dependencies installed successfully
) else (
    echo [ERROR] Failed to install npm dependencies
    pause
    exit /b 1
)

echo.
echo =========================================
echo Setup completed successfully!
echo =========================================
echo.
echo Next steps:
echo   1. Run 'npm run tauri:dev' to start development mode
echo   2. Run 'npm run tauri:build' to build the application
echo   3. Or open 'standalone\index.html' in a browser for standalone version
echo.
pause

