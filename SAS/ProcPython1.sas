/*============================================================================*/
/* STEP 1: Define SAS macro variables                                         */
/*============================================================================*/

/*
   These macro variables define:
   - stock ticker symbol
   - historical date range
   - export directory path

   The values can be modified dynamically depending on:
   - company being analyzed
   - forecasting period
   - project configuration
*/

%let ticker = AAPL;              /* Stock ticker symbol */
%let start_date = 2022-01-01;   /* Beginning of historical period */
%let end_date = 2023-01-01;     /* End of historical period */

/* Root directory used for storing exported CSV files */
%let root_path = 
/export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/
Automatyzacja_procesow/dane_zrodlowe/yfinance;


/*============================================================================*/
/* STEP 2: Execute Python code inside SAS                                     */
/*============================================================================*/

/*
   PROC PYTHON enables integration between:
   - SAS macro variables
   - Python scripts
   - external APIs
   - filesystem operations

   In this workflow:
   1. SAS provides parameters
   2. Python downloads stock data using yfinance
   3. Data is exported as CSV
*/

PROC PYTHON;
submit;

import yfinance as yf
import os

# Fetch the parameters from SAS macro variables
ticker = SAS.symget("ticker")
start_date = SAS.symget("start_date")
end_date = SAS.symget("end_date")
root_path = SAS.symget("root_path")

# Download the data for the specified ticker and date range
data = yf.download(ticker, start=start_date, end=end_date)

# Define the export path dynamically based on the root path, ticker, and date range
export_path = os.path.join(root_path, f"{ticker}.{start_date}.{end_date}.csv")

# Create the directory if it does not exist
os.makedirs(os.path.dirname(export_path), exist_ok=True)

# Save the data to CSV
data.to_csv(export_path)

# Print the first few rows to confirm data retrieval
print(data.head())

endsubmit;
RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   SAS.symget(...)
   ----------------
   Retrieves SAS macro variable values inside Python.

   This creates communication between:
   - SAS macro environment
   - embedded Python runtime


   yf.download(...)
   -----------------
   Downloads historical stock market data from Yahoo Finance.

   Retrieved fields typically include:
   - Open
   - High
   - Low
   - Close
   - Adjusted Close
   - Volume


   os.path.join(...)
   ------------------
   Dynamically builds a platform-independent file path.

   Example generated filename:
   ------------------------------------------------
   AAPL.2022-01-01.2023-01-01.csv


   os.makedirs(..., exist_ok=True)
   --------------------------------
   Ensures the export directory exists before saving the file.

   exist_ok=True prevents errors if:
   - the folder already exists


   data.to_csv(export_path)
   -------------------------
   Exports the downloaded stock data into CSV format.

   The file can later be:
   - imported into SAS
   - used for ARIMA forecasting
   - analyzed with macros
   - stored as historical source data


   print(data.head())
   -------------------
   Displays the first few observations for:
   - validation
   - debugging
   - confirming successful download


   Overall Workflow
   -----------------
   1. Define ticker and date range in SAS
   2. Pass parameters into Python
   3. Download stock market data
   4. Save results as CSV
   5. Prepare data for further SAS analytics

   This approach combines:
   - SAS orchestration capabilities
   - Python financial APIs
   - automated data engineering
   into a single analytical workflow.
*/
