/* Perform paired t-test to compare the forecasts before and after the AI revolution */

PROC TTEST DATA=&_input1;
	PAIRED ForecastBeforeRevolution*ForecastAfterRevolution;
RUN;

/* Create a scatter plot to compare the forecast values before and after the AI revolution */
PROC SGPLOT DATA=&_input1;
	/* Scatter plot for ForecastBeforeRevolution with circular markers */
	SCATTER X=Ticker Y=ForecastBeforeRevolution / MARKERATTRS=(SYMBOL=CIRCLE);

	/* Scatter plot for ForecastAfterRevolution with square red markers */
	SCATTER X=Ticker Y=ForecastAfterRevolution / MARKERATTRS=(SYMBOL=SQUARE 
		COLOR=RED);

	/* Label the x-axis as Ticker */
	XAXIS LABEL="Ticker";

	/* Label the y-axis as Forecast Value */
	YAXIS LABEL="Forecast Value";
RUN;

/* Calculate correlation between forecasts before and after the AI revolution */
PROC CORR DATA=&_input1;
	VAR ForecastBeforeRevolution ForecastAfterRevolution;
RUN;

/* Generate a panel plot comparing forecasts before and after the AI revolution for each ticker */
PROC SGPANEL DATA=&_input1;
	/* Panel by Ticker, arranging them into 3 columns and 6 rows */
	PANELBY Ticker / COLUMNS=3 ROWS=6 UNISCALE=ROW;

	/* Line plot for ForecastBeforeRevolution (solid blue line) */
	SERIES X=Date Y=ForecastBeforeRevolution / LINEATTRS=(PATTERN=SOLID 
		COLOR=BLUE);

	/* Line plot for ForecastAfterRevolution (dashed red line) */
	SERIES X=Date Y=ForecastAfterRevolution / LINEATTRS=(PATTERN=DASH COLOR=RED);

	/* Label x-axis as Date */
	COLAXIS LABEL="Date";

	/* Label y-axis as Stock Price */
	ROWAXIS LABEL="Stock Price";

	/* Add a title to the panel plot */
	TITLE "Panel Comparison of Forecasts Before and After AI Revolution";
RUN;

/* Create new variables: forecast delta and percentage change between the two forecasts */
DATA &_output1;
	SET &_input1;

	/* Calculate the difference between ForecastAfterRevolution and ForecastBeforeRevolution */
	FORECAST_DELTA=ForecastAfterRevolution - ForecastBeforeRevolution;

	/* Calculate the percentage change between the forecasts */
	PCT_CHANGE=(ForecastAfterRevolution - ForecastBeforeRevolution) / 
		ForecastBeforeRevolution * 100;
RUN;