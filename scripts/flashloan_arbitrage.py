import brownie
from brownie import config, network, FlashLoanArbitrage
from scripts.helper_scripts import (
    get_account,
    toWei,
    fromWei,
    approve_erc20,
    FORKED_BLOCHCHAINS,
    get_next_rpc_url,
    load_abi
)
from scripts.get_weth import get_weth
from web3 import Web3
import logging
import json

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

ETHERSCAN_TX_URL = "https://etherscan.io/tx/{}"

# Dynamic RPC URL rotation
network_urls = {
    "mainnet": get_next_rpc_url(),
    "optimism": get_next_rpc_url(),
    "arbitrum": get_next_rpc_url(),
    "sepolia": get_next_rpc_url()
}

# Define tokens and addresses dynamically
network_config = config["networks"][network.show_active()]
weth_token = network_config["weth-token"]
dai_token = network_config["dai-token"]
uni_router_address = network_config["uniswap-router"]
sushi_router_address = network_config["sushiswap-router"]
aave_address_provider = network_config["provider"]

def calculate_flashloan_amount(account):
    """
    Calculate the maximum flashloan amount based on wallet balance
    and gas cost considerations.
    """
    try:
        web3 = Web3(Web3.HTTPProvider(get_next_rpc_url()))
        wallet_balance = web3.eth.get_balance(account.address)
        gas_price = web3.eth.gas_price

        logging.info(f"Wallet balance: {fromWei(wallet_balance)} ETH")
        logging.info(f"Gas price: {Web3.fromWei(gas_price, 'gwei')} gwei")

        # Set a buffer for gas costs (e.g., 0.02 ETH)
        gas_buffer = toWei(0.02)
        max_flashloan = wallet_balance - gas_buffer

        if max_flashloan <= 0:
            raise ValueError("Insufficient balance for flashloan after gas buffer")

        # Use 90% of the available amount to leave some margin
        return max_flashloan * 0.9
    except Exception as e:
        logging.error(f"Error calculating flashloan amount: {e}")
        raise

def deploy():
    account = get_account()

    # Use dynamic URL rotation for the network
    active_network_url = network_urls.get(network.show_active(), None)
    if not active_network_url:
        raise ValueError(f"No RPC URL found for network: {network.show_active()}")

    if network.show_active() in FORKED_BLOCHCHAINS:
        get_weth(account, 10)

    logging.info("Deploying FlashLoanArbitrage contract...")
    try:
        # Dynamically load the FlashLoanArbitrage ABI
        abi = load_abi("FlashLoanArbitrage")
        web3 = Web3(Web3.HTTPProvider(active_network_url))
        flashloan_arbitrage = web3.eth.contract(abi=abi)

        arbitrage = FlashLoanArbitrage.deploy(
            aave_address_provider,
            uni_router_address,
            sushi_router_address,
            weth_token,
            dai_token,
            {"from": account, "gas_limit": 6000000, "gas_price": Web3.toWei("20", "gwei")}
        )

        tx_hash = arbitrage.tx.txid
        contract_address = arbitrage.address

        logging.info(f"Transaction hash: {tx_hash}")
        logging.info(f"Deployed FlashLoanArbitrage contract at: {contract_address}")

        # Log deployed contract details to a file
        with open("deployed_flashloan_contract.log", "w") as log_file:
            log_file.write(f"Transaction hash: {tx_hash}\n")
            log_file.write(f"Contract address: {contract_address}\n")

        # Execute the flashloan workflow
        execute_flashloan_workflow(account, arbitrage)

    except Exception as e:
        logging.error(f"Error during deployment: {e}")
        raise

def execute_flashloan_workflow(account, arbitrage):
    """
    Execute the full flashloan workflow, including deposit, calculation, and execution.
    """
    try:
        # Set the amount of WETH to deposit
        amount = toWei(5)

        # Approve WETH for the arbitrage contract
        logging.info("Approving WETH for the arbitrage contract...")
        approve_erc20(weth_token, arbitrage.address, amount, account)

        # Deposit WETH into the arbitrage contract
        logging.info("Depositing WETH into the arbitrage contract...")
        deposit_tx = arbitrage.deposit(amount, {"from": account})
        deposit_tx.wait(1)

        weth_balance = arbitrage.getERC20Balance(weth_token)
        logging.info(f"Amount deposited: {fromWei(weth_balance)} WETH")

        # Calculate the flashloan amount
        flashloan_amount = calculate_flashloan_amount(account)
        logging.info(f"Calculated flashloan amount: {fromWei(flashloan_amount)} WETH")

        # Execute the flashloan
        logging.info("Executing flashloan...")
        flash_tx = arbitrage.flashloan(weth_token, flashloan_amount, {"from": account})
        flash_tx.wait(1)

        logging.info(f"Flashloan executed successfully. Tx hash: {flash_tx.txid}")

    except Exception as e:
        logging.error(f"Error during flashloan workflow: {e}")
        raise

def main():
    deploy()
