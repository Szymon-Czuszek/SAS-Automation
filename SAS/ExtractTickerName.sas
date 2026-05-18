DATA &_output1;
    SET &_input1;

    /* --- STEP 1: Remove unwanted special characters --- */
    /* Removes parentheses, commas, apostrophes, and spaces */
    NAME = COMPRESS(NAME, "(),' ");

    /* --- STEP 2: Remove the word 'close' (case-insensitive) --- */
    /* TRANWRD is case-sensitive, so we handle all common variations */

    NAME = TRANWRD(NAME, 'close', '');
    NAME = TRANWRD(NAME, 'CLOSE', '');
    NAME = TRANWRD(NAME, 'Close', '');

RUN;
