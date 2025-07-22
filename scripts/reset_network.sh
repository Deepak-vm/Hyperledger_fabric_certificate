#!/bin/bash

# Network Reset and Restart Script for Certificate Management System
# This script completely resets the Hyperledger Fabric network and restarts it properly

# Color coding for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Network Reset and Restart Script =====${NC}"

# Set environment variables for Fabric
export PATH=$PATH:/home/deepak/Desktop/Hyperledger_fabric_certificate-main/bin
export FABRIC_CFG_PATH=/home/deepak/Desktop/Hyperledger_fabric_certificate-main/config
export CORE_PEER_TLS_ENABLED=true

# Navigate to project root
cd /home/deepak/Desktop/Hyperledger_fabric_certificate-main

echo -e "${RED}Step 1: Bringing down existing network...${NC}"
cd test-network
./network.sh down 2>/dev/null || true

echo -e "${RED}Step 2: Cleaning up Docker containers and images...${NC}"
# Stop all containers
docker stop $(docker ps -aq) 2>/dev/null || true

# Remove all containers
docker rm $(docker ps -aq) 2>/dev/null || true

# Remove chaincode images
docker image rm -f $(docker images -aq --filter reference='dev-peer*') 2>/dev/null || true

# Prune system
docker system prune -f 2>/dev/null || true

echo -e "${RED}Step 3: Removing old artifacts...${NC}"
# Remove crypto material and channel artifacts
rm -rf organizations/peerOrganizations/
rm -rf organizations/ordererOrganizations/
rm -rf channel-artifacts/*.block
rm -rf channel-artifacts/*.tx
rm -rf channel-artifacts/*.json
rm -rf channel-artifacts/*.pb
rm -rf system-genesis-block/*.block

# Remove any chaincode packages
rm -rf *.tar.gz

echo -e "${YELLOW}Step 4: Starting fresh network...${NC}"
# Start network with CA and create channel
./network.sh up createChannel -c certchannel -ca

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to start network. Trying alternative approach...${NC}"
    ./network.sh down
    sleep 5
    ./network.sh up -ca
    sleep 5
    ./network.sh createChannel -c certchannel
fi

echo -e "${YELLOW}Step 5: Deploying chaincode...${NC}"
# Deploy the certificate chaincode
./network.sh deployCC -c certchannel -ccn cert_cc -ccp chaincode/cert_cc/go -ccl go

if [ $? -ne 0 ]; then
    echo -e "${RED}Chaincode deployment failed. Trying manual approach...${NC}"
    
    # Set environment for Org1
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    
    # Package chaincode
    peer lifecycle chaincode package cert_cc.tar.gz --path chaincode/cert_cc/go --lang golang --label cert_cc_1.0
    
    # Install on Org1
    peer lifecycle chaincode install cert_cc.tar.gz
    
    # Set environment for Org2
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
    # Install on Org2
    peer lifecycle chaincode install cert_cc.tar.gz
    
    # Get package ID
    PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[] | select(.label=="cert_cc_1.0") | .package_id')
    
    # Approve for Org2
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID certchannel --name cert_cc --version 1.0 --package-id $PACKAGE_ID --sequence 1
    
    # Switch back to Org1 and approve
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID certchannel --name cert_cc --version 1.0 --package-id $PACKAGE_ID --sequence 1
    
    # Commit chaincode
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID certchannel --name cert_cc --version 1.0 --sequence 1 --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
fi

echo -e "${YELLOW}Step 6: Setting up application wallet...${NC}"
cd ../certificate-management-ui
rm -rf wallet/
npm install --silent
node setupWallet.js

echo -e "${GREEN}Step 7: Testing the network...${NC}"
# Test network connectivity
cd ../test-network

# Set environment for Org1
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo -e "${YELLOW}Testing peer connection...${NC}"
peer channel list

echo -e "${YELLOW}Testing chaincode query...${NC}"
peer chaincode query -C certchannel -n cert_cc -c '{"Args":["GetAllCertificates"]}'

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Network is running successfully!${NC}"
    echo -e "${GREEN}✓ Chaincode is deployed and responding!${NC}"
    
    echo -e "${BLUE}Network Status:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo -e "${BLUE}You can now start the certificate management application:${NC}"
    echo -e "${YELLOW}cd certificate-management-ui${NC}"
    echo -e "${YELLOW}npm start${NC}"
    
else
    echo -e "${RED}✗ Network test failed. Please check the logs above.${NC}"
    exit 1
fi

echo -e "${GREEN}Network reset and restart completed successfully!${NC}"
