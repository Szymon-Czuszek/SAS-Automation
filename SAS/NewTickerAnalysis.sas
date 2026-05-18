/*============================================================================*/
/* STEP 1: Extract ticker and date parameters from the source dataset         */
/*============================================================================*/

DATA _NULL_;
    SET STOCKS.TICKER_LIST END=last;

    /* Store values from the last observation as SAS macro variables */
    IF last THEN DO;
        CALL SYMPUTX('ticker', ticker);
        CALL SYMPUTX('start_date', start_date);
        CALL SYMPUTX('end_date', end_date);
    END;
RUN;


/*============================================================================*/
/* STEP 2: Display extracted macro variable values in the SAS log             */
/*============================================================================*/

%PUT &=ticker;
%PUT &=start_date;
%PUT &=end_date;


/*============================================================================*/
/* STEP 3: Define root directory for storing stock data                       */
/*============================================================================*/

%LET root_path=
/export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/
Automatyzacja_procesow/dane_zrodlowe/yfinance;

/* Display macro variable values */
%PUT Ticker: &ticker;
%PUT Start Date: &start_date;
%PUT End Date: &end_date;


/*============================================================================*/
/* STEP 4: Define SAS library pointing to the root folder                     */
/*============================================================================*/

LIBNAME mydblib "&root_path";


/*============================================================================*/
/* STEP 5: Macro to import CSV file as SAS dataset                            */
/*============================================================================*/

%MACRO open_csv_as_dataset(ticker, start_date, end_date, root_path);

    /* Dynamically create CSV file path */
    %LET csv_path = 
        &root_path/&ticker..&start_date..&end_date..csv;

    /* Check whether the file exists */
    %IF %SYSFUNC(FILEEXIST(&csv_path)) %THEN %DO;

        /* Import CSV file into WORK library */
        PROC IMPORT DATAFILE="&csv_path"
            OUT=work.&ticker._data
            DBMS=csv
            REPLACE;

            GETNAMES=YES;   /* Use first row as column names */
            DATAROW=4;      /* Start reading data from row 4 */

        RUN;

        /* Rename imported column */
        DATA work.&ticker._data;
            SET work.&ticker._data;

            /* Rename Price column to Date */
            RENAME Price = Date;

        RUN;

        /* Print sample observations for validation */
        PROC PRINT DATA=work.&ticker._data(OBS=10);
        RUN;

    %END;

    %ELSE %DO;
        %PUT ERROR: The file &csv_path does not exist.;
    %END;

%MEND open_csv_as_dataset;


/*============================================================================*/
/* STEP 6: Macro to generate average trading volume chart                     */
/*============================================================================*/

%MACRO generate_volume_chart(dataset);

    /* Validate dataset parameter */
    %IF &dataset = %THEN %DO;
        %PUT ERROR: Dataset parameter is missing.;
        %RETURN;
    %END;

    TITLE "Average Volume for Stock: &dataset";

    PROC CHART DATA=&dataset;

        /* Horizontal bar chart of average trading volume */
        HBAR DATE / 
            SUMVAR=Volume
            TYPE=MEAN;

    RUN;

    TITLE;

%MEND generate_volume_chart;


/*============================================================================*/
/* STEP 7: Macro to calculate moving average                                  */
/*============================================================================*/

%MACRO moving_average(dataset, window);

    DATA &dataset._moving_avg;
        SET &dataset;

        /* Calculate 5-day moving average */
        MA_Close = MEAN(
            LAG1(Close),
            LAG2(Close),
            LAG3(Close),
            LAG4(Close),
            LAG5(Close)
        );

        FORMAT MA_Close 8.2;

    RUN;

    /* Display results */
    PROC PRINT DATA=&dataset._moving_avg;

        TITLE 
        "Stock Prices with &window-Day Moving Average for &dataset";

        VAR Date Close MA_Close;

    RUN;

%MEND moving_average;


/*============================================================================*/
/* STEP 8: Macro to calculate rolling volatility                              */
/*============================================================================*/

%MACRO calculate_volatility(dataset, window);

    PROC EXPAND DATA=&dataset
        OUT=&dataset._volatility
        METHOD=none;

        /* Calculate moving standard deviation */
        CONVERT Close = Volatility /
            TRANSFORMOUT=(MOVSTD &window);

    RUN;

    PROC PRINT DATA=&dataset._volatility;

        TITLE 
        "Volatility of Stock Price for &dataset 
        (Window: &window Days)";

        VAR Date Close Volatility;

    RUN;

%MEND calculate_volatility;


/*============================================================================*/
/* STEP 9: Macro to visualize stock price trends                              */
/*============================================================================*/

