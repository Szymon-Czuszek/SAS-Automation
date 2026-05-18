import yfinance as yf
import pandas as pd

# --- STEP 1: Load data from SAS into a pandas DataFrame ---
# _input1 is a SAS dataset passed into the Python environment
df = SAS.sd2df(_input1)

# --- STEP 2: Extract ticker symbols ---
# Assumes the SAS dataset has a column named "Ticker"
tickers = df["Ticker"].dropna().unique().tolist()

# Define date range for historical data
start_date = "2010-01-01"
end_date = "2025-01-01"

# --- STEP 3: Download stock data using yfinance ---
# yf.download returns a multi-index DataFrame when multiple tickers are used
data = yf.download(
    tickers,
    start=start_date,
    end=end_date,
    group_by="ticker",   # keeps data organized per ticker
    auto_adjust=True     # adjusts for splits/dividends (recommended)
)

# --- STEP 4: Reshape data (optional but often useful) ---
# If multiple tickers, flatten the multi-index columns
if isinstance(data.columns, pd.MultiIndex):
    data.columns = ['_'.join(col).strip() for col in data.columns.values]

# Reset index so 'Date' becomes a column instead of index
data.reset_index(inplace=True)

# --- STEP 5: Send processed DataFrame back to SAS ---
# _output1 is the target SAS dataset
SAS.df2sd(data, _output1)
