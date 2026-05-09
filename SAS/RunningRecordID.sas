/*============================================================================*/
/* STEP 1: Create sequential RecordID within each Ticker group                */
/*============================================================================*/

/*
   This DATA step generates a sequential RecordID
   separately for each stock ticker.

   The numbering:
   - starts at 1 for each new Ticker group
   - increments for subsequent observations
*/

DATA &_output1;

    /* Read input dataset */
    SET &_input1;

    /* Group observations by Ticker */
    BY Ticker;

    /* Initialize RecordID for first observation in each group */
    IF FIRST.Ticker THEN
        RecordID = 1;

    /* Increment RecordID for remaining observations */
    ELSE
        RecordID + 1;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   BY Ticker
   ----------------------------------------------------------------
   Processes the dataset in groups based on the Ticker variable.

   IMPORTANT:
   The dataset MUST be sorted before using BY processing.

   Example:
   ------------------------------------------------
   PROC SORT DATA=&_input1;
       BY Ticker;
   RUN;


   FIRST.Ticker
   ----------------------------------------------------------------
   FIRST.Ticker is an automatic SAS temporary variable.

   It equals:
   - 1 → for the first observation in a Ticker group
   - 0 → for all remaining observations

   Example:
   ------------------------------------------------
   Ticker    FIRST.Ticker
   -----------------------
   AAPL           1
   AAPL           0
   AAPL           0
   MSFT           1
   MSFT           0


   RecordID = 1
   ----------------------------------------------------------------
   Resets numbering when a new Ticker group begins.


   RecordID + 1
   ----------------------------------------------------------------
   Sum statement syntax automatically:
   - retains the variable value
   - increments by 1
   - handles missing values safely

   Equivalent to:
   ------------------------------------------------
   RETAIN RecordID;
   RecordID = RecordID + 1;


   Example Output
   ----------------------------------------------------------------

   Input:
   ------------------------------------------------
   Ticker    Date
   -------------------------
   AAPL      2022-01-01
   AAPL      2022-01-02
   MSFT      2022-01-01
   MSFT      2022-01-02

   Output:
   ------------------------------------------------
   Ticker    Date         RecordID
   --------------------------------
   AAPL      2022-01-01       1
   AAPL      2022-01-02       2
   MSFT      2022-01-01       1
   MSFT      2022-01-02       2


   Common Use Cases
   ----------------------------------------------------------------
   - Time series indexing
   - Per-company observation tracking
   - Rolling window analysis
   - ARIMA preprocessing
   - Sequential stock analysis
   - Group-based calculations


   Important Consideration
   ----------------------------------------------------------------
   If the dataset is NOT sorted by Ticker before execution,
   SAS may generate incorrect group boundaries or errors.

   Recommended preprocessing:
   ------------------------------------------------
   PROC SORT DATA=&_input1;
       BY Ticker Date;
   RUN;
*/
