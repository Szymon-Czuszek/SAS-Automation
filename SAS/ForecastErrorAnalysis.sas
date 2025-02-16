/* Creating new variables to calculate the absolute forecast error for both periods */

DATA &_output1;
	SET &_input1;

	/* Calculate the absolute forecast error before the revolution */
	AFE_Before=ABS(ForecastBeforeRevolution - CloseAfter);

	/* Calculate the absolute forecast error after the revolution */
	AFE_After=ABS(ForecastAfterRevolution - CloseAfter);
RUN;

/* Generate a boxplot comparing the absolute forecast errors before and after the AI revolution */
PROC SGPLOT DATA=&_output1;
	/* Create a boxplot for absolute forecast error before the AI revolution, color it blue */
	VBOX AFE_Before / CATEGORY=Ticker FILLATTRS=(COLOR=blue);

	/* Create a boxplot for absolute forecast error after the AI revolution, color it yellow */
	VBOX AFE_After / CATEGORY=Ticker FILLATTRS=(COLOR=yellow);

	/* Label the x-axis as Company Ticker */
	XAXIS LABEL="Company Ticker";

	/* Label the y-axis as Absolute Forecast Error (AFE) */
	YAXIS LABEL="Absolute Forecast Error (AFE)";

	/* Title the plot with a clear description of the analysis */
	TITLE "Forecast Error Before vs. After AI Revolution";
RUN;