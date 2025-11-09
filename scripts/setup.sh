#!/bin/bash

# ISee Monitor Test - Setup Script
# This script helps set up the development environment

echo "========================================="
echo "ISee Monitor Test - Setup Script"
echo "========================================="
echo ""

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✓ Node.js found: $NODE_VERSION"
else
    echo "✗ Node.js not found!"
    echo "  Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✓ npm found: $NPM_VERSION"
else
    echo "✗ npm not found!"
    exit 1
fi

# Check Rust
echo "Checking Rust..."
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo "✓ Rust found: $RUST_VERSION"
else
    echo "✗ Rust not found!"
    echo "  Please install Rust from https://rustup.rs/"
    exit 1
fi

# Check Cargo
echo "Checking Cargo..."
if command -v cargo &> /dev/null; then
    CARGO_VERSION=$(cargo --version)
    echo "✓ Cargo found: $CARGO_VERSION"
else
    echo "✗ Cargo not found!"
    exit 1
fi

echo ""
echo "All prerequisites are installed!"
echo ""

# Install dependencies
echo "Installing npm dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✓ npm dependencies installed successfully"
else
    echo "✗ Failed to install npm dependencies"
    exit 1
fi

echo ""
echo "========================================="
echo "Setup completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run 'npm run tauri:dev' to start development mode"
echo "  2. Run 'npm run tauri:build' to build the application"
echo "  3. Or open 'standalone/index.html' in a browser for standalone version"
echo ""

