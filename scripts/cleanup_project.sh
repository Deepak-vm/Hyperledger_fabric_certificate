#!/bin/bash

# Project Cleanup Script for Hyperledger Fabric Certificate Management System
# This script removes temporary files, logs, and unused artifacts

# Color coding for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Cleaning up Hyperledger Fabric Certificate Management Project =====${NC}"

# Navigate to project root
cd "$(dirname "$0")"
PROJECT_ROOT=$(pwd)

echo -e "${YELLOW}Current directory: ${PROJECT_ROOT}${NC}"

# 1. Remove temporary files and logs
echo -e "${YELLOW}Removing temporary files and logs...${NC}"

# Remove Node.js temporary files
find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "package-lock.json" -delete 2>/dev/null || true
find . -name ".npm" -type d -exec rm -rf {} + 2>/dev/null || true

# Remove logs
find . -name "*.log" -delete 2>/dev/null || true
find . -name "log.txt" -delete 2>/dev/null || true

# Remove temporary certificates and crypto material (will be regenerated)
if [ -d "test-network/organizations" ]; then
    echo -e "${YELLOW}Removing old crypto material...${NC}"
    rm -rf test-network/organizations/peerOrganizations
    rm -rf test-network/organizations/ordererOrganizations
    rm -rf test-network/organizations/fabric-ca/*/msp
    rm -rf test-network/organizations/fabric-ca/*/tls-cert.pem
    rm -rf test-network/organizations/fabric-ca/*/ca-cert.pem
    rm -rf test-network/organizations/fabric-ca/*/IssuerPublicKey
    rm -rf test-network/organizations/fabric-ca/*/IssuerRevocationPublicKey
    rm -rf test-network/organizations/fabric-ca/*/fabric-ca-server.db
fi

# Remove channel artifacts
if [ -d "test-network/channel-artifacts" ]; then
    echo -e "${YELLOW}Removing old channel artifacts...${NC}"
    rm -rf test-network/channel-artifacts/*.block
    rm -rf test-network/channel-artifacts/*.tx
    rm -rf test-network/channel-artifacts/*.json
    rm -rf test-network/channel-artifacts/*.pb
fi

# Remove system genesis block
if [ -d "test-network/system-genesis-block" ]; then
    rm -rf test-network/system-genesis-block/*.block
fi

# Remove chaincode packages
find test-network -name "*.tar.gz" -delete 2>/dev/null || true

# 2. Remove Docker artifacts
echo -e "${YELLOW}Cleaning Docker artifacts...${NC}"

# Stop and remove all Fabric containers
docker stop $(docker ps -aq --filter "name=peer*") 2>/dev/null || true
docker stop $(docker ps -aq --filter "name=orderer*") 2>/dev/null || true
docker stop $(docker ps -aq --filter "name=ca*") 2>/dev/null || true
docker stop $(docker ps -aq --filter "name=dev-*") 2>/dev/null || true

docker rm $(docker ps -aq --filter "name=peer*") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=orderer*") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=ca*") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=dev-*") 2>/dev/null || true

# Remove chaincode docker images
docker image rm -f $(docker images -aq --filter reference='dev-peer*') 2>/dev/null || true

# Remove volumes
docker volume prune -f 2>/dev/null || true

# 3. Remove application wallets (will be regenerated)
echo -e "${YELLOW}Removing application wallets...${NC}"
rm -rf certificate-management-ui/wallet
rm -rf basic-fabric-interface/wallet

# 4. Remove IDE and editor files
echo -e "${YELLOW}Removing IDE and editor files...${NC}"
find . -name ".vscode" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".idea" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.swp" -delete 2>/dev/null || true
find . -name "*.swo" -delete 2>/dev/null || true
find . -name "*~" -delete 2>/dev/null || true

# 5. Remove OS specific files
echo -e "${YELLOW}Removing OS specific files...${NC}"
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true
find . -name "desktop.ini" -delete 2>/dev/null || true

# 6. Clean up build artifacts
echo -e "${YELLOW}Removing build artifacts...${NC}"
find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "target" -type d -exec rm -rf {} + 2>/dev/null || true

# 7. Remove test artifacts and coverage reports
echo -e "${YELLOW}Removing test artifacts...${NC}"
find . -name "coverage" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".nyc_output" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.lcov" -delete 2>/dev/null || true

# 8. Show current project size
echo -e "${BLUE}Project cleanup completed!${NC}"
echo -e "${GREEN}Current project structure:${NC}"
du -sh . 2>/dev/null || echo "Unable to calculate size"

echo -e "${GREEN}Main directories:${NC}"
du -sh */ 2>/dev/null | head -10

echo -e "${BLUE}To start fresh, run:${NC}"
echo -e "${YELLOW}cd test-network${NC}"
echo -e "${YELLOW}./network.sh up createChannel -c certchannel -ca${NC}"
echo -e "${YELLOW}./network.sh deployCC -c certchannel -ccn cert_cc -ccp chaincode/cert_cc/go -ccl go${NC}"
echo -e "${YELLOW}cd ../certificate-management-ui${NC}"
echo -e "${YELLOW}npm install${NC}"
echo -e "${YELLOW}node setupWallet.js${NC}"
echo -e "${YELLOW}npm start${NC}"

echo -e "${GREEN}Cleanup completed successfully!${NC}"
