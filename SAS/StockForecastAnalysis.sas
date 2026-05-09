/*============================================================================*/
/* STEP 1: Perform paired t-test                                               */
/*============================================================================*/

/*
   PROC TTEST is used to determine whether there is a statistically
   significant difference between forecasts generated:
   
   - before the AI revolution
   - after the AI revolution

   Since both forecasts relate to the same companies/time series,
   a paired t-test is appropriate.
*/

PROC TTEST DATA=&_input1;

    /* Compare paired forecast observations */
    PAIRED 
        ForecastBeforeRevolution *
        ForecastAfterRevolution;

RUN;


/*============================================================================*/
/* STEP 2: Create scatter plot comparison                                     */
/*============================================================================*/

/*
   Visualize forecast values before and after the AI revolution
   for each company ticker.
*/

PROC SGPLOT DATA=&_input1;

    /* Forecasts before AI revolution */
    SCATTER 
        X=Ticker
        Y=ForecastBeforeRevolution /

        MARKERATTRS=(
            SYMBOL=CIRCLE
        );

    /* Forecasts after AI revolution */
    SCATTER 
        X=Ticker
        Y=ForecastAfterRevolution /

        MARKERATTRS=(
            SYMBOL=SQUARE
            COLOR=RED
        );

    /* Axis labels */
    XAXIS LABEL="Ticker";
    YAXIS LABEL="Forecast Value";

RUN;


/*============================================================================*/
/* STEP 3: Calculate correlation between forecasts                            */
/*============================================================================*/

/*
   PROC CORR measures the strength and direction
   of the relationship between:

   - ForecastBeforeRevolution
   - ForecastAfterRevolution
*/

PROC CORR DATA=&_input1;

    VAR 
        ForecastBeforeRevolution
        ForecastAfterRevolution;

RUN;


/*============================================================================*/
/* STEP 4: Generate panel time series comparison                              */
/*============================================================================*/

/*
   PROC SGPANEL creates separate plots for each ticker
   to compare forecast behavior over time.

   This allows:
   - company-level comparison
   - visual trend analysis
   - identification of structural differences
*/

PROC SGPANEL DATA=&_input1;

    /* Create separate panels for each ticker */
    PANELBY 
        Ticker /

        COLUMNS=3
        ROWS=6
        UNISCALE=ROW;

    /* Forecast before AI revolution */
    SERIES 
        X=Date
        Y=ForecastBeforeRevolution /

        LINEATTRS=(
            PATTERN=SOLID
            COLOR=BLUE
        );

    /* Forecast after AI revolution */
    SERIES 
        X=Date
        Y=ForecastAfterRevolution /

        LINEATTRS=(
            PATTERN=DASH
            COLOR=RED
        );

    /* Axis labels */
    COLAXIS LABEL="Date";
    ROWAXIS LABEL="Stock Price";

    /* Chart title */
    TITLE 
    "Panel Comparison of Forecasts Before and After AI Revolution";

RUN;


/*============================================================================*/
/* STEP 5: Calculate forecast differences and percentage changes              */
/*============================================================================*/

/*
   Create analytical variables measuring:
   - absolute forecast difference
   - relative percentage change

   These variables quantify the impact
   of the AI revolution on stock forecasts.
*/

DATA &_output1;

    SET &_input1;

    /* Absolute difference between forecasts */
    FORECAST_DELTA =
        ForecastAfterRevolution -
        ForecastBeforeRevolution;

    /* Relative percentage change */
    PCT_CHANGE =
        (
            ForecastAfterRevolution -
            ForecastBeforeRevolution
        )
        /
        ForecastBeforeRevolution
        * 100;

RUN;


/*============================================================================*/
/* Commentary                                                                 */
/*============================================================================*/

/*
   PROC TTEST
   ----------------------------------------------------------------
   Performs a paired t-test comparing two related samples.

   Hypotheses:
   ------------------------------------------------
   H0:
   No significant difference exists between forecasts.

   H1:
   Significant differences exist between forecasts.


   Why a Paired Test?
   ----------------------------------------------------------------
   The same companies are analyzed:
   - before AI revolution
   - after AI revolution

   Therefore observations are dependent/paired.


   PROC CORR
   ----------------------------------------------------------------
   Measures correlation between forecasts.

   Interpretation:
   ------------------------------------------------
   Correlation close to:
   +1  -> strong positive relationship
    0  -> weak/no relationship
   -1  -> strong negative relationship

   High correlation suggests:
   - forecast structures remained similar

   Lower correlation may indicate:
   - AI revolution changed market behavior


   Scatter Plot
   ----------------------------------------------------------------
   Visual comparison of forecast values.

   Helps identify:
   - outliers
   - shifts in valuation
   - companies most affected by AI trends


   PROC SGPANEL
   ----------------------------------------------------------------
   Creates multi-panel time series visualizations.

   Advantages:
   - company-by-company comparison
   - easier trend interpretation
   - structural pattern detection


   FORECAST_DELTA
   ----------------------------------------------------------------
   Measures absolute forecast difference.

   Positive values:
   - forecast increased after AI revolution

   Negative values:
   - forecast decreased after AI revolution


   PCT_CHANGE
   ----------------------------------------------------------------
   Measures relative percentage impact.

   Formula:
   ------------------------------------------------
   (
       After Forecast - Before Forecast
   )
   /
   Before Forecast
   × 100


   Example:
   ------------------------------------------------
   Before Forecast = 100
   After Forecast  = 130

   PCT_CHANGE = 30%

   Interpretation:
   Forecast increased by 30% after AI revolution.


   Analytical Importance
   ----------------------------------------------------------------
   This workflow enables:
   - statistical validation
   - visual comparison
   - structural trend analysis
   - AI impact measurement
   - cross-company comparison

   It supports research into whether the emergence
   of generative AI technologies introduced measurable
   changes in stock market expectations.
*/
