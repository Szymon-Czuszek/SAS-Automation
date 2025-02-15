import sys
import subprocess

# Install yfinance using subprocess
subprocess.check_call([sys.executable, "-m", "pip", "install", "yfinance"])