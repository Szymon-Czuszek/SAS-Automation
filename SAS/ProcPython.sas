PROC PYTHON;
submit;
import yfinance as yf
import os
import pandas as pd

# Fetch the root path from SAS macro variables
root_path = SAS.symget("root_path")

# Define the path to the CSV file containing tickers and date ranges
csv_file = os.path.join(root_path, 'ticker_list.csv')

# Read the CSV file into a pandas DataFrame
ticker_df = pd.read_csv(csv_file)

# Loop through each row in the DataFrame
for index, row in ticker_df.iterrows():
    ticker = row['ticker']
    start_date = row['start_date']
    end_date = row['end_date']
    
    # Download the data for the specified ticker and date range
    data = yf.download(ticker, start=start_date, end=end_date)

    # Define the export path dynamically based on the root path, ticker, and date range
    export_path = os.path.join(root_path, f"{ticker}.{start_date}.{end_date}.csv")

    # Create the directory if it does not exist
    os.makedirs(os.path.dirname(export_path), exist_ok=True)

    # Save the data to CSV
    data.to_csv(export_path)

    # Print the first few rows to confirm data retrieval
    print(f"Downloaded data for {ticker}:")
    print(data.head())

endsubmit;
RUN;