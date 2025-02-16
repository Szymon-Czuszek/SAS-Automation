/* Include the external SAS script that contains the ARMA forecasting macro */
%INCLUDE "/export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/Automatyzacja_procesow/SAS Curiosity Cup 2025/ForecastARMA.sas";

/* Create an empty dataset to store all forecasted data */
DATA ALL_DATA;
	LENGTH TICKER $10;

	/* Define column 'TICKER' as a character variable with a maximum length of 10 */
RUN;

/* Iterate over each ticker in the ticker list and execute the ARMA macro */
DATA _NULL_;
	SET WORK.TickerList;

	/* Read the list of tickers from the WORK library */
	/* Dynamically generate and execute the ARMA macro call for each ticker */
	CALL EXECUTE('%ARMA(' || NAME || ', &_input1, ' || NAME || ')');
RUN;

/* Store the results of all ARMA forecasts in the final dataset */
DATA &_output1;
	SET ALL_DATA;

	/* Append forecasted data to the output dataset */
RUN;