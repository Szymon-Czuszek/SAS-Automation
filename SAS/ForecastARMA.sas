%MACRO ARMA(TICKER, INPUT, OUTPUT);
	/* Perform ARIMA modeling on the selected ticker's closing price */
	PROC ARIMA DATA=&INPUT;
		IDENTIFY VAR="('Close', '&TICKER')"N;

		/* Identify the time series for the given ticker */
		ESTIMATE P=1 Q=1;

		/* Estimate ARIMA model with (1,1) parameters */
		FORECAST LEAD=800 OUT=&OUTPUT;

		/* Generate a 30-day forecast */
	RUN;

	/* Rename the forecasted column and add a Ticker column */
	DATA &OUTPUT;
		SET &OUTPUT;
		RENAME "('Close', '&TICKER')"N=CLOSE;

		/* Rename dynamically created column to 'CLOSE' */
		TICKER="&TICKER";

		/* Add the TICKER column for identification */
	RUN;

	/* Append the new forecast data to the ALL_DATA dataset */
	DATA ALL_DATA;
		SET ALL_DATA &OUTPUT;
	RUN;

%MEND ARMA;