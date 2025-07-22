// Fabric service to handle blockchain interactions
const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { organizations, appConfig } = require('../config/organizations');

class FabricService {
    constructor() {
        this.gateway = new Gateway();
        this.network = null;
        this.contract = null;
        this.currentOrg = null;
    }

    /**
     * Connect to the Hyperledger Fabric network
     * @param {string} orgKey - Organization key (university, student, verifier)
     */
    async connect(orgKey) {
        try {
            const org = organizations[orgKey];
            if (!org) {
                throw new Error(`Unknown organization: ${orgKey}`);
            }

            // Load the network configuration
            const ccpPath = org.connectionProfilePath;
            const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

            // Create a new file system based wallet for managing identities
            const walletPath = org.walletPath;
            const wallet = await Wallets.newFileSystemWallet(walletPath);

            // Check to see if we've already enrolled the admin user
            const identity = await wallet.get(org.identity);
            if (!identity) {
                throw new Error(`An identity for the user "${org.identity}" does not exist in the wallet at ${walletPath}. Run the enrollAdmin.js application before retrying`);
            }

            // Create a new gateway instance for interacting with the fabric network
            const connectionOptions = {
                wallet,
                identity: org.identity,
                discovery: { enabled: true, asLocalhost: true }
            };

            // Connect to the gateway
            await this.gateway.connect(ccp, connectionOptions);

            // Get the network (channel) our contract is deployed to
            this.network = await this.gateway.getNetwork(appConfig.channelName);

            // Get the contract from the network
            this.contract = this.network.getContract(appConfig.chaincodeName);

            this.currentOrg = orgKey;
            console.log(`Successfully connected to fabric network as ${org.name}`);

            return true;
        } catch (error) {
            console.error(`Failed to connect to fabric network: ${error.message}`);
            throw error;
        }
    }

    /**
     * Disconnect from the fabric network
     */
    async disconnect() {
        try {
            if (this.gateway) {
                await this.gateway.disconnect();
                this.network = null;
                this.contract = null;
                this.currentOrg = null;
                console.log('Disconnected from fabric network');
            }
        } catch (error) {
            console.error(`Error disconnecting from fabric network: ${error.message}`);
            throw error;
        }
    }

    /**
     * Issue a new certificate
     * @param {string} studentId - Student ID
     * @param {string} certId - Certificate ID
     * @param {string} certHash - Certificate hash
     * @param {string} issuer - Issuer name
     */
    async issueCertificate(studentId, certId, certHash, issuer) {
        try {
            if (this.currentOrg !== 'university') {
                throw new Error('Only UniversityOrg can issue certificates');
            }

            const result = await this.contract.submitTransaction('IssueCertificate', studentId, certId, certHash, issuer);
            console.log('Certificate issued successfully');
            return JSON.parse(result.toString());
        } catch (error) {
            console.error(`Failed to issue certificate: ${error.message}`);
            throw error;
        }
    }

    /**
     * Get all certificates
     */
    async getAllCertificates() {
        try {
            const result = await this.contract.evaluateTransaction('GetAllCertificates');
            return JSON.parse(result.toString());
        } catch (error) {
            console.error(`Failed to get all certificates: ${error.message}`);
            throw error;
        }
    }

    /**
     * Get a specific certificate by ID
     * @param {string} certId - Certificate ID
     */
    async getCertificate(certId) {
        try {
            const result = await this.contract.evaluateTransaction('GetCertificate', certId);
            return JSON.parse(result.toString());
        } catch (error) {
            console.error(`Failed to get certificate: ${error.message}`);
            throw error;
        }
    }

    /**
     * Verify a certificate
     * @param {string} certId - Certificate ID
     */
    async verifyCertificate(certId) {
        try {
            const result = await this.contract.evaluateTransaction('VerifyCertificate', certId);
            return result.toString() === 'true';
        } catch (error) {
            console.error(`Failed to verify certificate: ${error.message}`);
            throw error;
        }
    }

    /**
     * Revoke a certificate
     * @param {string} certId - Certificate ID
     */
    async revokeCertificate(certId) {
        try {
            if (this.currentOrg !== 'university') {
                throw new Error('Only UniversityOrg can revoke certificates');
            }

            const result = await this.contract.submitTransaction('RevokeCertificate', certId);
            console.log('Certificate revoked successfully');
            return result.toString();
        } catch (error) {
            console.error(`Failed to revoke certificate: ${error.message}`);
            throw error;
        }
    }

    /**
     * Get the current organization
     */
    getCurrentOrganization() {
        return this.currentOrg ? organizations[this.currentOrg] : null;
    }

    /**
     * Check if current organization has specific permissions
     * @param {string} permission - Permission to check (issue, revoke, verify, query)
     */
    hasPermission(permission) {
        if (!this.currentOrg) return false;

        const permissions = {
            university: ['issue', 'revoke', 'verify', 'query'],
            student: ['verify', 'query'],
            verifier: ['verify', 'query']
        };

        return permissions[this.currentOrg] && permissions[this.currentOrg].includes(permission);
    }
}

module.exports = FabricService;
