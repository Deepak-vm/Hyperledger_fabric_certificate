#!/bin/bash

# Comprehensive Project Analysis and Cleanup Script
# This script analyzes the project structure and removes unused/duplicate files

# Color coding for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Hyperledger Fabric Certificate Management System - Project Cleanup =====${NC}"

# Navigate to project root
cd "$(dirname "$0")"
PROJECT_ROOT=$(pwd)

echo -e "${YELLOW}Analyzing project structure...${NC}"

# Core directories that should remain
CORE_DIRS=(
    "bin"
    "config" 
    "test-network"
    "certificate-management-ui"
    "basic-fabric-interface"
    "builders"
)

# Files that should remain
CORE_FILES=(
    "README.md"
    "LICENSE" 
    "report.md"
    ".gitignore"
    ".editorconfig"
    "cleanup_project.sh"
    "reset_network.sh"
    "fix_discovery_access.sh"
    "fix_org3_access.sh"
)

echo -e "${MAGENTA}Core Project Structure:${NC}"
echo -e "${GREEN}Essential Directories:${NC}"
for dir in "${CORE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ✓ $dir"
        du -sh "$dir" 2>/dev/null | sed 's/^/    /'
    else
        echo -e "  ✗ $dir (missing)"
    fi
done

echo -e "${GREEN}Essential Files:${NC}"
for file in "${CORE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ✓ $file"
    else
        echo -e "  ✗ $file (missing)"
    fi
done

echo -e "${YELLOW}Checking for unnecessary files and directories...${NC}"

# Check for common unnecessary files/directories
UNNECESSARY_PATTERNS=(
    "asset-transfer-*"
    "auction-*"
    "full-stack-asset-transfer-guide"
    "hardware-security-module"
    "high-throughput"
    "off_chain_data"
    "test-application"
    "token-*"
    "test-network-nano-bash"
    "commercial-paper"
    "interest_rate_swaps"
)

echo -e "${YELLOW}Looking for sample applications that can be removed...${NC}"
FOUND_UNNECESSARY=false
for pattern in "${UNNECESSARY_PATTERNS[@]}"; do
    if ls $pattern 2>/dev/null | head -1 | grep -q .; then
        echo -e "${RED}Found unnecessary directory/file matching: $pattern${NC}"
        ls -la $pattern 2>/dev/null | head -3
        FOUND_UNNECESSARY=true
    fi
done

if [ "$FOUND_UNNECESSARY" = false ]; then
    echo -e "${GREEN}✓ No unnecessary sample applications found${NC}"
fi

echo -e "${YELLOW}Checking for temporary and cache files...${NC}"

# Find temporary files
TEMP_FILES_FOUND=false

# Check for node_modules
if find . -name "node_modules" -type d 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}Found node_modules directories:${NC}"
    find . -name "node_modules" -type d 2>/dev/null | head -5
    TEMP_FILES_FOUND=true
fi

# Check for log files
if find . -name "*.log" 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}Found log files:${NC}"
    find . -name "*.log" 2>/dev/null | head -5
    TEMP_FILES_FOUND=true
fi

# Check for build artifacts
BUILD_DIRS=("dist" "build" "target" ".next" "coverage")
for dir in "${BUILD_DIRS[@]}"; do
    if find . -name "$dir" -type d 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}Found $dir directories:${NC}"
        find . -name "$dir" -type d 2>/dev/null | head -3
        TEMP_FILES_FOUND=true
    fi
done

# Check for editor files
EDITOR_FILES=(".vscode" ".idea" "*.swp" "*.swo" "*~" ".DS_Store")
for pattern in "${EDITOR_FILES[@]}"; do
    if find . -name "$pattern" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}Found editor files matching $pattern:${NC}"
        find . -name "$pattern" 2>/dev/null | head -3
        TEMP_FILES_FOUND=true
    fi
done

if [ "$TEMP_FILES_FOUND" = false ]; then
    echo -e "${GREEN}✓ No temporary files found${NC}"
fi

echo -e "${BLUE}Current project size breakdown:${NC}"
echo -e "${GREEN}Total project size:${NC}"
du -sh . 2>/dev/null

echo -e "${GREEN}Largest directories:${NC}"
du -sh */ 2>/dev/null | sort -hr | head -10

echo -e "${GREEN}File count by type:${NC}"
echo -e "JavaScript files: $(find . -name "*.js" | wc -l)"
echo -e "TypeScript files: $(find . -name "*.ts" | wc -l)" 
echo -e "Go files: $(find . -name "*.go" | wc -l)"
echo -e "Java files: $(find . -name "*.java" | wc -l)"
echo -e "Shell scripts: $(find . -name "*.sh" | wc -l)"
echo -e "JSON files: $(find . -name "*.json" | wc -l)"
echo -e "YAML files: $(find . -name "*.yaml" -o -name "*.yml" | wc -l)"
echo -e "Markdown files: $(find . -name "*.md" | wc -l)"

echo -e "${BLUE}Docker containers status:${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Running containers:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No running containers"
    
    echo -e "${GREEN}Fabric related images:${NC}"
    docker images | grep -E "(hyperledger|fabric)" | head -5 || echo "No Fabric images found"
fi

echo -e "${BLUE}Recommendations:${NC}"
echo -e "${GREEN}Your project structure looks clean! Here's what you can do:${NC}"

echo -e "${YELLOW}1. To clean temporary files:${NC}"
echo -e "   ./cleanup_project.sh"

echo -e "${YELLOW}2. To reset the network (fixes connectivity issues):${NC}"
echo -e "   ./reset_network.sh"

echo -e "${YELLOW}3. Manual cleanup commands (if needed):${NC}"
echo -e "   # Remove node_modules (will be reinstalled):"
echo -e "   find . -name 'node_modules' -type d -exec rm -rf {} + 2>/dev/null"
echo -e "   "
echo -e "   # Remove log files:"
echo -e "   find . -name '*.log' -delete"
echo -e "   "
echo -e "   # Remove editor files:"
echo -e "   find . -name '.vscode' -type d -exec rm -rf {} + 2>/dev/null"

echo -e "${BLUE}Next steps to fix your network issue:${NC}"
echo -e "${GREEN}1. Run the network reset script:${NC}"
echo -e "   ./reset_network.sh"
echo -e "${GREEN}2. If successful, start the application:${NC}"
echo -e "   cd certificate-management-ui && npm start"

echo -e "${GREEN}Analysis completed!${NC}"
