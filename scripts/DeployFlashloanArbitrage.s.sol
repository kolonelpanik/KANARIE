// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/FlashLoanArbitrage.sol"; // Correct import path and contract name

/**
 * @title DeployFlashLoanArbitrage
 * @dev Script to deploy the FlashLoanArbitrage contract.
 */
contract DeployFlashLoanArbitrage is Script {
    function run() external {
        vm.startBroadcast();

        // Constructor arguments for FlashLoanArbitrage
        address aavePool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD; // Aave pool address
        address profitWallet = 0xFaBe086a37A1f5556e49F2aFc2BeC0A131E19Ed4; // Replace with your profit wallet address

        // Deploy the FlashLoanArbitrage contract
        FlashLoanArbitrage flashLoanArbitrage = new FlashLoanArbitrage(
            aavePool,
            profitWallet
        );

        console.log("FlashLoanArbitrage deployed at:", address(flashLoanArbitrage));

        vm.stopBroadcast();
    }
}
