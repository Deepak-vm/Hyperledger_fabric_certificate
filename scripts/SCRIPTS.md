# Essential Scripts Documentation

This directory contains the core script for managing the Hyperledger Fabric Certificate Management System.

## Available Script

### setup.sh
**Purpose**: Complete system setup and network management
**Usage**: 
```bash
cd test-network
../scripts/setup.sh [command]
```

**Commands**:
- `../scripts/setup.sh` - Full setup (network + chaincode + application)
- `../scripts/setup.sh clean` - Clean up existing network
- `../scripts/setup.sh test` - Test network connectivity  
- `../scripts/setup.sh help` - Show help information

**Description**: 
- Comprehensive setup script that handles everything
- Stops/cleans existing containers and resources
- Starts fresh Hyperledger Fabric network with certchannel
- Deploys cert_cc chaincode (Go-based certificate management)
- Sets up application wallet with admin identities
- Installs Node.js dependencies
- Performs connectivity and functionality tests
- Provides detailed status information

**Features**:
- ✅ Prerequisite checking (Docker, Node.js, npm)
- ✅ Intelligent cleanup and resource management
- ✅ Comprehensive error handling and reporting
- ✅ Network health testing and validation
- ✅ Color-coded output for easy reading
- ✅ Detailed final status and next steps

## Quick Start

```bash
# Initial setup
cd test-network
../scripts/setup.sh

# Start web application
cd ../certificate-management-ui  
npm start
```

## Troubleshooting

```bash
# Complete reset
cd test-network
../scripts/setup.sh clean
../scripts/setup.sh

# Test network health
../scripts/setup.sh test
```

## Requirements

- Docker & Docker Compose
- Node.js v16+
- npm
- Hyperledger Fabric binaries (in bin/)
- bash shell

## Usage Examples

```bash
# Complete setup from scratch
cd test-network
../scripts/setup.sh

# Clean and restart
../scripts/setup.sh clean
../scripts/setup.sh

# Start web application
cd ../certificate-management-ui
npm start
```

## ✅ Optimized Project Status

The project has been optimized with:
- ✅ Single essential script (setup.sh)
- ✅ Clean project structure
- ✅ No duplicate or unnecessary files
- ✅ Production-ready configuration
- ✅ Comprehensive error handling

**Essential Scripts**: 1 (was 46+ total scripts)
**Project Status**: Optimized & Production Ready  
**Last Updated**: July 22, 2025
