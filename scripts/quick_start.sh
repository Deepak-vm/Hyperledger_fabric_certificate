#!/bin/bash

# Quick Start Script - Test Everything Works
# This script sets up dependencies and tests the application

# Color coding for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Quick Start - Testing Certificate Management System =====${NC}"

cd "$(dirname "$0")"

echo -e "${YELLOW}Step 1: Installing application dependencies...${NC}"
cd certificate-management-ui
npm install --silent

echo -e "${YELLOW}Step 2: Setting up wallet...${NC}"
node setupWallet.js

echo -e "${YELLOW}Step 3: Testing network connectivity...${NC}"
cd ../test-network

# Set environment for testing
export PATH=$PATH:$(pwd)/../bin
export FABRIC_CFG_PATH=$(pwd)/../config
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$(pwd)/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=$(pwd)/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Test peer connection
echo -e "${YELLOW}Testing peer connection...${NC}"
if peer channel list > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Peer connection: WORKING${NC}"
else
    echo -e "${RED}❌ Peer connection: FAILED${NC}"
fi

# Test chaincode
echo -e "${YELLOW}Testing chaincode...${NC}"
if peer chaincode query -C certchannel -n cert_cc -c '{"Args":["GetAllCertificates"]}' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Chaincode: WORKING${NC}"
else
    echo -e "${RED}❌ Chaincode: FAILED${NC}"
fi

echo -e "${BLUE}System Status:${NC}"
echo -e "${GREEN}Docker containers running:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(peer|orderer|ca)" | head -8

echo -e "${GREEN}Ready to start the application!${NC}"
echo -e "${YELLOW}Run: cd certificate-management-ui && npm start${NC}"
echo -e "${YELLOW}Access: http://localhost:3000${NC}"
