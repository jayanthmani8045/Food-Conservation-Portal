import os
from pathlib import Path
from dotenv import load_dotenv
import oracledb

# 1) Load your .env from the same directory
dotenv_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path)

# 2) Point at your wallet directory
wallet_dir = Path(__file__).parent / "Wallet_DevDB"
if not wallet_dir.exists():
    raise RuntimeError(f"Wallet folder not found: {wallet_dir}")

# 3) Connect in thin mode, supplying wallet location and full descriptor
con = oracledb.connect(
    user               = os.getenv("DB_USER"),
    password           = os.getenv("DB_PASSWORD"),
    dsn                = os.getenv("DB_DSN"),
    wallet_location    = str(wallet_dir),  # where cwallet.sso, sqlnet.ora live
    wallet_password    = os.getenv("DB_WALLET_PASS"),
    ssl_server_dn_match= True              # enforce SSL DN match
)


print("Database version:", con.version)
print("Successfully connected to Oracle Database")


# 4) Run a simple query
# Note: The following query is just an example. You can replace it with any valid SQL query.
date = con.cursor().execute("SELECT sysdate FROM DUAL")
res = date.fetchone()
print("Current date and time:", res[0])

