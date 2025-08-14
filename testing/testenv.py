import os
from dotenv import load_dotenv
from pathlib import Path

path = Path(__file__).parent / ".env"
print(path)
load_dotenv(path)

print(os.getenv("DB_USER"))