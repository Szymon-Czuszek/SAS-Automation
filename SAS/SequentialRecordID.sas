/* Create a new variable 'MainRecordID' to uniquely identify each record in the dataset */

DATA &_output1;
	SET &_input1;

	/* Assign a unique sequential ID number to each record based on its position in the dataset */
	MainRecordID=_N_;
RUN;