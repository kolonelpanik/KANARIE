from brownie import FlashLoanArbitrage, Contract, accounts, network, config
from web3 import Web3
from itertools import cycle
import os
from decimal import Decimal
import logging
import json

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Cycle for rotating Infura project IDs
INFURA_URLS = cycle([
    os.getenv("ETH_MAINNET_RPC_URL"),
    os.getenv("OPTIMISM_RPC_URL"),
    os.getenv("ARBITRUM_RPC_URL"),
    os.getenv("SEPOLIA_RPC_URL"),
    os.getenv("FORK_RPC_URL")
])

def get_next_rpc_url():
    return next(INFURA_URLS)

def load_abi(abi_name):
    """Load ABI dynamically from the interfaces directory."""
    abi_path = f"./interfaces/aave-v3/{abi_name}-mainnet.json"
    try:
        with open(abi_path, "r") as abi_file:
            return json.load(abi_file)
    except Exception as e:
        logging.error(f"Error loading ABI for {abi_name}: {e}")
        raise

def calculate_trade_size(wallet_balance, gas_price):
    buffer = Decimal("0.1")  # 10% buffer for gas fees
    gas_cost = gas_price * Decimal("8000000") / Decimal("1e9")  # Adjust gas cost calculation for higher limits
    max_trade_size = wallet_balance - gas_cost
    return max_trade_size * Decimal("0.9")  # Use 90% of the calculated size for safety

def simulate_liquidity(contract, account):
    try:
        logging.info(f"Simulating liquidity with contract at: {contract.address}")

        token_in = config["networks"][network.show_active()].get('weth-token')
        token_out = config["networks"][network.show_active()].get('dai-token')
        uniswap_factory_address = config["networks"][network.show_active()].get('uniswap-factory')

        if not token_in or not token_out or not uniswap_factory_address:
            raise ValueError("Token or factory addresses not found in configuration")

        web3 = Web3(Web3.HTTPProvider(get_next_rpc_url()))

        # Load ABI dynamically
        uniswap_factory_abi = load_abi("UniswapV3Factory")

        uniswap_factory = web3.eth.contract(address=uniswap_factory_address, abi=uniswap_factory_abi)

        wallet_balance = Decimal(web3.from_wei(web3.eth.get_balance(account.address), 'ether'))
        logging.info(f"Wallet balance: {wallet_balance} ETH")

        gas_price = Decimal(web3.from_wei(web3.eth.gas_price, 'gwei'))
        logging.info(f"Current gas price: {gas_price} gwei")

        gas_limit = Decimal("8000000")
        gas_cost = gas_price * gas_limit / Decimal("1e9")
        logging.info(f"Estimated gas cost for trade: {gas_cost} ETH")

        trade_size = wallet_balance - gas_cost - (wallet_balance * Decimal("0.1"))
        if trade_size <= 0:
            logging.warning("Insufficient balance to perform a trade after gas costs.")
            return

        simulate_amount = web3.to_wei(trade_size, "ether")
        logging.info(f"Simulating trade: {simulate_amount} of {token_in} -> {token_out}")

        try:
            pool_address = uniswap_factory.functions.getPool(token_in, token_out, 3000).call()
            if pool_address == "0x0000000000000000000000000000000000000000":
                logging.error("No valid pool found for the token pair. Exiting simulation.")
                return

            logging.info(f"Pool address for trade: {pool_address}")

            tx = contract.makeArbitrage(simulate_amount, token_in, token_out, {
                "from": account.address,
                "gas_limit": int(gas_limit),
                "gas_price": web3.eth.gas_price
            })
            tx_receipt = web3.eth.wait_for_transaction_receipt(tx.txid)
            logging.info(f"Transaction successful. Tx hash: {tx_receipt.transactionHash.hex()}")
        except AttributeError as ae:
            logging.error(f"Error: {ae}. Ensure the contract ABI and methods are correctly defined.")
        except Exception as e:
            logging.error(f"Transaction failed: {e}")
    except Exception as e:
        logging.error(f"Error in liquidity simulation: {e}")

def main():
    try:
        account = accounts.add(config["wallets"]["from_key"])
        logging.info(f"Using account: {account.address}")
    except Exception as e:
        logging.error(f"Error loading account: {e}")
        return

    active_network = network.show_active()
    logging.info(f"Active network: {active_network}")

    try:
        deployed_contract_address = "0x45afA3E91360B75478C24ED3c355F847F1E4778e"  # Replace with your deployed contract address
        abi = load_abi("FlashLoanArbitrage")
        deployed_contract = Contract.from_abi("FlashLoanArbitrage", deployed_contract_address, abi)
        logging.info(f"Successfully loaded FlashLoanArbitrage contract at: {deployed_contract.address}")
    except Exception as e:
        logging.error(f"Error loading deployed contract: {e}")
        return

    try:
        simulate_liquidity(deployed_contract, account)
    except Exception as e:
        logging.error(f"Error during liquidity simulation: {e}")
