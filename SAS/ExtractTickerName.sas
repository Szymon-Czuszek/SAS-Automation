DATA &_output1;
	SET &_input1;

	/* Remove special characters using COMPRESS */
	NAME=COMPRESS(NAME, "(),' ");

	/* Remove the word 'close' (case insensitive) */
	NAME=TRANWRD(NAME, 'close', '');
	NAME=TRANWRD(NAME, 'CLOSE', '');

	/* For uppercase 'CLOSE' */
	NAME=TRANWRD(NAME, 'Close', '');
RUN;