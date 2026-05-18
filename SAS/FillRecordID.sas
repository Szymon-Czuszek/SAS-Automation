DATA &_output1;
    SET &_input1;

    /* --- STEP 1: Retain previous MainRecordID value --- */
    RETAIN prev_MainRecordID;

    /* --- STEP 2: Fill missing MainRecordID values --- */
    IF MISSING(MainRecordID) THEN DO;

        /* Initialize first observation */
        IF _N_ = 1 THEN 
            MainRecordID = 1;

        /* Otherwise increment based on previous value */
        ELSE 
            MainRecordID = prev_MainRecordID + 1;

    END;

    /* --- STEP 3: Store current value for next iteration --- */
    prev_MainRecordID = MainRecordID;

RUN;
