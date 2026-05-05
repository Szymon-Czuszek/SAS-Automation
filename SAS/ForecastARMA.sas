%MACRO ARMA(TICKER, INPUT, OUTPUT);

    /* --- STEP 1: ARIMA modeling for selected ticker --- */
    PROC ARIMA DATA=&INPUT;

        /* Identify the time series (dynamic column name) */
        IDENTIFY VAR="('Close', '&TICKER')"N;

        /* Estimate ARMA(1,1) model */
        ESTIMATE P=1 Q=1;

        /* Generate forecast (LEAD = number of periods ahead) */
        FORECAST LEAD=800 OUT=&OUTPUT;

    RUN;

    /* --- STEP 2: Post-process forecast output --- */
    DATA &OUTPUT;
        SET &OUTPUT;

        /* Rename dynamically created column to a standard name */
        RENAME "('Close', '&TICKER')"N = CLOSE;

        /* Add ticker identifier */
        TICKER = "&TICKER";

    RUN;

    /* --- STEP 3: Append results to master dataset --- */
    DATA ALL_DATA;
        SET ALL_DATA &OUTPUT;
    RUN;

%MEND ARMA;
