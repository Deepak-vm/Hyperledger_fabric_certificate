
const WalletUtils = require('./src/utils/walletUtils');

async function setupWallets() {
    console.log('🔧 Setting up wallets for all organizations...');

    try {
        await WalletUtils.setupAllWallets();
        console.log('✅ All wallets setup completed successfully!');
    } catch (error) {
        console.error('❌ Failed to setup wallets:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    setupWallets();
}

module.exports = setupWallets;
