DATA &_output1;
    SET &_input1;
    BY Ticker; /* Group the data by Ticker */
    IF FIRST.Ticker THEN RecordID = 1; /* Reset RecordID for the first record in each group */
    ELSE RecordID + 1; /* Increment RecordID for subsequent records in the group */
RUN;