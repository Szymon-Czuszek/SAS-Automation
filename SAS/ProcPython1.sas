%let ticker = AAPL;         /* Change this to your desired ticker */
%let start_date = 2022-01-01;  /* Change this to your desired start date */
%let end_date = 2023-01-01;    /* Change this to your desired end date */
%let root_path = /export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/Automatyzacja_procesow/dane_zrodlowe/yfinance;  /* Define your root path */

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

