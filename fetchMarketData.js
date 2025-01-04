// Javconst { UiPoolDataProvider, UiIncentiveDataProvider } = require('@aave/contract-helpers');
const { ethers } = require('ethers');

// Replace this with your Infura or Alchemy RPC URL
const provider = new ethers.providers.JsonRpcProvider('https://mainnet.infura.io/v3/03cebe177b4746e790f893ec76ec608d');

// Replace these addresses with the Aave V3 contract addresses for the network you're using
const uiPoolDataProviderAddress = '0xBA6378f1c1D046e9EB0F538560BA7558546edF3C'; // PoolDataProvider (Optimism example)
const lendingPoolAddressProvider = '0xC539E0A5e5C9A79D69fB44cA6E3A2D7700300374'; // LendingPoolAddressesProvider

// Initialize the UiPoolDataProvider
const poolDataProvider = new UiPoolDataProvider({
    uiPoolDataProviderAddress,
    provider,
});

async function fetchMarketData() {
    try {
        // Fetch reserves data from the Aave V3 protocol
        const reservesData = await poolDataProvider.getReservesHumanized({
            lendingPoolAddressProvider,
        });

        console.log('Reserves Data:', reservesData);
    } catch (error) {
        console.error('Error fetching market data:', error);
    }
}

// Run the function
fetchMarketData();
