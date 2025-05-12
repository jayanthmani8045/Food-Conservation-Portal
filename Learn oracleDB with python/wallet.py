import os
from pathlib import Path
from dotenv import load_dotenv
import oracledb

wallet_dir = Path(__file__).parent / "Wallet_DevDB"
if not wallet_dir.exists():
    raise RuntimeError(f"Wallet folder not found: {wallet_dir}")
print("Wallet directory exists:", wallet_dir)