DATA _NULL_;
    set STOCKS.TICKER_LIST end=last;
    if last then do;
        call symputx('ticker', ticker);
        call symputx('start_date', start_date);
        call symputx('end_date', end_date);
    end;
RUN;

/* Example of using the macro variables */
%put &=ticker;
%put &=start_date;
%put &=end_date;

%let root_path = /export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/Automatyzacja_procesow/dane_zrodlowe/yfinance;

/* You can now use the extracted macro variables in your code or macros */
%put Ticker: &ticker;
%put Start Date: &start_date;
%put End Date: &end_date;


/* Define the destination library pointing to the folder */
LIBNAME mydblib "&root_path";

%macro open_csv_as_dataset(ticker, start_date, end_date, root_path);
    /* Define the path for the CSV file */
    %let csv_path = &root_path/&ticker..&start_date..&end_date..csv;

    /* Check if the file exists */
    %if %sysfunc(fileexist(&csv_path)) %then %do;
        /* Import the CSV file as a SAS dataset */
        proc import datafile="&csv_path"
            out=work.&ticker._data
            dbms=csv
            replace;
            getnames=yes; /* Use the first row as column names */
            datarow=4; /* Skip the first two rows */
        run;

        /* Rename the first column to Date */
        data work.&ticker._data;
            set work.&ticker._data;
            rename Price = Date; /* Rename the first column (Price) to Date */
        run;

        /* Print the first few rows of the dataset to check */
        proc print data=work.&ticker._data(obs=10);
        run;
    %end;
    %else %do;
        %put ERROR: The file &csv_path does not exist.;
    %end;
%mend;

%macro generate_volume_chart(dataset);
	/* Check if the dataset parameter is provided */
    %if &dataset=%then
		%do;
			%put ERROR: Dataset parameter is missing.;
			%return;
		%end;

	/* Set a dynamic title for the chart */
	title "Average Volume for Stock: &dataset";

	PROC CHART DATA=&dataset;
		/* Create a horizontal bar chart to show the Average Volume for the stock dataset */
		HBAR DATE / SUMVAR=Volume TYPE=MEAN;
	RUN;

	/* Clear the title after the procedure */
	title;
%mend generate_volume_chart;

%macro moving_average(dataset, window);
	DATA &dataset._moving_avg;
		SET &dataset;
		MA_Close=MEAN(LAG1(Close), LAG2(Close), LAG3(Close), LAG4(Close), 
			LAG5(Close));
		FORMAT MA_Close 8.2;
	RUN;

	PROC PRINT DATA=&dataset._moving_avg;
		TITLE "Stock Prices with &window-Day Moving Average for &dataset";
		VAR Date Close MA_Close;
	RUN;

%mend moving_average;

%macro calculate_volatility(dataset, window);
	PROC EXPAND DATA=&dataset OUT=&dataset._volatility METHOD=none;
		CONVERT Close=Volatility / TRANSFORMOUT=(MOVSTD &window);
	RUN;

	PROC PRINT DATA=&dataset._volatility;
		TITLE "Volatility of Stock Price for &dataset (Window: &window Days)";
		VAR Date Close Volatility;
	RUN;

%mend calculate_volatility;

%macro plot_stock_trend(dataset);
	PROC SGPLOT DATA=&dataset;
		TITLE "Stock Price Trend for &dataset";
		SERIES X=Date Y=Open / LINEATTRS=(COLOR=blue) LEGENDLABEL="Open";
		SERIES X=Date Y=High / LINEATTRS=(COLOR=green) LEGENDLABEL="High";
		SERIES X=Date Y=Low / LINEATTRS=(COLOR=red) LEGENDLABEL="Low";
		SERIES X=Date Y=Close / LINEATTRS=(COLOR=black) LEGENDLABEL="Close";
		XAXIS LABEL="Date";
		YAXIS LABEL="Price";
	RUN;

%mend plot_stock_trend;

%macro correlation_analysis(dataset);
	PROC CORR DATA=&dataset;
		TITLE "Correlation Between Volume and Close Price for &dataset";
		VAR Volume Close;
	RUN;

%mend correlation_analysis;

%macro plot_volume_trend(dataset);
	PROC SGPLOT DATA=&dataset;
		TITLE "Volume Trend for &dataset";
		SERIES X=Date Y=Volume / LINEATTRS=(COLOR=blue) LEGENDLABEL="Volume";
		XAXIS LABEL="Date";
		YAXIS LABEL="Volume";
	RUN;

%mend plot_volume_trend;

%macro candlestick_chart(dataset);
	PROC SGPLOT DATA=&dataset;
		TITLE "Candlestick Chart for &dataset";

		/* Plot high and low prices using the HIGHLOW statement */
		HIGHLOW X=Date HIGH=High LOW=Low / TYPE=BAR;

		/* Plot open and close prices as scatter plots to simulate candlestick */
		SCATTER X=Date Y=Open / MARKERATTRS=(SYMBOL=CircleFilled COLOR=green) 
			LEGENDLABEL="Open";
		SCATTER X=Date Y=Close / MARKERATTRS=(SYMBOL=CircleFilled COLOR=red) 
			LEGENDLABEL="Close";
		XAXIS LABEL="Date";
		YAXIS LABEL="Price";
		KEYLEGEND / POSITION=RIGHT;
	RUN;

%mend candlestick_chart;

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

%open_csv_as_dataset(&ticker, &start_date, &end_date, &root_path);

PROC SQL;
	CREATE TABLE mydblib.&ticker AS
	SELECT *
	FROM work.&ticker._data;
QUIT;

LIBNAME STOCKS BASE
"&root_path";

%generate_volume_chart(work.&ticker._data);

%moving_average(work.&ticker._data, 5);

%calculate_volatility(work.&ticker._data, 5);

%plot_stock_trend(work.&ticker._data);

%correlation_analysis(work.&ticker._data);

%plot_volume_trend(work.&ticker._data);

%candlestick_chart(work.&ticker._data);