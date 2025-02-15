data &_output1;
    set &_input1;
    retain prev_MainRecordID;  /* Retain previous value of MainRecordID */
    
    if missing(MainRecordID) then do;  
        if _N_ = 1 then MainRecordID = 1;  /* Initialize first row with 1 */
        else MainRecordID = prev_MainRecordID + 1;  /* Increment previous value */
    end;

    prev_MainRecordID = MainRecordID;  /* Update prev_MainRecordID for next row */

run;
