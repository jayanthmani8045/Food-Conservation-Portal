from typing import Literal
from fastapi import FastAPI
import oracledb
from dotenv import load_dotenv
import os
from pathlib import Path
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


# python -m uvicorn [fastapi file name]:[app (fastapi pointing keyword)] --reload --host 0.0.0.0 --port 8000      -> use this to run the file
# pip install -r requirement.txt 
# check http://127.0.0.1:8000/

load_dotenv(Path(__file__).parent / ".env")

wallet_dir = Path(__file__).parent / "Wallet_DevDB"
if not wallet_dir.exists():
    raise RuntimeError(f"Wallet folder not found: {wallet_dir}")
else:
    print("---------------------------")
    print("Found DB wallet ",wallet_dir)
    print("---------------------------")

app = FastAPI()



app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_methods=["*"],
  allow_headers=["*"],
)

@app.get("/")
async def root():
    res = ""
    try:
        con = oracledb.connect(
            user=os.getenv("FOOD_ADMIN_USER"),
            password=os.getenv("FOOD_ADMIN_PASSWORD"),
            dsn=os.getenv("FOOD_ADMIN_DSN"),
            wallet_location=str(wallet_dir),
            wallet_password=os.getenv("FOOD_ADMIN_WALLET_PASS"),
            ssl_server_dn_match=True
        )
        cur = con.cursor()
        res = cur.execute("select SYSDATE from dual").fetchone()
        cur.close()
        con.close()

    except Exception as e:
        print("-------------------------")
        print("\nconnection error: ", e)
        print("-------------------------")
        print()

    return res

class UserRegistration(BaseModel):
    role: Literal["GOVT", "SUPPLIER", "NGO", "LOGISTICS"]
    username: str
    password: str
    first_name: str
    last_name: str
    address: str
    contact_number: int

# Define response model
class RegistrationResponse(BaseModel):
    code: int
    message: str


@app.post("/signup", response_model=RegistrationResponse)
async def register_user(user: UserRegistration):
    try:
        conn = oracledb.connect(
        user=os.getenv("FOOD_ADMIN_USER"),
        password=os.getenv("FOOD_ADMIN_PASSWORD"),
        dsn=os.getenv("FOOD_ADMIN_DSN"),
        wallet_location=str(wallet_dir),
        wallet_password=os.getenv("FOOD_ADMIN_WALLET_PASS"),
        ssl_server_dn_match=True
    )

        cursor = conn.cursor()
        l_code = cursor.var(int)
        
        cursor.callproc(
            "user_mgmt_pkg.onboard_user",
            [
                user.role,
                user.username,
                user.password,
                user.first_name,
                user.last_name,
                user.address,
                user.contact_number,
                l_code
            ]
        )
        
        result_code = l_code.getvalue()
        conn.cursor().close()
        conn.close()
        print()
        print('package output: ', result_code)
        print()
        return RegistrationResponse(code=result_code, message=f"User registration processed with code {result_code}")
        
    except Exception as e:
        return RegistrationResponse(code=500, message=f"An error occurred: {str(e)}")
