import sys
import subprocess

# --- STEP 1: Install required package (yfinance) ---
# Uses the current Python interpreter to ensure compatibility
subprocess.check_call([
    sys.executable, 
    "-m", 
    "pip", 
    "install", 
    "yfinance"
])
