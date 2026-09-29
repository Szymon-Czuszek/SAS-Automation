/*============================================================================*/
/* STEP 1: Create the output dataset                                         */
/*============================================================================*/

DATA &_output1;

    /*
        Read all observations and variables from the input dataset.

        &_input1 and &_output1 are macro variables, meaning that their
        actual dataset names are supplied dynamically when the code runs.
    */
    SET &_input1;

        /*------------------------------------------------------------------------*/
    /* STEP 2: Remove unwanted special characters from NAME                  */
    /*------------------------------------------------------------------------*/
    NAME = COMPRESS(NAME, "(),' ");

    /* --- STEP 2: Remove the word 'close' (case-insensitive) --- */
        /*------------------------------------------------------------------------*/
    /* STEP 2: Remove unwanted special characters from NAME                  */
    /*------------------------------------------------------------------------*/

    /*
        COMPRESS() removes specified characters from a character variable.

        Here, we remove:
            (   -> opening parenthesis
            )   -> closing parenthesis
            ,   -> comma
            '   -> apostrophe
            [space] -> spaces

        The cleaned value is assigned back to NAME.

        Example:
            "John (Close), Smith"
                ->
            "JohnCloseSmith"
    */
    NAME = COMPRESS(NAME, "(),' ");
    /* TRANWRD is case-sensitive, so we handle all common variations */

    NAME = TRANWRD(NAME, 'close', '');
    NAME = TRANWRD(NAME, 'CLOSE', '');
    NAME = TRANWRD(NAME, 'Close', '');

RUN;
