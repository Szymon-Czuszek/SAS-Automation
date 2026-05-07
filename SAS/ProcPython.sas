/*============================================================================*/
/* STEP 1: Start PROC PYTHON environment                                      */
/*============================================================================*/

/*
   PROC PYTHON enables Python code execution directly inside SAS.
   This allows integration between:
   
   - SAS macro variables
   - Python libraries
   - external APIs
   - filesystem operations

   In this example:
   - SAS provides configuration parameters
   - Python downloads financial data using yfinance
   - CSV files are generated dynamically
*/

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


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   import yfinance as yf
   ----------------------
   Imports the yfinance library used to retrieve historical
   stock market data from Yahoo Finance.


   import os
   ----------
   Provides operating system functionality:
   - path handling
   - directory creation
   - file management


   import pandas as pd
   --------------------
   Imports pandas for:
   - tabular data processing
   - CSV reading/writing
   - DataFrame manipulation


   SAS.symget("root_path")
   ------------------------
   Retrieves a SAS macro variable value inside Python.

   This enables communication between:
   - SAS macro environment
   - embedded Python session


   pd.read_csv(csv_file)
   ----------------------
   Reads the ticker configuration file into a pandas DataFrame.

   Expected CSV structure:
   ---------------------------------------
   ticker,start_date,end_date
   AAPL,2010-01-01,2025-01-01
   MSFT,2010-01-01,2025-01-01
   NVDA,2010-01-01,2025-01-01


   for index, row in ticker_df.iterrows()
   ---------------------------------------
   Iterates through each row of the ticker list.

   For every ticker:
   - ticker symbol is extracted
   - date range is extracted
   - stock data is downloaded
   - CSV file is generated


   yf.download(...)
   -----------------
   Downloads historical stock market data.

   Returned data typically includes:
   - Open
   - High
   - Low
   - Close
   - Adjusted Close
   - Volume


   os.path.join(...)
   ------------------
   Dynamically creates platform-independent file paths.


   os.makedirs(..., exist_ok=True)
   --------------------------------
   Creates the destination folder if it does not exist.

   exist_ok=True prevents errors if:
   - the directory already exists


   data.to_csv(export_path)
   -------------------------
   Saves downloaded stock data to CSV format.

   Naming convention:
   ---------------------------------------
   TICKER.STARTDATE.ENDDATE.csv

   Example:
   ---------------------------------------
   AAPL.2010-01-01.2025-01-01.csv


   print(data.head())
   -------------------
   Displays preview rows for:
   - debugging
   - validation
   - monitoring download success


   Overall Workflow
   -----------------
   1. Read ticker configuration file
   2. Loop through all tickers
   3. Download historical stock data
   4. Export datasets to CSV
   5. Store files in centralized directory

   This creates a scalable automated data ingestion pipeline
   combining SAS orchestration with Python-based API access.
*/
