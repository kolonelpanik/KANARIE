// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "./FlashLoanArbitrage.sol";

contract DeployFlashLoanArbitrage is Script {
    function getPoolAddress(uint256 chainId) internal pure returns (address) {
        if (chainId == 1) return 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2; // Ethereum Mainnet
        if (chainId == 42161) return 0x794a61358D6845594F94dc1DB02A252b5b4814aD; // Arbitrum
        if (chainId == 10) return 0x794a61358D6845594F94dc1DB02A252b5b4814aD; // Optimism
        if (chainId == 137) return 0x794a61358D6845594F94dc1DB02A252b5b4814aD; // Polygon
        revert("Unsupported chain ID");
    }

    function run() external {
        // Load private key and profit wallet from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address profitWallet = vm.envAddress("PROFIT_WALLET");

        // Determine the Aave Pool address based on the current chain ID
        address aavePool = getPoolAddress(block.chainid);

        // Begin broadcast for deployment
        vm.startBroadcast(deployerPrivateKey);

        // Deploy FlashLoanArbitrage contract
        FlashLoanArbitrage flashLoanArbitrage = new FlashLoanArbitrage(aavePool, profitWallet);

        console.log("Deployed FlashLoanArbitrage contract at:", address(flashLoanArbitrage));

        // End broadcast
        vm.stopBroadcast();
    }
}
