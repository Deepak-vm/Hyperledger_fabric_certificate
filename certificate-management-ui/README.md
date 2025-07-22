# Certificate Management UI

A clean, organized web interface for the Hyperledger Fabric Certificate Management System.

## 🏗️ Project Structure

```
certificate-management-ui/
├── src/                          # Source code (organized by functionality)
│   ├── config/                   # Configuration files
│   │   └── organizations.js      # Organization and app configuration
│   ├── routes/                   # API route handlers
│   │   └── api.js               # Certificate management API routes
│   ├── services/                # Business logic services
│   │   └── fabricService.js     # Hyperledger Fabric blockchain service
│   └── utils/                   # Utility functions
│       └── walletUtils.js       # Wallet management utilities
├── public/                      # Static web assets
│   ├── index.html              # Main application page
│   └── js/                     # Client-side JavaScript
│       ├── app.js              # Frontend application logic
│       └── fix.js              # UI organization-specific features
├── wallet/                     # Blockchain identities (auto-generated)
│   ├── org1/                   # University organization wallet
│   ├── org2/                   # Student organization wallet
│   └── org3/                   # Verifier organization wallet
├── backup/                     # Old files (for reference)
├── server.js                   # Main application server
├── setupWallet.js             # Wallet setup utility
└── package.json               # Dependencies and scripts
```

## ✨ Key Features

### Clean Architecture
- **Separation of Concerns**: Config, routes, services, and utilities are separated
- **Modular Design**: Each component has a single responsibility
- **Easy Maintenance**: Clear structure makes updates and debugging easier

### Robust API
- **RESTful Endpoints**: Standard HTTP methods and status codes
- **Error Handling**: Comprehensive error responses with meaningful messages
- **Permission Control**: Organization-based access control
- **Status Monitoring**: Health checks and wallet status endpoints

### Smart Services
- **Fabric Service**: Handles all blockchain interactions
- **Wallet Utils**: Manages identity and wallet operations
- **Configuration**: Centralized organization and app settings

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Setup wallets for all organizations
npm run setup

# Start the application
npm start
```

## 📡 API Endpoints

### Certificate Management
- `GET /api/certificates` - Get all certificates
- `GET /api/certificates/:id` - Get specific certificate
- `POST /api/certificates` - Issue new certificate (UniversityOrg only)
- `POST /api/certificates/:id/verify` - Verify certificate
- `DELETE /api/certificates/:id` - Revoke certificate (UniversityOrg only)

### Organization & Status
- `POST /api/connect/:org` - Connect to organization (university|student|verifier)
- `GET /api/status` - Get API and blockchain status
- `POST /api/wallet/setup` - Setup wallets for all organizations
- `GET /health` - Health check endpoint

## 🏢 Organization Access Control

| Organization | Permissions | API Access |
|-------------|-------------|------------|
| **UniversityOrg** | Issue, Revoke, Verify, Query | Full API access |
| **StudentOrg** | Verify, Query | Read-only + verify |
| **VerifierOrg** | Verify, Query | Read-only + verify |