%MACRO plot_stock_trend(dataset);

    PROC SGPLOT DATA=&dataset;

        TITLE "Stock Price Trend for &dataset";

        /* Plot OHLC price series */
        SERIES X=Date Y=Open  / 
            LINEATTRS=(COLOR=blue)
            LEGENDLABEL="Open";

        SERIES X=Date Y=High  / 
            LINEATTRS=(COLOR=green)
            LEGENDLABEL="High";

        SERIES X=Date Y=Low   / 
            LINEATTRS=(COLOR=red)
            LEGENDLABEL="Low";

        SERIES X=Date Y=Close / 
            LINEATTRS=(COLOR=black)
            LEGENDLABEL="Close";

        XAXIS LABEL="Date";
        YAXIS LABEL="Price";

    RUN;

%MEND plot_stock_trend;


/*============================================================================*/
/* STEP 10: Macro to perform correlation analysis                             */
/*============================================================================*/

%MACRO correlation_analysis(dataset);

    PROC CORR DATA=&dataset;

        TITLE 
        "Correlation Between Volume and Close Price for &dataset";

        VAR Volume Close;

    RUN;

%MEND correlation_analysis;


/*============================================================================*/
/* STEP 11: Macro to visualize trading volume trend                           */
/*============================================================================*/

%MACRO plot_volume_trend(dataset);

    PROC SGPLOT DATA=&dataset;

        TITLE "Volume Trend for &dataset";

        SERIES X=Date Y=Volume /
            LINEATTRS=(COLOR=blue)
            LEGENDLABEL="Volume";

        XAXIS LABEL="Date";
        YAXIS LABEL="Volume";

    RUN;

%MEND plot_volume_trend;


/*============================================================================*/
/* STEP 12: Macro to simulate candlestick chart                               */
/*============================================================================*/

%MACRO candlestick_chart(dataset);

    PROC SGPLOT DATA=&dataset;

        TITLE "Candlestick Chart for &dataset";

        /* High-Low bars */
        HIGHLOW X=Date
            HIGH=High
            LOW=Low /
            TYPE=BAR;

        /* Open prices */
        SCATTER X=Date Y=Open /
            MARKERATTRS=(
                SYMBOL=CircleFilled
                COLOR=green
            )
            LEGENDLABEL="Open";

        /* Close prices */
        SCATTER X=Date Y=Close /
            MARKERATTRS=(
                SYMBOL=CircleFilled
                COLOR=red
            )
            LEGENDLABEL="Close";

        XAXIS LABEL="Date";
        YAXIS LABEL="Price";

        KEYLEGEND / POSITION=RIGHT;

    RUN;

%MEND candlestick_chart;


/*============================================================================*/
/* STEP 13: Download stock data using Python and yfinance                     */
/*============================================================================*/

PROC PYTHON;
SUBMIT;

import yfinance as yf
import os

# Retrieve SAS macro variables
ticker = SAS.symget("ticker")
start_date = SAS.symget("start_date")
end_date = SAS.symget("end_date")
root_path = SAS.symget("root_path")

# Download historical stock data
data = yf.download(
    ticker,
    start=start_date,
    end=end_date
)

# Create export file path
export_path = os.path.join(
    root_path,
    f"{ticker}.{start_date}.{end_date}.csv"
)

# Create directory if necessary
os.makedirs(
    os.path.dirname(export_path),
    exist_ok=True
)

# Export data to CSV
data.to_csv(export_path)

# Print preview of downloaded data
print(data.head())

ENDSUBMIT;
RUN;


/*============================================================================*/
/* STEP 14: Import downloaded CSV into SAS                                    */
/*============================================================================*/

%open_csv_as_dataset(
    &ticker,
    &start_date,
    &end_date,
    &root_path
);


/*============================================================================*/
/* STEP 15: Save imported dataset to permanent library                        */
/*============================================================================*/

PROC SQL;

    CREATE TABLE mydblib.&ticker AS
    SELECT *
    FROM work.&ticker._data;

QUIT;


/*============================================================================*/
/* STEP 16: Define STOCKS library                                              */
/*============================================================================*/

LIBNAME STOCKS BASE "&root_path";


/*============================================================================*/
/* STEP 17: Execute analytical macros                                          */
/*============================================================================*/

/* Generate average trading volume chart */
%generate_volume_chart(work.&ticker._data);

/* Calculate moving average */
%moving_average(work.&ticker._data, 5);

/* Calculate rolling volatility */
%calculate_volatility(work.&ticker._data, 5);

/* Plot OHLC stock trend */
%plot_stock_trend(work.&ticker._data);

/* Analyze correlation between volume and closing price */
%correlation_analysis(work.&ticker._data);

/* Plot volume trend */
%plot_volume_trend(work.&ticker._data);

/* Generate candlestick chart */
%candlestick_chart(work.&ticker._data);
