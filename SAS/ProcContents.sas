/*============================================================================*/
/* STEP 1: Extract column names from the input dataset                        */
/*============================================================================*/

/* 
   PROC CONTENTS retrieves metadata information about a SAS dataset.
   In this case, only the variable names are extracted and stored
   in the output dataset.
*/

PROC CONTENTS 
    DATA=&_input1
    OUT=&_output1(KEEP=name)
    NOPRINT;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   DATA=&_input1
   ----------------
   Specifies the source dataset whose metadata will be analyzed.


   OUT=&_output1(KEEP=name)
   -------------------------
   Creates an output dataset containing metadata information.

   KEEP=name restricts the output to only the variable:
       - NAME → column names from the source dataset

   This produces a clean dataset containing only column names.


   NOPRINT
   --------
   Prevents PROC CONTENTS from printing metadata results
   to the SAS output window/log.


   Example Output
   ---------------
   NAME
   -----
   Date
   Open
   High
   Low
   Close
   Volume


   Common Use Cases
   ----------------
   - Dynamic macro generation
   - Automated ETL processes
   - Dataset validation
   - Variable name cleaning
   - Metadata-driven workflows
   - Preparing variable lists for loops/macros
*/
