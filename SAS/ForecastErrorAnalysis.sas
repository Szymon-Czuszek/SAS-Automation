/* --- STEP 1: Calculate Absolute Forecast Errors (AFE) --- */
DATA &_output1;
    SET &_input1;

    /* Absolute Forecast Error before the AI revolution */
    AFE_Before = ABS(ForecastBeforeRevolution - CloseAfter);

    /* Absolute Forecast Error after the AI revolution */
    AFE_After  = ABS(ForecastAfterRevolution - CloseAfter);

RUN;


/* --- STEP 2: Visualize comparison using boxplots --- */
PROC SGPLOT DATA=&_output1;

    /* Boxplot: Before AI revolution */
    VBOX AFE_Before / 
        CATEGORY=Ticker 
        FILLATTRS=(COLOR=blue)
        NAME="before";

    /* Boxplot: After AI revolution */
    VBOX AFE_After / 
        CATEGORY=Ticker 
        FILLATTRS=(COLOR=yellow)
        NAME="after";

    /* Axis labels */
    XAXIS LABEL="Company Ticker";
    YAXIS LABEL="Absolute Forecast Error (AFE)";

    /* Title */
    TITLE "Forecast Error Before vs. After AI Revolution";

RUN;
