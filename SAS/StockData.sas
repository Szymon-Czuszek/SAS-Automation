DATA &_output1;
	LENGTH Ticker $10 Company $50 Sector $30;
	INFILE datalines DELIMITER=' ';
	INPUT Ticker Company Sector;
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

/* Check dataset */
PROC PRINT DATA=&_output1;
RUN;