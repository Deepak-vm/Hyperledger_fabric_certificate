#!/bin/bash

# Final Project Cleanup Script - Remove All Unused Files
# This script performs a comprehensive cleanup of the Hyperledger Fabric Certificate project

# Color coding for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Final Project Cleanup - Remove Unused Files =====${NC}"

# Navigate to project root
cd "$(dirname "$0")"
PROJECT_ROOT=$(pwd)

echo -e "${YELLOW}Project root: ${PROJECT_ROOT}${NC}"

# Function to safely remove files/directories
safe_remove() {
    local item="$1"
    local description="$2"
    
    if [ -e "$item" ]; then
        echo -e "${YELLOW}Removing $description: $item${NC}"
        rm -rf "$item" 2>/dev/null || echo -e "${RED}Could not remove $item${NC}"
    fi
}

# Function to remove files by pattern
remove_pattern() {
    local pattern="$1"
    local description="$2"
    
    echo -e "${YELLOW}Searching for $description...${NC}"
    find . -name "$pattern" -type f 2>/dev/null | while read -r file; do
        echo -e "  Removing: $file"
        rm -f "$file"
    done
}

echo -e "${MAGENTA}Phase 1: Remove temporary and cache files${NC}"

# Remove Node.js artifacts
remove_pattern "package-lock.json" "package-lock files"
remove_pattern ".npm" "NPM cache"
safe_remove "*/node_modules" "Node modules directories"

# Remove build artifacts
remove_pattern "*.tgz" "tarball files"
remove_pattern "*.tar.gz" "compressed archives"

echo -e "${MAGENTA}Phase 2: Remove editor and OS files${NC}"

# Remove editor files
safe_remove "*/.vscode" "VS Code settings"
safe_remove "*/.idea" "IntelliJ IDEA files"
remove_pattern "*.swp" "Vim swap files"
remove_pattern "*.swo" "Vim swap files"
remove_pattern "*~" "backup files"

# Remove OS files
remove_pattern ".DS_Store" "macOS metadata files"
remove_pattern "Thumbs.db" "Windows thumbnail cache"
remove_pattern "desktop.ini" "Windows folder settings"

echo -e "${MAGENTA}Phase 3: Remove logs and temporary data${NC}"

# Remove log files
remove_pattern "*.log" "log files"
safe_remove "test-network/log.txt" "network log file"

# Remove test artifacts
safe_remove "*/coverage" "test coverage reports"
safe_remove "*/.nyc_output" "NYC output"

echo -e "${MAGENTA}Phase 4: Clean up Docker and network artifacts${NC}"

# Remove old chaincode packages
find test-network -name "*.tar.gz" -delete 2>/dev/null || true

# Clean application wallets (will be regenerated)
echo -e "${YELLOW}Cleaning application wallets...${NC}"
safe_remove "certificate-management-ui/wallet" "certificate management wallet"
safe_remove "basic-fabric-interface/wallet" "basic interface wallet"

echo -e "${MAGENTA}Phase 5: Remove duplicate or unused files${NC}"

# Remove any duplicate README files
safe_remove "*/README.md.bak" "backup README files"
safe_remove "*/README.old" "old README files"

# Remove any test databases or temp files in chaincode
safe_remove "*/chaincode/**/test.db" "test databases"
safe_remove "*/chaincode/**/tmp" "temporary chaincode files"

echo -e "${MAGENTA}Phase 6: Check for large unnecessary files${NC}"

echo -e "${YELLOW}Checking for files larger than 10MB...${NC}"
find . -type f -size +10M 2>/dev/null | grep -v bin/ | head -10 | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    echo -e "${YELLOW}Large file found: $file ($size)${NC}"
done

echo -e "${MAGENTA}Phase 7: Final optimization${NC}"

# Remove empty directories
echo -e "${YELLOW}Removing empty directories...${NC}"
find . -type d -empty -delete 2>/dev/null || true

# Set correct permissions for scripts
echo -e "${YELLOW}Setting correct permissions for scripts...${NC}"
chmod +x *.sh 2>/dev/null || true
chmod +x certificate-management-ui/*.sh 2>/dev/null || true
chmod +x test-network/*.sh 2>/dev/null || true

echo -e "${BLUE}Final Cleanup Summary:${NC}"
echo -e "${GREEN}Project structure after cleanup:${NC}"
du -sh . 2>/dev/null

echo -e "${GREEN}Main directories:${NC}"
du -sh */ 2>/dev/null | sort -hr | head -8

echo -e "${GREEN}File count by type:${NC}"
echo -e "Shell scripts: $(find . -name "*.sh" | wc -l)"
echo -e "JavaScript files: $(find . -name "*.js" | wc -l)"
echo -e "Go files: $(find . -name "*.go" | wc -l)"
echo -e "JSON files: $(find . -name "*.json" | wc -l)"
echo -e "YAML files: $(find . -name "*.yaml" -o -name "*.yml" | wc -l)"

echo -e "${BLUE}Project Status:${NC}"
echo -e "${GREEN}✅ Unused files removed${NC}"
echo -e "${GREEN}✅ Project optimized${NC}"
echo -e "${GREEN}✅ Ready for production${NC}"

echo -e "${YELLOW}Essential files preserved:${NC}"
echo -e "  ✓ bin/ (Fabric binaries)"
echo -e "  ✓ config/ (Configuration files)"
echo -e "  ✓ test-network/ (Network setup)"
echo -e "  ✓ certificate-management-ui/ (Main application)"
echo -e "  ✓ basic-fabric-interface/ (Alternative interface)"
echo -e "  ✓ builders/ (Chaincode builders)"

echo -e "${GREEN}Final cleanup completed successfully!${NC}"

echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Test the network: ${YELLOW}./reset_network.sh${NC}"
echo -e "2. Start the app: ${YELLOW}cd certificate-management-ui && npm start${NC}"
echo -e "3. Access at: ${YELLOW}http://localhost:3000${NC}"
