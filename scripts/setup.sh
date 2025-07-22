#!/bin/bash

# Hyperledger Fabric Certificate Management System - Complete Setup Script
# This script handles all network setup, chaincode deployment, and application setup

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Hyperledger Fabric Certificate Management System ===${NC}"
echo -e "${CYAN}=== Complete Network Setup and Application Launcher ===${NC}"
echo ""

# Check if we're in the correct directory
if [ ! -f "network.sh" ]; then
    echo -e "${RED}Error: Please run this script from the test-network directory${NC}"
    echo -e "${YELLOW}Usage: cd test-network && ../scripts/setup.sh${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    if ! command_exists docker; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        echo -e "${RED}❌ Docker Compose is not installed${NC}"
        exit 1
    fi
    
    if ! command_exists node; then
        echo -e "${RED}❌ Node.js is not installed${NC}"
        exit 1
    fi
    
    if ! command_exists npm; then
        echo -e "${RED}❌ npm is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites met${NC}"
}

# Function to clean up any existing network
cleanup_existing() {
    echo -e "${YELLOW}Cleaning up any existing network...${NC}"
    
    # Stop and remove all containers
    ./network.sh down 2>/dev/null || true
    
    # Remove any existing chaincode packages
    rm -f cert_cc.tar.gz 2>/dev/null || true
    
    # Clean up Docker
    docker system prune -f >/dev/null 2>&1 || true
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to start the network
start_network() {
    echo -e "${YELLOW}Starting Hyperledger Fabric network...${NC}"
    
    # Start the network with CA
    ./network.sh up createChannel -c certchannel -ca
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to start network${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Network started successfully${NC}"
}

# Function to deploy chaincode
deploy_chaincode() {
    echo -e "${YELLOW}Deploying certificate management chaincode...${NC}"
    
    # Deploy the chaincode
    ./network.sh deployCC -c certchannel -ccn cert_cc -ccp chaincode/cert_cc/go -ccl go
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to deploy chaincode${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Chaincode deployed successfully${NC}"
}

# Function to setup application
setup_application() {
    echo -e "${YELLOW}Setting up certificate management application...${NC}"
    
    cd ../certificate-management-ui
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "Installing Node.js dependencies..."
        npm install --silent
    fi
    
    # Setup wallet
    echo "Setting up application wallet..."
    rm -rf wallet/ 2>/dev/null || true
    node setupWallet.js
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to setup wallet${NC}"
        exit 1
    fi
    
    cd ../test-network
    echo -e "${GREEN}✓ Application setup complete${NC}"
}

# Function to test the network
test_network() {
    echo -e "${YELLOW}Testing network connectivity...${NC}"
    
    # Set environment for testing
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    
    # Test chaincode query
    peer chaincode query -C certchannel -n cert_cc -c '{"Args":["GetAllCertificates"]}' >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Network test successful${NC}"
        return 0
    else
        echo -e "${RED}❌ Network test failed${NC}"
        return 1
    fi
}

# Function to display final status
show_final_status() {
    echo ""
    echo -e "${CYAN}=== Setup Complete! ===${NC}"
    echo ""
    echo -e "${GREEN}✅ Hyperledger Fabric Network: Running${NC}"
    echo -e "${GREEN}✅ Certificate Chaincode: Deployed${NC}"
    echo -e "${GREEN}✅ Application Wallet: Configured${NC}"
    echo ""
    echo -e "${BLUE}🌐 Network Information:${NC}"
    echo "   📍 Channel: certchannel"
    echo "   🏢 Organizations: Org1 (UniversityOrg), Org2 (StudentOrg)"
    echo "   📦 Chaincode: cert_cc (Go)"
    echo ""
    echo -e "${PURPLE}🚀 To start the web application:${NC}"
    echo -e "${YELLOW}   cd ../certificate-management-ui${NC}"
    echo -e "${YELLOW}   npm start${NC}"
    echo ""
    echo -e "${PURPLE}🌍 Application will be available at:${NC}"
    echo -e "${CYAN}   http://localhost:3000${NC}"
    echo ""
    echo -e "${BLUE}📚 Available API Endpoints:${NC}"
    echo "   POST /api/certificates - Issue certificate"
    echo "   GET  /api/certificates - Get all certificates" 
    echo "   GET  /api/certificates/:id - Get specific certificate"
    echo "   POST /api/certificates/:id/verify - Verify certificate"
    echo "   DELETE /api/certificates/:id - Revoke certificate"
    echo ""
    echo -e "${YELLOW}💡 To reset the network: ../scripts/setup.sh${NC}"
}

# Main execution flow
main() {
    echo -e "${BLUE}Starting setup process...${NC}"
    echo ""
    
    check_prerequisites
    cleanup_existing
    start_network
    deploy_chaincode  
    setup_application
    
    echo -e "${YELLOW}Performing final network test...${NC}"
    if test_network; then
        show_final_status
    else
        echo -e "${RED}Setup completed but network test failed. Please check the logs.${NC}"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "clean")
        echo -e "${YELLOW}Cleaning up network only...${NC}"
        cleanup_existing
        echo -e "${GREEN}✓ Cleanup complete${NC}"
        ;;
    "test")
        echo -e "${YELLOW}Testing network connectivity...${NC}"
        if test_network; then
            echo -e "${GREEN}✓ Network is healthy${NC}"
        else
            echo -e "${RED}❌ Network test failed${NC}"
            exit 1
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Hyperledger Fabric Certificate Management System Setup"
        echo ""
        echo "Usage:"
        echo "  ./setup.sh          # Complete setup and configuration"
        echo "  ./setup.sh clean    # Clean up existing network"
        echo "  ./setup.sh test     # Test network connectivity"
        echo "  ./setup.sh help     # Show this help message"
        echo ""
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use './setup.sh help' for usage information"
        exit 1
        ;;
esac
