/*============================================================================*/
/* STEP 1: Create company classification dataset                              */
/*============================================================================*/

/*
   This DATA step creates a structured dataset containing:
   - stock ticker symbols
   - company names
   - industry/sector classifications

   The dataset is manually entered using DATALINES.
*/

DATA &_output1;

    /* Define variable lengths */
    LENGTH 
        Ticker $10
        Company $50
        Sector $30;

    /* Read inline data */
    INFILE datalines DELIMITER=' ';

    /* Define input variables */
    INPUT 
        Ticker
        Company
        Sector;

    /* Inline dataset values */
    DATALINES;
NVDA NVIDIA Semiconductors
MSFT Microsoft Technology
GOOGL Alphabet_(Class_A) Technology
META Meta_Platforms Technology
AMZN Amazon Technology
AMD AMD Semiconductors
INTC Intel Semiconductors
TSM Taiwan_Semiconductor Semiconductors
IBM IBM Enterprise_AI
ORCL Oracle Enterprise_AI
SNOW Snowflake Enterprise_AI
TSLA Tesla Automation_&_Robotics
PATH UiPath Automation_&_Robotics
PLTR Palantir Cybersecurity_&_AI
CRWD CrowdStrike Cybersecurity_&_AI
MRNA Moderna Healthcare_&_AI
ILMN Illumina Healthcare_&_AI
PFE Pfizer Healthcare_&_AI
;
RUN;


/*============================================================================*/
/* STEP 2: Display created dataset                                            */
/*============================================================================*/

/*
   PROC PRINT is used to validate:
   - successful data loading
   - correct variable structure
   - observation accuracy
*/

PROC PRINT DATA=&_output1;
RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   LENGTH Statement
   ----------------------------------------------------------------
   Defines variable types and maximum storage lengths.

   Variable definitions:
   ------------------------------------------------
   Ticker   -> Character variable (max 10 characters)
   Company  -> Character variable (max 50 characters)
   Sector   -> Character variable (max 30 characters)


   INFILE DATALINES
   ----------------------------------------------------------------
   Allows inline manual data entry directly inside the SAS program.

   DELIMITER=' '
   ----------------
   Uses spaces as separators between values.


   INPUT Statement
   ----------------------------------------------------------------
   Specifies the order in which values are read into variables.

   Example:
   ------------------------------------------------
   NVDA NVIDIA Semiconductors

   Maps to:
   ------------------------------------------------
   Ticker   = NVDA
   Company  = NVIDIA
   Sector   = Semiconductors


   Underscores in Values
   ----------------------------------------------------------------
   Underscores are used to preserve multi-word values.

   Example:
   ------------------------------------------------
   Alphabet_(Class_A)

   instead of:
   ------------------------------------------------
   Alphabet (Class A)

   This prevents SAS from splitting values incorrectly
   when using space delimiters.


   Sector Classification
   ----------------------------------------------------------------
   The dataset groups companies into AI-related sectors:

   - Technology
   - Semiconductors
   - Enterprise AI
   - Automation & Robotics
   - Cybersecurity & AI
   - Healthcare & AI

   This classification supports:
   - sector-level analysis
   - AI industry comparisons
   - grouped forecasting
   - market trend evaluation


   Practical Use Cases
   ----------------------------------------------------------------
   - AI stock market research
   - Sector-based forecasting
   - Portfolio grouping
   - Statistical segmentation
   - Comparative analytics
   - Financial visualization


   PROC PRINT
   ----------------------------------------------------------------
   Displays the dataset contents for validation purposes.

   Useful for:
   - debugging
   - confirming imports
   - checking variable formatting
   - validating observations
*/
