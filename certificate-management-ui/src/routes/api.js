// Certificate management API routes
const express = require('express');
const router = express.Router();
const FabricService = require('../services/fabricService');
const WalletUtils = require('../utils/walletUtils');

// Initialize fabric service
let fabricService = null;

// Middleware to ensure fabric connection
const ensureConnection = async (req, res, next) => {
    try {
        if (!fabricService) {
            fabricService = new FabricService();
        }

        // Default to university organization if not connected
        if (!fabricService.currentOrg) {
            await fabricService.connect('university');
        }

        req.fabricService = fabricService;
        next();
    } catch (error) {
        res.status(500).json({
            error: 'Failed to connect to blockchain network',
            message: error.message
        });
    }
};

/**
 * GET /api/certificates
 * Get all certificates
 */
router.get('/certificates', ensureConnection, async (req, res) => {
    try {
        const certificates = await req.fabricService.getAllCertificates();
        res.json({
            success: true,
            data: certificates,
            organization: req.fabricService.getCurrentOrganization()?.name
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve certificates',
            message: error.message
        });
    }
});

/**
 * GET /api/certificates/:id
 * Get a specific certificate by ID
 */
router.get('/certificates/:id', ensureConnection, async (req, res) => {
    try {
        const { id } = req.params;
        const certificate = await req.fabricService.getCertificate(id);

        res.json({
            success: true,
            data: certificate,
            organization: req.fabricService.getCurrentOrganization()?.name
        });
    } catch (error) {
        res.status(404).json({
            success: false,
            error: 'Certificate not found',
            message: error.message
        });
    }
});

/**
 * POST /api/certificates
 * Issue a new certificate (UniversityOrg only)
 */
router.post('/certificates', ensureConnection, async (req, res) => {
    try {
        const { studentId, certId, certHash, issuer } = req.body;

        // Validate required fields
        if (!studentId || !certId || !certHash || !issuer) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields',
                required: ['studentId', 'certId', 'certHash', 'issuer']
            });
        }

        // Check permissions
        if (!req.fabricService.hasPermission('issue')) {
            return res.status(403).json({
                success: false,
                error: 'Permission denied',
                message: 'Only UniversityOrg can issue certificates'
            });
        }

        const result = await req.fabricService.issueCertificate(studentId, certId, certHash, issuer);

        res.status(201).json({
            success: true,
            message: 'Certificate issued successfully',
            data: result,
            organization: req.fabricService.getCurrentOrganization()?.name
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to issue certificate',
            message: error.message
        });
    }
});

/**
 * POST /api/certificates/:id/verify
 * Verify a certificate
 */
router.post('/certificates/:id/verify', ensureConnection, async (req, res) => {
    try {
        const { id } = req.params;
        const isValid = await req.fabricService.verifyCertificate(id);

        res.json({
            success: true,
            verified: isValid,
            certificateId: id,
            organization: req.fabricService.getCurrentOrganization()?.name
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to verify certificate',
            message: error.message
        });
    }
});

/**
 * DELETE /api/certificates/:id
 * Revoke a certificate (UniversityOrg only)
 */
router.delete('/certificates/:id', ensureConnection, async (req, res) => {
    try {
        const { id } = req.params;

        // Check permissions
        if (!req.fabricService.hasPermission('revoke')) {
            return res.status(403).json({
                success: false,
                error: 'Permission denied',
                message: 'Only UniversityOrg can revoke certificates'
            });
        }

        const result = await req.fabricService.revokeCertificate(id);

        res.json({
            success: true,
            message: 'Certificate revoked successfully',
            certificateId: id,
            organization: req.fabricService.getCurrentOrganization()?.name
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to revoke certificate',
            message: error.message
        });
    }
});

/**
 * POST /api/connect/:org
 * Connect to a specific organization
 */
router.post('/connect/:org', async (req, res) => {
    try {
        const { org } = req.params;

        if (!['university', 'student', 'verifier'].includes(org)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid organization',
                message: 'Organization must be: university, student, or verifier'
            });
        }

        if (!fabricService) {
            fabricService = new FabricService();
        }

        // Disconnect if already connected
        if (fabricService.currentOrg) {
            await fabricService.disconnect();
        }

        await fabricService.connect(org);

        res.json({
            success: true,
            message: `Connected to ${fabricService.getCurrentOrganization()?.name}`,
            organization: fabricService.getCurrentOrganization()
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to connect to organization',
            message: error.message
        });
    }
});

/**
 * GET /api/status
 * Get API and blockchain status
 */
router.get('/status', async (req, res) => {
    try {
        const walletStatus = await WalletUtils.getWalletStatus();
        const connected = fabricService && fabricService.currentOrg;

        res.json({
            success: true,
            status: {
                connected,
                currentOrganization: connected ? fabricService.getCurrentOrganization() : null,
                wallets: walletStatus
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to get status',
            message: error.message
        });
    }
});

/**
 * POST /api/wallet/setup
 * Setup wallets for all organizations
 */
router.post('/wallet/setup', async (req, res) => {
    try {
        await WalletUtils.setupAllWallets();

        res.json({
            success: true,
            message: 'Wallets setup completed'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to setup wallets',
            message: error.message
        });
    }
});

module.exports = router;
