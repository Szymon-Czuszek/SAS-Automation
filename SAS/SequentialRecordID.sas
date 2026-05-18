/*============================================================================*/
/* STEP 1: Create unique MainRecordID variable                                */
/*============================================================================*/

/*
   This DATA step creates a new variable called MainRecordID
   that uniquely identifies each observation in the dataset.

   The identifier is generated sequentially using
   the SAS automatic variable _N_.
*/

DATA &_output1;

    /* Read observations from input dataset */
    SET &_input1;

    /* Assign sequential unique identifier */
    MainRecordID = _N_;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   SET &_input1
   ----------------------------------------------------------------
   Reads observations from the input dataset specified
   dynamically using a SAS macro variable.


   _N_
   ----------------------------------------------------------------
   _N_ is an automatic SAS variable representing
   the current iteration number of the DATA step.

   Characteristics:
   - Starts at 1
   - Automatically increments for each observation
   - Exists temporarily during execution
   - Not stored unless explicitly assigned


   MainRecordID = _N_
   ----------------------------------------------------------------
   Creates a permanent variable called MainRecordID
   containing unique sequential numbers.

   Example:
   ------------------------------------------------
   Observation    MainRecordID
   --------------------------------
        1               1
        2               2
        3               3


   Purpose of MainRecordID
   ----------------------------------------------------------------
   This variable can be used to:
   - uniquely identify observations
   - preserve row order
   - support joins and merges
   - track records across transformations
   - simplify debugging and validation
   - create reference keys for analysis


   Common Use Cases
   ----------------------------------------------------------------
   - Time series processing
   - Financial datasets
   - Forecast result tracking
   - Data integration
   - Record matching
   - Automated ETL workflows


   Important Note
   ----------------------------------------------------------------
   The generated IDs depend on the current observation order.

   If the dataset is:
   - sorted
   - filtered
   - reshaped

   the MainRecordID values may change.

   To preserve consistency:
   - assign IDs after final sorting if stable numbering is required.
*/
