# Aave V3 Flashloan Arbitrage Bot

Welcome to the **Aave V3 Flashloan Arbitrage Bot**, a project designed to identify and exploit arbitrage opportunities between **Uniswap V3**, **Sushiswap V3**, and **Aave V3** lending protocols on Layer 2 networks like **Arbitrum** and **Optimism**.

---

## Features

- **Flashloan Support**: Fully integrated with **Aave V3 flashloan protocols**.
- **Arbitrage Logic**: Automates profit-driven token swaps across decentralized exchanges.
- **V3 Protocols Only**: Supports **Uniswap V3** and **Sushiswap V3** for enhanced flexibility.
- **Layer 2 Networks**: Operates on Arbitrum, Optimism, and Ethereum Mainnet.

---

## Project Structure

### Contracts
- **`contracts/FlashLoanArbitrage.sol`**: Core arbitrage logic implemented with Aave V3 flashloans.
- **`contracts/`**: Contains all Solidity files, including dependencies for:
  - **Aave V3 Protocol** (e.g., Lending Pool, Data Types).
  - **Uniswap V3** (e.g., Pool, Factory, Router).

### Python Scripts
- **`flashloan_arbitrage.py`**:
  - Orchestrates flashloan workflows, arbitrage logic, and trade execution.
  - Monitors prices across Uniswap and Sushiswap to identify profitable trades.
- **Utility Scripts**:
  - **`get_weth.py`**: Automates the process of obtaining WETH.
  - **`helper_scripts.py`**: Contains reusable functions for interacting with contracts, fetching gas prices, and approving ERC-20 tokens.
  - **`liquidity_sim.py`**: Simulates liquidity conditions to test arbitrage strategies.
  - **`reset.py`**: Resets local blockchain states and manages snapshots for testing.

### Configuration
- **`foundry.toml`**:
  - Defines configurations for Foundry.
- **`.env`**:
  - Stores sensitive keys (e.g., `PRIVATE_KEY`, `INFURA_PROJECT_ID`).

---

## Setup Instructions

### 1. Install Dependencies
Ensure you have the required tools installed:
```bash
pip install web3 requests
```

### 2. Clone the Repository
```bash
git clone https://github.com/your-repo/aave-flashloan-arbitrage.git
cd aave-flashloan-arbitrage
```

### 3. Set Up Environment Variables
Create a `.env` file with:
```env
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
INFURA_PROJECT_ID=<YOUR_INFURA_PROJECT_ID>
ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
OPTIMISM_API_KEY=<YOUR_OPTIMISM_API_KEY>
ARBITRUM_API_KEY=<YOUR_ARBITRUM_API_KEY>
```

### 4. Compile Contracts
Use Foundry to clean and compile the contracts:
```bash
forge clean && forge build
```

### 5. Deploy Contract
Deploy the FlashLoanArbitrage contract to your desired network:
```bash
forge script script/DeployFlashLoanArbitrage.s.sol --rpc-url <NETWORK_RPC_URL> --broadcast
```

### 6. Orchestrate Arbitrage with Python
Use the Python scripts to:
- Monitor prices on Uniswap and Sushiswap.
- Trigger arbitrage opportunities via the deployed contract.
- Example:
  ```bash
  python flashloan_arbitrage.py
  ```

---

## Summary of Changes

### Key Updates
1. **Migration to Python and Foundry**:
   - Removed references to Hardhat and Brownie.
   - Relied on Python for orchestration and monitoring.
2. **Improved Workflow**:
   - Python scripts manage real-time monitoring and trade execution.
   - Foundry handles contract deployment and testing.
3. **Centralized Dependencies**:
   - All Solidity files and Python utilities are centralized in their respective directories.
   - Updated import paths dynamically to prevent nested directory issues.
4. **Enhanced Flexibility**:
   - Added network configurations for Arbitrum, Optimism, and Ethereum Mainnet.
   - Improved error handling and logging across Python scripts for seamless debugging.

---

## Troubleshooting

1. **Import Errors**:
   - Ensure all required Python libraries are installed using `pip`.
   - Verify that `.env` is correctly configured with RPC URLs and private keys.

2. **Deployment Issues**:
   - Confirm your `.env` file has valid RPC URLs and private keys.
   - Ensure sufficient ETH or testnet funds are available in the deployment account.

3. **Price Monitoring Delays**:
   - Adjust the polling interval in `flashloan_arbitrage.py` to balance speed and rate limits.

---

## License
MIT License.
