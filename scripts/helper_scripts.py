from brownie import config, network, accounts, Contract, interface
from web3 import Web3
from itertools import cycle
import os
import requests

LOCAL_BLOCKCHAINS = ["ganache-local", "development"]

FORKED_BLOCHCHAINS = ["mainnet-fork", "mainnet-fork-dev"]

ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

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

def get_account(index=None):
    if network.show_active() in LOCAL_BLOCKCHAINS or network.show_active() in FORKED_BLOCHCHAINS:
        if index is not None:
            return accounts[index]
        else:
            return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def toWei(amount):
    return Web3.toWei(amount, "ether")

def fromWei(amount):
    return Web3.fromWei(amount, "ether")

def get_contract(_contract, contract_address):
    web3 = Web3(Web3.HTTPProvider(get_next_rpc_url()))
    return web3.eth.contract(address=contract_address, abi=_contract.abi)

def approve_erc20(erc20_address, spender, amount, account):
    web3 = Web3(Web3.HTTPProvider(get_next_rpc_url()))
    erc20 = web3.eth.contract(address=erc20_address, abi=interface.IERC20.abi)
    approve_tx = erc20.functions.approve(spender, amount).transact({"from": account.address})
    web3.eth.waitForTransactionReceipt(approve_tx)
    print("----- ERC20 approved -----")

def fetch_current_gas_price():
    """
    Fetch the current gas price using a reliable provider API.
    """
    try:
        web3 = Web3(Web3.HTTPProvider(get_next_rpc_url()))
        gas_price = web3.eth.gas_price
        print(f"Current gas price: {Web3.fromWei(gas_price, 'gwei')} gwei")
        return gas_price
    except Exception as e:
        print(f"Error fetching gas price: {e}")
        return None

def fetch_gas_price_api():
    """
    Fetch gas price from an external API as a fallback.
    """
    try:
        response = requests.get("https://ethgasstation.info/api/ethgasAPI.json")
        if response.status_code == 200:
            data = response.json()
            fast_gas = data.get("fast", 0) / 10  # Convert to gwei
            print(f"Fast gas price (API): {fast_gas} gwei")
            return Web3.toWei(fast_gas, "gwei")
        else:
            print("Failed to fetch gas price from API.")
    except Exception as e:
        print(f"Error fetching gas price from API: {e}")
    return None

def get_dynamic_gas_price():
    """
    Attempt to fetch the dynamic gas price, using multiple sources.
    """
    gas_price = fetch_current_gas_price()
    if gas_price is None:
        gas_price = fetch_gas_price_api()
    return gas_price if gas_price is not None else Web3.toWei("20", "gwei")  # Default fallback gas price
