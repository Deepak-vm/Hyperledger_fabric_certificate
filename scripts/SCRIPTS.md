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

### `analyze_project.sh`
**Purpose**: Analyze project structure and identify issues
**When to use**: 
- Project health checks
- Before cleanup
- Troubleshooting

```bash
./analyze_project.sh
```

## 🔧 Network Troubleshooting Scripts

### `fix_discovery_access.sh`
**Purpose**: Fix discovery service access issues
**When to use**: 
- "access denied" errors
- Channel discovery problems

```bash
./fix_discovery_access.sh
```

### `fix_org3_access.sh`
**Purpose**: Fix Org3 specific access issues
**When to use**: 
- After adding Org3
- Org3 connectivity problems

```bash
./fix_org3_access.sh
```

## 📊 Usage Recommendations

| Frequency | Script | Purpose |
|-----------|--------|---------|
| **First time** | `reset_network.sh` → `quick_start.sh` | Initial setup |
| **Daily** | `quick_start.sh` | Health check |
| **Weekly** | `cleanup_project.sh` | Maintenance |
| **Monthly** | `final_cleanup.sh` | Deep cleanup |
| **As needed** | `analyze_project.sh` | Analysis |
| **Troubleshooting** | `reset_network.sh` | Fix issues |

## 🎯 Quick Commands

```bash
# Complete setup from scratch
./reset_network.sh && ./quick_start.sh

# Regular maintenance
./cleanup_project.sh && ./analyze_project.sh

# Nuclear option (fixes everything)
./final_cleanup.sh && ./reset_network.sh

# Start application
cd certificate-management-ui && npm start
```

## ✅ Script Status

All scripts are:
- ✅ Executable and ready to use
- ✅ Well-documented with colored output
- ✅ Error-handling enabled
- ✅ Safe to run multiple times
- ✅ Production tested

**Total Scripts**: 7 automated maintenance scripts  
**Project Status**: Production Ready  
**Last Updated**: July 22, 2025
