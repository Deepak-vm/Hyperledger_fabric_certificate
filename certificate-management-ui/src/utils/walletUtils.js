// Wallet utility functions
const { Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const { organizations } = require('../config/organizations');

class WalletUtils {
    /**
     * Setup wallet for an organization
     * @param {string} orgKey - Organization key (university, student, verifier)
     */
    static async setupWallet(orgKey) {
        try {
            const org = organizations[orgKey];
            if (!org) {
                throw new Error(`Unknown organization: ${orgKey}`);
            }

            // Create wallet directory if it doesn't exist
            const walletPath = org.walletPath;
            if (!fs.existsSync(walletPath)) {
                fs.mkdirSync(walletPath, { recursive: true });
            }

            // Create a new file system based wallet for managing identities
            const wallet = await Wallets.newFileSystemWallet(walletPath);

            // Check to see if we've already enrolled the admin user
            const adminExists = await wallet.get(org.identity);
            if (adminExists) {
                console.log(`An identity for the admin user "${org.identity}" already exists in the wallet for ${org.name}`);
                return wallet;
            }

            // Path to crypto materials for the organization
            const credPath = path.join(process.cwd(), 'test-network', 'organizations', 'peerOrganizations', `${orgKey === 'university' ? 'org1' : orgKey === 'student' ? 'org2' : 'org3'}.example.com`);
            const certPath = path.join(credPath, 'users', `Admin@${orgKey === 'university' ? 'org1' : orgKey === 'student' ? 'org2' : 'org3'}.example.com`, 'msp', 'signcerts');
            const keyPath = path.join(credPath, 'users', `Admin@${orgKey === 'university' ? 'org1' : orgKey === 'student' ? 'org2' : 'org3'}.example.com`, 'msp', 'keystore');

            // Check if crypto material exists
            if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
                throw new Error(`Crypto material not found for ${org.name} at ${credPath}. Make sure the network is running.`);
            }

            // Get certificate file
            const certFiles = fs.readdirSync(certPath);
            if (certFiles.length === 0) {
                throw new Error(`No certificate files found in ${certPath}`);
            }
            const cert = fs.readFileSync(path.join(certPath, certFiles[0])).toString();

            // Get private key file
            const keyFiles = fs.readdirSync(keyPath);
            if (keyFiles.length === 0) {
                throw new Error(`No private key files found in ${keyPath}`);
            }
            const key = fs.readFileSync(path.join(keyPath, keyFiles[0])).toString();

            // Import the admin identity
            const identity = {
                credentials: {
                    certificate: cert,
                    privateKey: key,
                },
                mspId: org.mspId,
                type: 'X.509',
            };

            await wallet.put(org.identity, identity);
            console.log(`Successfully imported ${org.identity} identity for ${org.name} to the wallet`);

            return wallet;
        } catch (error) {
            console.error(`Error setting up wallet for ${orgKey}: ${error.message}`);
            throw error;
        }
    }

    /**
     * Setup wallets for all organizations
     */
    static async setupAllWallets() {
        try {
            const results = {};
            for (const orgKey of Object.keys(organizations)) {
                try {
                    results[orgKey] = await WalletUtils.setupWallet(orgKey);
                    console.log(`✓ Wallet setup completed for ${organizations[orgKey].name}`);
                } catch (error) {
                    console.error(`✗ Failed to setup wallet for ${organizations[orgKey].name}: ${error.message}`);
                    // Continue with other organizations even if one fails
                }
            }
            return results;
        } catch (error) {
            console.error(`Error setting up wallets: ${error.message}`);
            throw error;
        }
    }

    /**
     * Validate wallet exists and has required identity
     * @param {string} orgKey - Organization key
     */
    static async validateWallet(orgKey) {
        try {
            const org = organizations[orgKey];
            if (!org) {
                return { valid: false, error: `Unknown organization: ${orgKey}` };
            }

            const walletPath = org.walletPath;
            if (!fs.existsSync(walletPath)) {
                return { valid: false, error: `Wallet directory does not exist: ${walletPath}` };
            }

            const wallet = await Wallets.newFileSystemWallet(walletPath);
            const identity = await wallet.get(org.identity);

            if (!identity) {
                return { valid: false, error: `Identity ${org.identity} not found in wallet` };
            }

            return { valid: true, identity, wallet };
        } catch (error) {
            return { valid: false, error: error.message };
        }
    }

    /**
     * Get wallet status for all organizations
     */
    static async getWalletStatus() {
        const status = {};
        for (const orgKey of Object.keys(organizations)) {
            const validation = await WalletUtils.validateWallet(orgKey);
            status[orgKey] = {
                organization: organizations[orgKey].name,
                valid: validation.valid,
                error: validation.error || null
            };
        }
        return status;
    }

    /**
     * Clean/remove wallet for an organization
     * @param {string} orgKey - Organization key
     */
    static async cleanWallet(orgKey) {
        try {
            const org = organizations[orgKey];
            if (!org) {
                throw new Error(`Unknown organization: ${orgKey}`);
            }

            const walletPath = org.walletPath;
            if (fs.existsSync(walletPath)) {
                fs.rmSync(walletPath, { recursive: true, force: true });
                console.log(`Wallet cleaned for ${org.name}`);
                return true;
            }

            return false;
        } catch (error) {
            console.error(`Error cleaning wallet for ${orgKey}: ${error.message}`);
            throw error;
        }
    }
}

module.exports = WalletUtils;
