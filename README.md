# Hyperledger Fabric Certificate Management System

## Overview

This project implements a **Digital Certificate Management System** using Hyperledger Fabric blockchain technology. The system provides a secure, decentralized platform for issuing, verifying, and managing digital certificates with role-based access control across multiple organizations.


## Quick Start

### 🚀 One-Click Setup
```bash
# Navigate to project directory
cd /path/to/Hyperledger_fabric_certificate-main

# Complete setup (network + chaincode + application)
cd test-network
../scripts/setup.sh

# Start the certificate management application
cd ../certificate-management-ui
npm start
```
**Application will be available at: http://localhost:3000**

### 🧹 Project Maintenance
```bash
# Clean and reset network
cd test-network
../scripts/setup.sh clean

# Test network connectivity
../scripts/setup.sh test

# Get help
../scripts/setup.sh help
```

## Architecture

### Network Structure
The system uses a **multi-organization blockchain network**:

- **UniversityOrg (Org1MSP)** - Port 7051
  - **Role**: Certificate Issuer
  - **Permissions**: Issue, verify, revoke, and query certificates
  - **MSP ID**: `Org1MSP`

- **StudentOrg (Org2MSP)** - Port 9051  
  - **Role**: Certificate Consumer
  - **Permissions**: Verify and query certificates (read-only)
  - **MSP ID**: `Org2MSP`

- **VerifierOrg (Org3MSP)** - Port 11051 *(Optional)*
  - **Role**: Certificate Verifier
  - **Permissions**: Verify and query certificates (read-only)
  - **MSP ID**: `Org3MSP`

### Components

1. **Hyperledger Fabric Network**
   - Multi-org permissioned blockchain
   - TLS-enabled secure communication
   - Channel: `certchannel`
   - Orderer: `orderer.example.com:7050`

2. **Smart Contract (Chaincode)**
   - Name: `cert_cc`
   - Language: Go
   - Version: 1.0
   - Location: `/test-network/chaincode/cert_cc/go/`

3. **Web Interface**
   - Node.js Express application
   - REST API endpoints
   - Organization-specific features
   - Location: `/certificate-management-ui/`

4. **Automated Scripts**
   - `reset_network.sh` - Complete network reset and restart
   - `cleanup_project.sh` - Remove temporary files and optimize
   - `analyze_project.sh` - Project structure analysis
   - `fix_discovery_access.sh` - Fix network connectivity issues

## Prerequisites

- **Docker & Docker Compose**: Latest version
- **Node.js**: v16 or higher
- **Git**: For cloning and version control
- **npm**: Package manager
- **Hyperledger Fabric**: v2.5.12
- **Go**: v1.19 or higher (for chaincode development)

## Installation & Setup

### Automated Scripts

```bash
# Complete setup - handles everything
cd test-network
../scripts/setup.sh

# Clean network and containers
../scripts/setup.sh clean

# Test network connectivity
../scripts/setup.sh test

# Show help and usage
../scripts/setup.sh help
```

### Method 2: Manual Step-by-Step Setup

```bash
# 1. Clone the repository
git clone https://github.com/Deepak-vm/Hyperledger_fabric_certificate.git
cd Hyperledger_fabric_certificate-main

# 2. Start the network
cd test-network
./network.sh up createChannel -c certchannel -ca

# 3. Deploy the chaincode
./network.sh deployCC -c certchannel -ccn cert_cc -ccp chaincode/cert_cc/go -ccl go

# 4. Setup application wallet
cd ../certificate-management-ui
npm install
npm run setup

# 5. Start the application
npm start
```

**Application will be available at:** <http://localhost:3000>

## Project Structure

```
Hyperledger_fabric_certificate-main/
├── bin/                          # Hyperledger Fabric binaries
├── config/                       # Fabric configuration files
├── test-network/                 # Fabric test network
│   ├── chaincode/cert_cc/go/     # Certificate chaincode
│   ├── organizations/            # Crypto materials
│   ├── scripts/                  # Core network scripts
│   └── network.sh                # Network management
├── certificate-management-ui/    # Web application (modular structure)
│   ├── src/                      # Organized source code
│   │   ├── config/               # Configuration files
│   │   ├── routes/               # API route handlers
│   │   ├── services/             # Business logic services
│   │   └── utils/                # Utility functions
│   ├── public/                   # Frontend assets
│   ├── wallet/                   # Application identities
│   ├── server.js                 # Main application server
│   ├── setupWallet.js            # Wallet setup utility
│   └── package.json              # Dependencies
├── builders/                     # Chaincode builders
├── scripts/                      # Essential scripts
│   ├── setup.sh                  # Complete setup script
│   └── SCRIPTS.md                # Script documentation
├── README.md                     # This file
└── STRUCTURE.md                  # Detailed structure guide
```

## Starting the Application

```bash
# Navigate to UI directory
cd certificate-management-ui

# Install dependencies
npm install

# Setup wallets for all organizations
npm run setup

# Start the application
npm start
```

**Application will be available at:** `http://localhost:3000`

### Available npm Scripts

