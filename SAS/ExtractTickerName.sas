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


    /*------------------------------------------------------------------------*/
    /* STEP 3: Remove the word "close"                                        */
    /*------------------------------------------------------------------------*/

    /*
        TRANWRD() replaces an exact character string with another string.

        Syntax:
            TRANWRD(source, from, to)

        SAS's TRANWRD() function is case-sensitive.

        Therefore, these three statements handle the most common
        capitalization variations of the word "close".
    */

    /* Remove lowercase "close" */
    NAME = TRANWRD(NAME, 'close', '');

    /* Remove uppercase "CLOSE" */
    NAME = TRANWRD(NAME, 'CLOSE', '');

    /* Remove title-case "Close" */
    NAME = TRANWRD(NAME, 'Close', '');


RUN;