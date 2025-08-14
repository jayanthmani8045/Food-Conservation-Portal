from fastapi import FastAPI
import oracledb
from dotenv import load_dotenv
import os
from pathlib import Path

from fastapi.middleware.cors import CORSMiddleware


load_dotenv(Path(__file__).parent / ".env")

wallet_dir = Path(__file__).parent / "Wallet_DevDB"
if not wallet_dir.exists():
    raise RuntimeError(f"Wallet folder not found: {wallet_dir}")

con = oracledb.connect(
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    dsn=os.getenv("DB_DSN"),
    wallet_location=str(wallet_dir),  # where cwallet.sso, sqlnet.ora live
    wallet_password=os.getenv("DB_WALLET_PASS"),
    ssl_server_dn_match=True
)

print("Database version:", con.version)
print("Successfully connected to Oracle Database")



app = FastAPI()

# Allow CORS for all origins
app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_methods=["*"],
  allow_headers=["*"],
)


@app.get("/")
async def root():
    res = con.cursor().execute("SELECT sysdate FROM DUAL").fetchone()
    print("Current date and time:", res[0])
    return str(res[0])