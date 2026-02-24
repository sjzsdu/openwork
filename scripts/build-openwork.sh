#!/bin/bash

# OpenWork Build Script
# This script builds OpenWork from source and optionally installs it to your PATH
#
# Usage:
#   ./scripts/build-openwork.sh         # Interactive mode
#   ./scripts/build-openwork.sh --yes   # Auto-install after build
#   ./scripts/build-openwork.sh --help  # Show help

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
INSTALL_AFTER_BUILD=false
HELP=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--yes) INSTALL_AFTER_BUILD=true; shift ;;
    -h|--help) HELP=true; shift ;;
    *) shift ;;
  esac
done

if [ "$HELP" = true ]; then
  echo "OpenWork Build Script"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -y, --yes    Automatically install to PATH after build (non-interactive)"
  echo "  -h, --help   Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0               # Interactive build"
  echo "  $0 --yes         # Build and auto-install"
  exit 0
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESKTOP_DIR="$PROJECT_ROOT/packages/desktop"

echo -e "${GREEN}=== OpenWork Build Script ===${NC}"
echo ""

# Step 0: Check prerequisites
echo -e "${YELLOW}Step 0: Checking prerequisites...${NC}"

# Check OpenCode CLI
if ! command -v opencode &> /dev/null; then
    echo -e "${RED}Error: OpenCode CLI is not installed${NC}"
    echo "Please install from: https://opencode.ai"
    exit 1
fi
echo "OpenCode: $(opencode --version 2>&1 | head -1)"

# Step 1: Ensure Rust is using the correct version
echo ""
echo -e "${YELLOW}Step 1: Checking Rust environment...${NC}"
if command -v rustup &> /dev/null; then
    export RUSTC="$(rustup which rustc 2>/dev/null || echo "")"
    export CARGO="$(rustup which cargo 2>/dev/null || echo "")"
    if [ -n "$RUSTC" ]; then
        export PATH="$(dirname "$RUSTC"):$(dirname "$CARGO"):$PATH"
        echo "Using Rust: $($RUSTC --version)"
    fi
fi

# Step 2: Install dependencies
echo ""
echo -e "${YELLOW}Step 2: Installing dependencies...${NC}"
cd "$PROJECT_ROOT"
pnpm install

# Step 3: Prepare sidecar (OpenCode binary)
echo ""
echo -e "${YELLOW}Step 3: Preparing OpenCode sidecar...${NC}"
cd "$DESKTOP_DIR"
OPENWORK_SIDECAR_FORCE_BUILD=1 pnpm prepare:sidecar

# Step 4: Build Tauri app
echo ""
echo -e "${YELLOW}Step 4: Building OpenWork desktop app...${NC}"
cd "$DESKTOP_DIR"
pnpm tauri build

# Step 5: Find the built executable
BUILT_EXECUTABLE="$DESKTOP_DIR/src-tauri/target/release/openwork"

if [ -f "$BUILT_EXECUTABLE" ]; then
    echo ""
    echo -e "${GREEN}=== Build Successful! ===${NC}"
    echo "Executable: $BUILT_EXECUTABLE"
    echo "Size: $(du -h "$BUILT_EXECUTABLE" | cut -f1)"
    
    # Step 6: Install to PATH
    # Auto-install if --yes flag or if running in terminal
    if [ "$INSTALL_AFTER_BUILD" = true ] || [[ -t 0 ]]; then
        echo ""
        if [ "$INSTALL_AFTER_BUILD" = false ]; then
            echo -e "${YELLOW}Would you like to install OpenWork to your PATH?${NC}"
            echo "This will copy the executable to ~/.local/bin or /usr/local/bin"
            echo ""
            read -p "Install now? [y/N] " -n 1 -r
            echo ""
            
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Skipped installation."
                exit 0
            fi
        fi
        
        # Try ~/.local/bin first, then /usr/local/bin
        if [ -d "$HOME/.local/bin" ] && [ -w "$HOME/.local/bin" ]; then
            INSTALL_DIR="$HOME/.local/bin"
        elif [ -w "/usr/local/bin" ]; then
            INSTALL_DIR="/usr/local/bin"
        else
            INSTALL_DIR="$HOME/.local/bin"
        fi
        
        if [ ! -d "$INSTALL_DIR" ]; then
            mkdir -p "$INSTALL_DIR"
        fi
        
        if [ "$INSTALL_DIR" = "/usr/local/bin" ] && [ ! -w "/usr/local/bin" ]; then
            echo "Need sudo to install to /usr/local/bin..."
            sudo cp "$BUILT_EXECUTABLE" "$INSTALL_DIR/openwork"
            sudo chmod +x "$INSTALL_DIR/openwork"
        else
            cp "$BUILT_EXECUTABLE" "$INSTALL_DIR/openwork"
            chmod +x "$INSTALL_DIR/openwork"
        fi
        
        echo -e "${GREEN}✅ OpenWork installed to $INSTALL_DIR/openwork${NC}"
        echo "You can now run 'openwork' from anywhere!"
    fi
else
    echo -e "${RED}Build failed - executable not found at $BUILT_EXECUTABLE${NC}"
    exit 1
fi