- `npm start` - Start the application server
- `npm run setup` - Setup wallets for all organizations  
- `npm run dev` - Start in development mode (with file watching)
- `npm test` - Run tests (if available)

## Chaincode Functions

### Certificate Structure
```go
type Certificate struct {
    CertID    string `json:"certID"`
    StudentID string `json:"studentID"`
    CertHash  string `json:"certHash"`
    Issuer    string `json:"issuer"`
}
```

### Core Functions

#### 1. **IssueCertificate**
- **Description**: Issues a new digital certificate
- **Access Control**: Only UniversityOrg (Org1MSP)
- **Parameters**: `studentID`, `certID`, `certHash`, `issuer`
- **CLI Usage**:
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "$ORDERER_CA" -C certchannel -n cert_cc \
  --peerAddresses localhost:7051 --tlsRootCertFiles "$ORG1_CA" \
  --peerAddresses localhost:9051 --tlsRootCertFiles "$ORG2_CA" \
  -c '{"function":"IssueCertificate","Args":["student001","cert001","hash001","UniversityOrg"]}'
```

#### 2. **VerifyCertificate**
- **Description**: Verifies if a certificate exists
- **Access Control**: All organizations
- **Parameters**: `certID`
- **Returns**: Boolean verification status
- **CLI Usage**:
```bash
peer chaincode query -C certchannel -n cert_cc \
  -c '{"function":"VerifyCertificate","Args":["cert001"]}'
```

#### 3. **GetCertificate**
- **Description**: Retrieves certificate details
- **Access Control**: All organizations
- **Parameters**: `certID`
- **Returns**: Certificate object with full details
- **CLI Usage**:
```bash
peer chaincode query -C certchannel -n cert_cc \
  -c '{"function":"GetCertificate","Args":["cert001"]}'
```

#### 4. **GetAllCertificates**
- **Description**: Retrieves all certificates from the ledger
- **Access Control**: All organizations
- **Parameters**: None
- **CLI Usage**:
```bash
peer chaincode query -C certchannel -n cert_cc \
  -c '{"function":"GetAllCertificates","Args":[]}'
```

#### 5. **RevokeCertificate**
- **Description**: Removes a certificate from the ledger
- **Access Control**: Only UniversityOrg (Org1MSP)
- **Parameters**: `certID`
- **CLI Usage**:
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "$ORDERER_CA" -C certchannel -n cert_cc \
  --peerAddresses localhost:7051 --tlsRootCertFiles "$ORG1_CA" \
  -c '{"function":"RevokeCertificate","Args":["cert001"]}'
```


### REST API Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| `POST` | `/api/certificates` | Issue a new certificate | UniversityOrg only |
| `GET` | `/api/certificates` | Get all certificates | All orgs |
| `GET` | `/api/certificates/:id` | Get specific certificate | All orgs |
| `POST` | `/api/certificates/:id/verify` | Verify a certificate | All orgs |
| `DELETE` | `/api/certificates/:id` | Revoke a certificate | UniversityOrg only |
| `POST` | `/api/connect/:org` | Connect to organization | All orgs |
| `GET` | `/api/status` | Get API and blockchain status | All orgs |
| `POST` | `/api/wallet/setup` | Setup wallets for all organizations | All orgs |
| `GET` | `/health` | Health check endpoint | All orgs |

### Organization-Specific Features

The web interface adapts based on the organization:

- **UniversityOrg**: Full access including issue and revoke buttons
- **StudentOrg/VerifierOrg**: Read-only access with verify functionality

### Key Files
- **Main Server**: `certificate-management-ui/server.js`
- **API Routes**: `certificate-management-ui/src/routes/api.js`
- **Fabric Service**: `certificate-management-ui/src/services/fabricService.js`
- **Wallet Utils**: `certificate-management-ui/src/utils/walletUtils.js`
- **Configuration**: `certificate-management-ui/src/config/organizations.js`
- **Frontend Logic**: `certificate-management-ui/public/js/app.js`
- **Organization-specific UI**: `certificate-management-ui/public/js/fix.js`

## Testing

### Automated Testing Script
```bash
cd test-network
./scripts/test_certificate_system.sh
```

### Manual Testing Steps

1. **Issue a Certificate** (as UniversityOrg):
```bash
./scripts/setEnv.sh 1  # Set Org1 environment
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "$ORDERER_CA" -C certchannel -n cert_cc \
  --peerAddresses localhost:7051 --tlsRootCertFiles "$ORG1_CA" \
  -c '{"function":"IssueCertificate","Args":["student001","cert001","hash001","UniversityOrg"]}'
```

2. **Verify Certificate** (as any org):
```bash
peer chaincode query -C certchannel -n cert_cc \
  -c '{"function":"VerifyCertificate","Args":["cert001"]}'
```

3. **Test Access Control** (as StudentOrg - should fail):
```bash
./scripts/setEnv.sh 2  # Set Org2 environment
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
  --tls --cafile "$ORDERER_CA" -C certchannel -n cert_cc \
  --peerAddresses localhost:9051 --tlsRootCertFiles "$ORG2_CA" \
  -c '{"function":"IssueCertificate","Args":["student002","cert002","hash002","StudentOrg"]}'
```

## Access Control Matrix

