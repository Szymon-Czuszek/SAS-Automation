/* --- STEP 1: Include external SAS script with ARMA macro --- */
/* This file should contain the %ARMA macro definition */
%INCLUDE "/export/viya/homes/szymon.czuszek@edu.uekat.pl/casuser/Automatyzacja_procesow/SAS Curiosity Cup 2025/ForecastARMA.sas";


/* --- STEP 2: Initialize dataset to store all forecast results --- */
DATA ALL_DATA;
    LENGTH TICKER $10;  /* Ensure consistent length for ticker variable */
    STOP;               /* Prevent creation of an empty observation */
RUN;


/* --- STEP 3: Loop through ticker list and execute ARMA macro --- */
DATA _NULL_;
    SET WORK.TickerList;

    /* Dynamically build and execute macro calls */
    CALL EXECUTE(
        '%ARMA(' || STRIP(NAME) || ', &_input1, ' || STRIP(NAME) || ')'
    );

RUN;


/* --- STEP 4: Save final combined results --- */
DATA &_output1;
    SET ALL_DATA;
RUN;
