# Optimized Project Structure

This document describes the clean, production-ready structure of the Hyperledger Fabric Certificate Management System.

## Directory Structure

```
Hyperledger_fabric_certificate-main/
├── README.md                     # Main documentation
├── STRUCTURE.md                  # This file
├── bin/                         # Hyperledger Fabric binaries
│   ├── configtxgen
│   ├── cryptogen
│   ├── peer
│   ├── orderer
│   └── ...
├── builders/                    # Chaincode builders for external builders
├── certificate-management-ui/   # Web application (Essential)
│   ├── app.js                   # Main Express server
│   ├── package.json            # Dependencies
│   ├── setupWallet.js          # Wallet setup script
│   ├── issue-certificate.js    # Certificate issuing logic
│   ├── public/                 # Frontend assets
│   │   ├── index.html
│   │   ├── styles.css
│   │   └── js/
│   ├── routes/                 # API routes
│   └── wallet/                 # Application identities
├── config/                     # Fabric configuration files
├── scripts/                    # Essential scripts only
│   ├── reset_network.sh        # Complete network reset (ESSENTIAL)
│   └── SCRIPTS.md             # Script documentation
└── test-network/              # Hyperledger Fabric test network
    ├── network.sh              # Network management (ESSENTIAL)
    ├── chaincode/cert_cc/go/   # Certificate management chaincode
    ├── scripts/                # Core network scripts only
    │   ├── utils.sh
    │   ├── envVar.sh
    │   ├── ccutils.sh
    │   ├── createChannel.sh
    │   ├── deployCC.sh
    │   ├── configUpdate.sh
    │   └── setAnchorPeer.sh
    ├── organizations/          # Crypto materials
    └── compose/               # Docker compose files
```

## Removed Files

### From Root:
- `report.md` - Development report, not needed for production
- `.editorconfig` - IDE specific, not essential

### From certificate-management-ui/:
- `fix_chaincode.sh` - Temporary fix script
- `fix_couchdb.sh` - Temporary fix script  
- `fix_query_error.sh` - Temporary fix script
- `setupOrg3.sh` - Org3 setup (optional feature)
- `issue_certificate.sh` - Duplicate functionality
- `test-issue.js` - Test file
- `test-query.js` - Test file
- `cli-helper.js` - Unused helper
- `connection-org3.json` - Org3 specific config (optional)
- `initCertificate.js` - Duplicate functionality
- `README.md` - Duplicate documentation
- `test-network/` - Duplicate of main test-network

### From scripts/:
- `analyze_project.sh` - Development-only script
- `cleanup_project.sh` - Consolidated into optimize_project.sh
- `final_cleanup.sh` - Consolidated into optimize_project.sh
- `fix_discovery_access.sh` - Temporary fix script
- `fix_org3_access.sh` - Temporary fix script
- `quick_start.sh` - Functionality moved to reset_network.sh

### From test-network/scripts/:
- `deployCCAAS.sh` - Chaincode-as-a-service (not used)
- `packageCC.sh` - Packaging handled by deployCC.sh
- `pkgcc.sh` - Alternative packaging (not used)

## Key Benefits

1. **Reduced Size**: Significant reduction in project size
2. **Clear Structure**: Easy to understand and navigate
3. **Essential Scripts Only**: Only production-ready scripts remain
4. **No Duplicates**: Removed all duplicate files and directories
5. **Clean Documentation**: Updated documentation reflects actual structure

## Quick Start

```bash
# Start the network and deploy chaincode
cd test-network
./scripts/../scripts/reset_network.sh

# Start the web application
cd ../certificate-management-ui  
npm start
```

## Maintenance

The project now contains only essential files needed for:
- Network setup and management
- Chaincode deployment and management
- Web application functionality
- Basic troubleshooting and reset capabilities

All development and testing artifacts have been removed for production use.
