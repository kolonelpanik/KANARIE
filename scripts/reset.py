import os
import shutil
from web3 import Web3

"""
    Utility script to manage and reset blockchain testing environments.
"""

# Define snapshot storage
SNAPSHOT_FILE = "./snapshots/snapshot_id.txt"

def reset_deployments():
    folder = "./build/deployments"

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}. Reason: {e}")

def reset_compiled_contracts():
    folder = "./build/contracts"

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}. Reason: {e}")

def reset_compiled_interfaces():
    folder = "./build/interfaces"

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}. Reason: {e}")

def create_snapshot(web3):
    """
    Create a blockchain snapshot for testing rollback.
    """
    try:
        snapshot_id = web3.provider.make_request("evm_snapshot", [])
        with open(SNAPSHOT_FILE, "w") as file:
            file.write(snapshot_id["result"])
        print(f"Snapshot created with ID: {snapshot_id['result']}")
    except Exception as e:
        print(f"Failed to create snapshot. Reason: {e}")

def revert_to_snapshot(web3):
    """
    Revert the blockchain state to the last saved snapshot.
    """
    try:
        if not os.path.exists(SNAPSHOT_FILE):
            print("No snapshot found to revert to.")
            return

        with open(SNAPSHOT_FILE, "r") as file:
            snapshot_id = file.read().strip()

        result = web3.provider.make_request("evm_revert", [snapshot_id])
        if result["result"]:
            print(f"Reverted to snapshot ID: {snapshot_id}")
        else:
            print("Failed to revert to snapshot. Snapshot may no longer be valid.")

    except Exception as e:
        print(f"Failed to revert to snapshot. Reason: {e}")

def main():
    # Ensure a web3 connection for snapshot management
    web3 = Web3(Web3.HTTPProvider(os.getenv("ETH_MAINNET_RPC_URL")))

    reset_deployments()
    reset_compiled_contracts()
    reset_compiled_interfaces()

    # Optional: manage snapshots
    create_snapshot(web3)
    # revert_to_snapshot(web3)
