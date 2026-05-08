/*============================================================================*/
/* STEP 1: Create sequential record identifier                                */
/*============================================================================*/

/*
   This DATA step creates a new variable called RecordID
   containing a unique sequential number for each observation.

   The numbering is generated automatically using the SAS
   automatic variable _N_.
*/

DATA &_output1;

    /* Read observations from input dataset */
    SET &_input1;

    /* Assign sequential row number */
    RecordID = _N_;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   SET &_input1
   ----------------------------------------------------------------
   Reads observations from the input dataset specified
   dynamically using a macro variable.


   _N_
   ----------------------------------------------------------------
   _N_ is an automatic SAS variable representing
   the current iteration number of the DATA step.

   Characteristics:
   - Starts at 1
   - Increments automatically for each observation
   - Not stored in the final dataset unless explicitly assigned


   RecordID = _N_
   ----------------------------------------------------------------
   Creates a permanent variable called RecordID
   containing sequential row numbers.

   Example:
   ------------------------------------------------
   Observation    RecordID
   ------------------------
        1             1
        2             2
        3             3


   Common Use Cases
   ----------------------------------------------------------------
   - Creating unique row identifiers
   - Tracking observations
   - Supporting joins and merges
   - Data validation
   - Sorting and indexing
   - Preparing datasets for analytics


   Important Note
   ----------------------------------------------------------------
   RecordID values depend on the current order
   of observations in the dataset.

   If the dataset order changes:
   - RecordID values will also change.

   To ensure reproducibility:
   - sort data before assigning IDs if needed.
*/
