import os
import subprocess

# Load variables from .env
def load_env(file_path=".env"):
    with open(file_path, "r") as f:
        for line in f:
            if "=" in line and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value

# Start anvil instances for multiple networks
def start_anvil():
    load_env()

    # Define RPC URLs and ports
    rpc_urls = {
        "mainnet": os.getenv("ETH_MAINNET_RPC_URL"),
        "arbitrum": os.getenv("ARBITRUM_RPC_URL"),
        "optimism": os.getenv("OPTIMISM_RPC_URL"),
    }
    ports = {"mainnet": 8545, "arbitrum": 8546, "optimism": 8547}

    # Start Anvil for each network
    for network, url in rpc_urls.items():
        if url:
            print(f"Starting Anvil for {network} on port {ports[network]}...")
            subprocess.Popen(["anvil", "--fork-url", url, "--port", str(ports[network])])

if __name__ == "__main__":
    start_anvil()