| Operation | UniversityOrg | StudentOrg | VerifierOrg |
|-----------|---------------|------------|-------------|
| Issue Certificate | ✅ | ❌ | ❌ |
| Verify Certificate | ✅ | ✅ | ✅ |
| Get Certificate | ✅ | ✅ | ✅ |
| Get All Certificates | ✅ | ✅ | ✅ |
| Revoke Certificate | ✅ | ❌ | ❌ |

## Security Features

1. **Role-Based Access Control**: MSP-based organization identity verification
2. **TLS Communication**: All peer-to-peer communication is encrypted
3. **Digital Signatures**: All transactions are cryptographically signed
4. **Immutable Ledger**: Certificate history is tamper-proof
5. **Multi-Organization Consensus**: Transactions require endorsement from multiple peers

## Project Structure

```
Hyperledger_fabric_certificate-main/                    # Hyperledger Fabric network
├── test-network/                    # Hyperledger Fabric network
│   ├── network.sh                   # Network management script
│   ├── deploy_test.sh              # Chaincode deployment script
│   ├── chaincode/cert_cc/go/       # Certificate management chaincode
│   ├── scripts/                    # Utility scripts
│   └── organizations/              # Crypto material for orgs
├── certificate-management-ui/      # Web interface (modular structure)
│   ├── src/                        # Organized source code
│   │   ├── config/                 # Configuration files
│   │   │   └── organizations.js    # Organization and app configuration
│   │   ├── routes/                 # API route handlers
│   │   │   └── api.js              # Certificate management API routes
│   │   ├── services/               # Business logic services
│   │   │   └── fabricService.js    # Blockchain interaction service
│   │   └── utils/                  # Utility functions
│   │       └── walletUtils.js      # Wallet management utilities
│   ├── public/                     # Frontend assets
│   │   ├── index.html              # Main application page
│   │   └── js/                     # Client-side JavaScript
│   │       ├── app.js              # Frontend application logic
│   │       └── fix.js              # Organization-specific features
│   ├── wallet/                     # Blockchain identities
│   ├── server.js                   # Main application server
│   ├── setupWallet.js              # Wallet setup utility
│   └── package.json                # Node.js dependencies
├── bin/                            # Fabric binaries
├── config/                         # Configuration files
├── scripts/                        # Essential project scripts
│   ├── setup.sh                    # Complete setup script
│   └── SCRIPTS.md                  # Script documentation
└── README.md                       # This file
```

## Troubleshooting

### Quick Fixes

#### 🔧 Network Connectivity Issues
```bash
# Complete network reset (fixes 90% of issues)
cd test-network
../scripts/setup.sh clean
../scripts/setup.sh
```

#### 🧹 Test Network Health
```bash
# Check network status and connectivity
cd test-network
../scripts/setup.sh test
```

#### 📊 Get Help and Usage Information
```bash
# Show all available commands and options
cd test-network
../scripts/setup.sh help
```

### Common Issues & Solutions

| Issue | Solution | Command |
|-------|----------|---------|
| **Peer connection failed** | Reset network | `cd test-network && ../scripts/setup.sh` |
| **Channel not found** | Complete setup | `cd test-network && ../scripts/setup.sh` |
| **Chaincode not found** | Redeploy chaincode | `cd test-network && ../scripts/setup.sh` |
| **Docker issues** | Clean containers | `cd test-network && ../scripts/setup.sh clean` |
| **Wallet errors** | Regenerate wallet | `cd test-network && ../scripts/setup.sh` |
| **Port conflicts** | Clean and restart | `cd test-network && ../scripts/setup.sh clean && ../scripts/setup.sh` |

### Error Messages & Fixes

#### "creator org unknown, creator is malformed"
```bash
# Regenerate crypto material
cd test-network
./network.sh down
rm -rf organizations/peerOrganizations organizations/ordererOrganizations
./network.sh up createChannel -c certchannel -ca
```

#### "Failed to connect before the deadline"
```bash
# Check if containers are running
docker ps

# If no containers, restart network
./reset_network.sh
```

#### "Identity not found in wallet"
```bash
cd certificate-management-ui
rm -rf wallet/
npm run setup
```



### Monitoring

- **Check container status**: `docker ps`
- **View logs**: `docker logs <container_name>`
- **Monitor resources**: `docker stats`

### Backup & Recovery

```bash
# Backup important data
tar -czf backup.tar.gz test-network/organizations certificate-management-ui/wallet certificate-management-ui/src

# Restore from backup
tar -xzf backup.tar.gz
```


#### Directory Structure
- **`src/config/`**: Organization configurations and app settings
- **`src/routes/`**: API route handlers and endpoint definitions
- **`src/services/`**: Business logic and blockchain interaction services
- **`src/utils/`**: Utility functions and helper methods
- **`server.js`**: Main application entry point (replaces `app.js`)
- **`setupWallet.js`**: Simplified wallet setup using modular utilities





## Support

For issues and questions:

1. Check the [troubleshooting section](#troubleshooting)
2. Run the analysis script: `./analyze_project.sh`
3. Reset the network: `./reset_network.sh`
4. Create an issue on GitHub







