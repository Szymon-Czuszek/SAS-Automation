/* Step 1: Define the macro variables */
%let root_path = /export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/Automatyzacja_procesow/dane_zrodlowe/yfinance;

/* Step 2: Clean Up */

DATA ALL_DATA;
    length Ticker $10; /* Define column names and types */
RUN;

PROC PYTHON;
submit;
import yfinance as yf
import os
import pandas as pd
import glob

# After processing all tickers, delete all CSV files in the directory
csv_files = glob.glob(os.path.join(root_path, "*.csv"))  # Get all CSV files in the folder
for file in csv_files:
    try:
        os.remove(file)  # Remove each file
        print(f"Deleted {file}")
    except Exception as e:
        print(f"Error deleting file {file}: {e}")

endsubmit;
RUN;

/* Step 3: Create a dataset with tickers and date ranges */
DATA ticker_list;
    length ticker $10 start_date $10 end_date $10;
    infile datalines dsd truncover;
    input ticker $ start_date $ end_date $;
    datalines;
MSFT,2022-01-01,2023-01-01
TSLA,2022-01-01,2023-01-01
GOOGL,2022-01-01,2023-01-01
;
RUN;

/* Step 4: Export the dataset to a CSV file */
PROC EXPORT data=ticker_list
    outfile="&root_path/ticker_list.csv"
    dbms=csv
    replace;
RUN;

/* Step 5: Save the dataset as a SAS dataset in the root path */
LIBNAME yfinance "&root_path";  /* Define the library pointing to the root path */

DATA yfinance.ticker_list;  /* Save the dataset as a SAS dataset */
    set ticker_list;
RUN;

/* Step 6: Call PROC PYTHON with the necessary parameters */
%include "&root_path/ProcPython.sas";

/* Step 7: Loop through the list and call the macro */

%macro open_csv_as_dataset(ticker, start_date, end_date, root_path);
    /* Define the path for the CSV file */
    %let csv_path = &root_path/&ticker..&start_date..&end_date..csv;

    /* Check if the file exists */
    %if %sysfunc(fileexist(&csv_path)) %then %do;
        /* Import the CSV file as a SAS dataset */
        PROC IMPORT datafile="&csv_path"
            out=work.&ticker._data
            dbms=csv
            replace;
            getnames=yes; /* Use the first row as column names */
            datarow=4;     /* Skip the first three rows */
        RUN;

        /* Rename the "Price" column directly without checking */
        DATA work.&ticker._data;
            set work.&ticker._data(rename=(Price=Date)); /* Rename column directly */
			Ticker = "&ticker";
        RUN;
		
		DATA ALL_DATA;
			SET ALL_DATA work.&ticker._data;
		RUN;

        /* Print the first few rows of the dataset for verification */
        PROC PRINT data=work.&ticker._data(obs=10);
        TITLE "First 10 rows of the dataset for &ticker";
        RUN;

		TITLE; /* Clears the title */
    %end;
    %else %do;
        %put ERROR: The file &csv_path does not exist.;
    %end;
%mend;

DATA _null_;
    set ticker_list;
    call execute(cats('%open_csv_as_dataset(', ticker, ',', start_date, ',', end_date, ',', "&root_path", ');'));
RUN;

DATA &_output1;

SET ALL_DATA;

RUN;