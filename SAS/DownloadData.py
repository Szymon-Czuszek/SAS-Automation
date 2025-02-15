import yfinance as yf
import pandas as pd

df = SAS.sd2df(_input1)

# Get ticker symbols from SAS dataset
tickers = df["Ticker"].tolist()
start_date = "2010-01-01"
end_date = "2025-01-01"

# Download stock data
data = yf.download(tickers, start=start_date, end=end_date)

# Reset index to make 'Date' a column
data.reset_index(inplace = True)

# Send the modified DataFrame back to SAS
SAS.df2sd(data, _output1)