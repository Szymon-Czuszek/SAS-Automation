/* Extract column names */

PROC CONTENTS DATA=&_input1 OUT=&_output1(keep=name) NOPRINT;
RUN;