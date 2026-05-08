/*============================================================================*/
/* STEP 1: Define root directory path                                         */
/*============================================================================*/

/*
   This macro variable defines the central storage location for:
   - CSV source files
   - SAS datasets
   - imported stock market data
   - intermediate processing files
*/

%LET root_path = 
/export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/
Automatyzacja_procesow/dane_zrodlowe/yfinance;


/*============================================================================*/
/* STEP 2: Initialize master dataset                                          */
/*============================================================================*/

/*
   Create an empty dataset that will later store:
   - imported stock data
   - merged ticker datasets
   - consolidated historical records
*/

DATA ALL_DATA;

    /* Define variable structure */
    LENGTH Ticker $10;

RUN;


/*============================================================================*/
/* STEP 3: Remove old CSV files using Python                                  */
/*============================================================================*/

/*
   PROC PYTHON is used here to:
   - access the filesystem
   - locate previously generated CSV files
   - delete old exports before downloading new data

   This prevents:
   - duplicate files
   - outdated datasets
   - storage clutter
*/

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


/*============================================================================*/
/* STEP 4: Create ticker configuration dataset                                */
/*============================================================================*/

/*
   This dataset defines:
   - stock ticker symbols
   - analysis start dates
   - analysis end dates

   Each row represents one download request.
*/

DATA ticker_list;

    LENGTH ticker $10 start_date $10 end_date $10;

    INFILE datalines DSD TRUNCOVER;

    INPUT ticker $ start_date $ end_date $;

    DATALINES;
MSFT,2022-01-01,2023-01-01
TSLA,2022-01-01,2023-01-01
GOOGL,2022-01-01,2023-01-01
;
RUN;


/*============================================================================*/
/* STEP 5: Export ticker list to CSV                                          */
/*============================================================================*/

/*
   Export the ticker configuration file so it can be:
   - read by Python
   - used for automated downloads
*/

PROC EXPORT DATA=ticker_list
    OUTFILE="&root_path/ticker_list.csv"
    DBMS=csv
    REPLACE;

RUN;


/*============================================================================*/
/* STEP 6: Save ticker list as permanent SAS dataset                          */
/*============================================================================*/

/*
   Create a permanent SAS library pointing to the root directory.
*/

LIBNAME yfinance "&root_path";


/*
   Save ticker_list dataset permanently.
*/

DATA yfinance.ticker_list;

    SET ticker_list;

RUN;


/*============================================================================*/
/* STEP 7: Include external Python download script                            */
/*============================================================================*/

/*
   Include external SAS script containing:
   - PROC PYTHON logic
   - automated yfinance download process
*/

%INCLUDE "&root_path/ProcPython.sas";


/*============================================================================*/
/* STEP 8: Macro to import CSV files into SAS                                 */
/*============================================================================*/

/*
   This macro:
   - checks whether CSV exists
   - imports stock data
   - renames columns
   - appends data into ALL_DATA
*/

%MACRO open_csv_as_dataset(
    ticker,
    start_date,
    end_date,
    root_path
);

    /* Create CSV file path dynamically */
    %LET csv_path =
        &root_path/&ticker..&start_date..&end_date..csv;

    /* Verify file existence */
    %IF %SYSFUNC(FILEEXIST(&csv_path)) %THEN %DO;

        /* Import CSV file */
        PROC IMPORT DATAFILE="&csv_path"
            OUT=work.&ticker._data
            DBMS=csv
            REPLACE;

            GETNAMES=YES;

            /* Skip first three rows */
            DATAROW=4;

        RUN;


        /* Rename imported column and add ticker identifier */
        DATA work.&ticker._data;

            SET work.&ticker._data(
                RENAME=(Price=Date)
            );

            Ticker = "&ticker";

        RUN;


        /* Append imported dataset into master dataset */
        DATA ALL_DATA;

            SET ALL_DATA
                work.&ticker._data;

        RUN;


        /* Print sample observations for verification */
        PROC PRINT DATA=work.&ticker._data(OBS=10);

            TITLE 
            "First 10 rows of the dataset for &ticker";

        RUN;

        TITLE;

    %END;

    %ELSE %DO;

        %PUT ERROR: The file &csv_path does not exist.;

    %END;

%MEND open_csv_as_dataset;


/*============================================================================*/
/* STEP 9: Dynamically execute import macro for all tickers                   */
/*============================================================================*/

/*
   CALL EXECUTE dynamically generates macro calls
   for every row in ticker_list.

   Example generated calls:
   -------------------------------------------------
   %open_csv_as_dataset(MSFT,2022-01-01,...)
   %open_csv_as_dataset(TSLA,2022-01-01,...)
*/

DATA _NULL_;

    SET ticker_list;

    CALL EXECUTE(
        CATS(
            '%open_csv_as_dataset(',
            ticker,
            ',',
            start_date,
            ',',
            end_date,
            ',',
            "&root_path",
            ');'
        )
    );

RUN;


/*============================================================================*/
/* STEP 10: Save final consolidated dataset                                   */
/*============================================================================*/

/*
   ALL_DATA now contains:
   - all imported stock datasets
   - all ticker observations
   - combined historical market data
*/

DATA &_output1;

    SET ALL_DATA;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   Overall Workflow
   ----------------------------------------------------------------

   1. Define storage location
   2. Remove old CSV files
   3. Create ticker configuration dataset
   4. Export ticker configuration to CSV
   5. Execute Python download process
   6. Import downloaded CSV files into SAS
   7. Merge all datasets into ALL_DATA
   8. Save final output dataset


   Key Technologies Used
   ----------------------------------------------------------------
   - SAS Macros
   - PROC PYTHON
   - yfinance API
   - pandas
   - filesystem automation
   - dynamic macro execution


   CALL EXECUTE
   ----------------------------------------------------------------
   Dynamically generates SAS macro calls during DATA step execution.

   This enables scalable automation for:
   - multiple stock tickers
   - large download batches
   - reusable workflows


   PROC IMPORT
   ----------------------------------------------------------------
   Imports generated CSV files into SAS datasets.

   GETNAMES=YES:
       Uses first row as variable names

   DATAROW=4:
       Starts reading observations from row 4


   DATA ALL_DATA
   ----------------------------------------------------------------
   Serves as a centralized consolidated dataset
   containing all imported stock market observations.


   Practical Use Cases
   ----------------------------------------------------------------
   - Financial forecasting
   - ARIMA modeling
   - Volatility analysis
   - Time series analytics
   - Automated stock data pipelines
   - AI impact studies on financial markets
*/
