********************************************************************************* 
******************************* QA_MACROS.sas ***********************************
********************************************************************************* 

This file contains the CESR QA macro library, including standard utilities 
used by QA programs and distributed to CESR sites. 

Changes to functionality must be reflected in CESR_QA_MACRO_LIBRARY.DOC

Created and maintained by CESR
https://cesr.kp.org/

********************************************************************************* 
********************************************************************************* 
********************************************************************************* 


******************************* CESR_AGE *********************************** 
******************************* CESR_AGE ***********************************

CESR_AGE - This macro calculates the age using the SAS tip written by
William Kreuter, a senior computer specialist at the University of Washington
in Seattle.  Tip and note found at http://support.sas.com/kb/24/808.html 

No data set is created.
No report is created.
An age as a whole number is returned.

The variable birth_date is the default value for the BDtVar parameter.
The RefDate parameter must receive a value at invocation.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011
******************************* CESR_AGE ***********************************
******************************* CESR_AGE ***********************************;
%macro CESR_Age(BDtVar=birth_date, RefDate=) ;
    floor((intck('month',&BDtVar,&RefDate)-
    (day(&RefDate)<day(&BDtVar)))/12)
%mend CESR_Age ;

 
******************************* CESR_SYMBOLCHECK *********************************** 
******************************* CESR_SYMBOLCHECK ***********************************

CESR_SYMBOLCHECK - This macro checks that the macro variables CONTENT_AREA, ERA, and
VERSION have been assigned correctly. 

If any of the variables do not exist or is not
assigned a string in the correct format, the macro will stop program execution (but
not end an interactive SAS session). The macro also generates error messages
instructing the user to create appropriate macro variable assignments.

If all variables are correctly assigned, no message will be produced, and the program
will continue to execute normally.

No data set is created.
No report is created.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
					 Jenny.Staab@kpchr.org		503-335-6683
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  08/2012
******************************* CESR_SYMBOLCHECK ***********************************
******************************* CESR_SYMBOLCHECK ***********************************;

%macro CESR_SYMBOLCHECK;

	%local CONTENT_AREA_EXIST CONTENT_AREA_CORRECT ERA_EXIST ERA_CORRECT VERSION_EXIST VERSION_CORRECT STOPEXECUTION QAOUTLIB_EXIST;
	

	%let CONTENT_AREA_EXIST=0;
	%let CONTENT_AREA_CORRECT=0;
	%let ERA_EXIST=0;
	%let ERA_CORRECT=0;
	%let VERSION_EXIST=0;
	%let VERSION_CORRECT=0;
	%let QAOUTLIB_EXIST=0;
	%let STOPEXECUTION=0;

	data _null_;
		set sashelp.vmacro (where=(scope="GLOBAL")) ;
		if upcase(name)="CONTENT_AREA" then do;
			call symput ('CONTENT_AREA_EXIST','1');
			if anyfirst(value)=1 and length(value) le 8 then call symput ('CONTENT_AREA_CORRECT','1');
		end;
		if upcase(name)="ERA" then do;
			call symput ('ERA_EXIST','1');
			if notdigit(TRIM(value))=0 and length(value)=6 then call symput ('ERA_CORRECT','1');
		end;
		if upcase(name)="VERSION" then do;
			call symput ('VERSION_EXIST','1');
			if 1 le lengthn(value) le 4 then call symput ('VERSION_CORRECT','1');
		end;
		if upcase(name)='QAOUTLIB' then do;
			call symput ('QAOUTLIB_EXIST','1');
		end;

	run;

	%if not &CONTENT_AREA_EXIST %then %do;
		%put WARNING: The macro variable CONTENT_AREA does not exist.;
		%put WARNING: Please assign CONTENT_AREA a string of 1 to 8 characters starting with a letter or _.;
		%put WARNING: The macro variable CONTENT_AREA was set to QA.;
		%global CONTENT_AREA;
		%let CONTENT_AREA = QA;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &CONTENT_AREA_CORRECT %then %do;
		%put WARNING: The macro variable CONTENT_AREA has not been assigned correctly.;
		%put WARNING: Please assign CONTENT_AREA a string of up to 8 characters starting with a letter or _.;
		%put WARNING: The macro variable CONTENT_AREA was set to QA.;
		%let STOPEXECUTION=1;
	%end;
	%if not &ERA_EXIST %then %do;
		%put WARNING: The macro variable ERA does not exist.;
		%put WARNING: Please assign ERA a string of exactly 6 digits (YYYYMM).;
		%put WARNING: The macro variable ERA was set to 000000.;
		%global ERA;
		%let ERA = 000000;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &ERA_CORRECT %then %do;
		%put WARNING: The macro variable ERA was not assigned correctly.;
		%put WARNING: Please assign ERA a string of exactly 6 digits (YYYYMM).;
		%let ERA = 000000;
		%let STOPEXECUTION=1;
	%end;
	%if not &VERSION_EXIST %then %do;
		%put WARNING: The macro variable VERSION does not exist.;
		%put WARNING: Please assign VERSION a string of 1 to 4 characters.;
		%put WARNING: The macro variable VERSION was set to 00.;
		%global VERSION;
		%let VERSION = 00;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &VERSION_CORRECT %then %do;
		%put WARNING: The macro variable VERSION has not been assigned correctly.;
		%put WARNING: Please assign VERSION a string of 1 to 4 characters.;
		%put WARNING: The macro variable VERSION was set to 00.;
		%let VERSION = 00;
		%let STOPEXECUTION=1;
	%end;
	%if not &QAOUTLIB_EXIST %then %do;
		%put WARNING: The macro variable QAOUTLIB has not been assigned.;
		%put WARNING: The macro variable QAOUTLIB was set to WORK. The DCO file will be saved in the WORK library.;
		%global QAOUTLIB;
		%let QAOUTLIB = WORK;
		%let STOPEXECUTION=1;
	%end;

	
	%if &STOPEXECUTION %then %do;
/*		%put ERROR: The program will stop executing and all submitted statements be canceled.;*/
/*		%abort cancel;*/
	%end;


%mend CESR_SYMBOLCHECK;




******************************* CESR_AppendDS ***********************************
******************************* CESR_AppendDS ***********************************

This macro creates the DCO_file that is called in each of the TLC/VLC 
	macros. 

Note that the macro variable ERA must have been assigned a 6-digit string for the
	macro to execute and processing to continue.

Creates 1 dataset (DCO_file)with the following variables:
	Site $4. MemName $32. VarName $32.
	Check_description $256. Result $8. Reason $256. DateRan 8. Era 4. Version $4. 
	Content_Area $8. Check $120. OutDataSet $ 41

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
					 Jenny.Staab@kpchr.org		503-335-6683
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011
Revised:	08/2012

******************************* CESR_AppendDS ***********************************
******************************* CESR_AppendDS ***********************************;
%macro CESR_AppendDS(indataset=);

*verify that ERA has been assigned correctly;
*if not, print error message and stop program execution;
	%local CONTENT_AREA_EXIST CONTENT_AREA_CORRECT ERA_EXIST ERA_CORRECT VERSION_EXIST VERSION_CORRECT STOPEXECUTION QAOUTLIB_EXIST;
	

	%let CONTENT_AREA_EXIST=0;
	%let CONTENT_AREA_CORRECT=0;
	%let ERA_EXIST=0;
	%let ERA_CORRECT=0;
	%let VERSION_EXIST=0;
	%let VERSION_CORRECT=0;
	%let QAOUTLIB_EXIST=0;
	%let STOPEXECUTION=0;

	data _null_;
		set sashelp.vmacro (where=(scope="GLOBAL")) ;
		if upcase(name)="CONTENT_AREA" then do;
			call symput ('CONTENT_AREA_EXIST','1');
			if anyfirst(value)=1 and length(value) le 8 then call symput ('CONTENT_AREA_CORRECT','1');
		end;
		if upcase(name)="ERA" then do;
			call symput ('ERA_EXIST','1');
			if notdigit(TRIM(value))=0 and length(value)=6 then call symput ('ERA_CORRECT','1');
		end;
		if upcase(name)="VERSION" then do;
			call symput ('VERSION_EXIST','1');
			if 1 le lengthn(value) le 4 then call symput ('VERSION_CORRECT','1');
		end;
		if upcase(name)='QAOUTLIB' then do;
			call symput ('QAOUTLIB_EXIST','1');
		end;

	run;

	%if not &CONTENT_AREA_EXIST %then %do;
		%put WARNING: The macro variable CONTENT_AREA does not exist.;
		%put WARNING: Please assign CONTENT_AREA a string of 1 to 8 characters starting with a letter or _.;
		%put WARNING: The macro variable CONTENT_AREA was set to QA.;
		%global CONTENT_AREA;
		%let CONTENT_AREA = QA;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &CONTENT_AREA_CORRECT %then %do;
		%put WARNING: The macro variable CONTENT_AREA has not been assigned correctly.;
		%put WARNING: Please assign CONTENT_AREA a string of up to 8 characters starting with a letter or _.;
		%put WARNING: The macro variable CONTENT_AREA was set to QA.;
		%let STOPEXECUTION=1;
	%end;
	%if not &ERA_EXIST %then %do;
		%put WARNING: The macro variable ERA does not exist.;
		%put WARNING: Please assign ERA a string of exactly 6 digits (YYYYMM).;
		%put WARNING: The macro variable ERA was set to 000000.;
		%global ERA;
		%let ERA = 000000;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &ERA_CORRECT %then %do;
		%put WARNING: The macro variable ERA was not assigned correctly.;
		%put WARNING: Please assign ERA a string of exactly 6 digits (YYYYMM).;
		%let ERA = 000000;
		%let STOPEXECUTION=1;
	%end;
	%if not &VERSION_EXIST %then %do;
		%put WARNING: The macro variable VERSION does not exist.;
		%put WARNING: Please assign VERSION a string of 1 to 4 characters.;
		%put WARNING: The macro variable VERSION was set to 00.;
		%global VERSION;
		%let VERSION = 00;
		%let STOPEXECUTION=1;
	%end;
	%else %if not &VERSION_CORRECT %then %do;
		%put WARNING: The macro variable VERSION has not been assigned correctly.;
		%put WARNING: Please assign VERSION a string of 1 to 4 characters.;
		%put WARNING: The macro variable VERSION was set to 00.;
		%let VERSION = 00;
		%let STOPEXECUTION=1;
	%end;
	%if not &QAOUTLIB_EXIST %then %do;
		%put WARNING: The macro variable QAOUTLIB has not been assigned.;
		%put WARNING: The macro variable QAOUTLIB was set to WORK. The DCO file will be saved in the WORK library.;
		%global QAOUTLIB;
		%let QAOUTLIB = WORK;
		%let STOPEXECUTION=1;
	%end;


*Checks to see if the DCO_file has been created 
	before setting the indataset to it; 
  %if %sysfunc(exist(&QAoutlib..DCO_file)) %then %do;
	data &QAoutlib..dco_file (label="Data Check Outcome (DCO) File");
		set &QAoutlib..DCO_file &indataset (in=newfile);
		check=lowcase(check);
		outdataset=lowcase(outdataset);
		if newfile then Era=&era.;
	run;
  %end;
  %else %do;
    data &QAoutlib..DCO_file  (label="Data Check Outcome (DCO) File");
		length Site $4. MemName $32. VarName $32.
			Check_description $256. Result $8. Reason $256. DateRan 8. Era 4. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
		set &indataset;
		check=lowcase(check);
		Era=&era.;
		outdataset=lowcase(outdataset);
         	label site = "Site" memname = "Table Name" varname = "Variable Name"
			check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
            dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed"
            OutDataSet = 'Data Set Containing Check Specifics' Era="Era of QA Program";
		format dateran datetime20.;
	run;
  %end;

%mend CESR_AppendDS;



******************************* CESR_HideLowCount  *********************************** 
******************************* CESR_HideLowCount  ***********************************

CESR_HideLowCount:

CESR_HideLowCount - Creates a second data set with counts less than &lowest_count replaced with 0 for the variables requested.
   All variables listed should be numeric.  If the CALC_PERCENT macro variable is given the value of YES at invocation then
   a total will be calculated for each variable listed excluding low counts and percent of total will be calculated for each
   value of the variables listed. 
 
This macro generates:
1. No print output report is generated.
2. No record is written to the DCO_file.
3. Creates 1 dataset named by the user (&outdataset) which contains all rows and variables from the 
       input data set (&indataset).  Variables that are listed by the user (&vars) are checked for values less than &lowest_count
       as established in a sites StdVars.sas file. 
       Where low counts are found, values are set to 0.
       If the parameter &calc_percent = YES then percents are calculated using values after the comparison to &lowest_count.  
       A new data set variable PERCENT_requested-variable-name is created for each variable listed in the
       &vars macro parameter.  The new variable name PERCENT_requested-variable-name will be truncated at 32 if needed.
4. A message is written to the log stating that values less than &lowest_value for the specified variables in the 
       specified data set have been changed to 0.  If a new caluculation for percents was requested by giving 
       CALC_PERCENT=YES at invocation a message stating this is also generated.

To invoke the macro you must:
    a) supply the name of a SAS table to check.  The table can be permanente with a two level name or temporary with a single
       level name.
    b) list variables contained in the SAS table to be checked.
       -  Variables should be listed with only a blank in between.
    c) supply the name of a SAS table where results will be written.  The table can be permanente with a two level name or 
       temporary with a single level name.
    d) calc_percent = NO by default.  Enter a YES value to alculate percents.

Example Calls:

%CESR_HideLowCount(indataset=age_gender_freqs, vars=f1_5 m1_5 f95_ m95_, outdataset=project1.age_gender_freqs_hidden
                      calc_percent=YES)

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011
Modified:   05/2012 added calc_percent parameter
            06/2012 limit name of new percent_ variables to 32

******************************* CESR_HideLowCount  ***********************************
******************************* CESR_HideLowCount  ***********************************;
%macro CESR_HideLowCount (indataset=, vars=, outdataset=, calc_percent=NO);

%let indataset=%upcase(&indataset);
%let vars=%upcase(&vars);
%let outdataset=%upcase(&outdataset);
%let calc_percent=%upcase(&calc_percent);

%local parser Vcounter found num_of_vars i;

*parse variables names;
%let parser=1;
%let Vcounter=1;
%if &vars ne %then %do;*if variables were entered when macro was invoked;
  %let found=%scan(&vars,&parser,%str( ));*find the first variable name;
  %do %while (&found ne);*as long as there is a value left to work with from the variables list stay in this loop;
    %if %index(_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,%substr(&found,1,1)) ne 0 %then %do; *a character or _ has been found;
      %local var&Vcounter;*add var1, var2, ... to local symbol table;
      %let %trim(var%left(&Vcounter))=&found; *the variable name will be stored in var1, var2,...;
      %let Vcounter=%eval(&Vcounter+1); *increment the variable counter;
    %end;*if do;
    %let parser=%eval(&parser+1); *point to the next piece of infomation in the list of variables;
    %let found=%scan(&vars,&parser,%str( )); *find the next piece of information when parsing variables and types;
  %end;*while;
  %let num_of_vars=%eval(&Vcounter-1);
%end;*if do;

*Creates the outdataset with values less than &lowest_count set to 0;
data &outdataset;
  set &indataset end=eof;
  %do i=1 %to &num_of_vars;
    if &&var&i <&lowest_count then &&var&i=0;
	total&i+&&var&i;
	if &i = &num_of_vars then output;
  %end;
  if eof then do;
  %do i=1 %to &num_of_vars;
	%local total&i;
    call symput("total&i",trim(put(total&i,13.)));
  %end;
  end;
%do i=1 %to &num_of_vars;
  drop total&i;
%end; 
run;
%if &calc_percent=YES %then %do;
  data &outdataset;
    set &outdataset;
    %do i=1 %to &num_of_vars;
      if not &&total&i in (0,.) then %substr(percent_&&var&i,1,%sysfunc(min(%length(percent_&&var&i),32)))=(&&var&i/&&total&i)*100;
	  else %substr(percent_&&var&i,1,%sysfunc(min(%length(percent_&&var&i),32)))=.;
	  label %substr(percent_&&var&i,1,%sysfunc(min(%length(percent_&&var&i),32)))="Percent of Total &&var&i Recalculated";
	%end;
  run;
%end;
 /* proc freq data=&outdataset order=data noprint;
    table &&var&i /missing out=percent_clean_&&var&i ;
    weight &&var&i/zero;
  run;
  data &outdataset;
    merge &outdataset percent_clean_&&var&i(keep=percent rename=(percent=percent_&&var&i));
	label percent_&&var&i="Percent of &&var&i Total Recalculated";
  run;*/
%put ==> COUNTS LESS THAN &Lowest_Count FOR VARIABLES &VARS IN THE &INDATASET DATA SET HAVE BEEN CHANGED TO ZERO IN THE &OUTDATASET DATA SET.;
%if &calc_percent = YES %then %do;
  %put ==> PERCENTS HAVE BEEN RECALCULATED AFTER COUNTS LESS THAN &Lowest_Count WERE CHANGED TO ZERO.;
%end;

%mend CESR_HideLowCount ;



******************************* CESR_TLC_DatasetExist ***********************************
******************************* CESR_TLC_DatasetExist ***********************************

CESR_TLC_DatasetExist:

Performs a data check that reports if the given table exists as a data set, view or not at all.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row 
       Columns in Report are: site, data set name, result and reason.

2. Appends 1 row explaining the result for the requested table to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..DataSetExists_&inname where DataSetExists_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, result, reason

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:
    a) supply the name of a SAS table to check.  The table can be permanente with two level name or temporary with single
       level name.
    b) optionally supply the name of the output dataset which the user can reference to find specifics about the result of the check.

Macro Call:
%CESR_TLC_DatasetExist(indataset= ,outdataset= )

Example Calls:
%CESR_TLC_DatasetExist(indatasets=VDW.PHARMACY)
%CESR_TLC_DatasetExist(indatasets=VDW.DEATH, outdataset=MyLibRef.death_table_existence_check)

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011
Modified:	11/22/13 - Gwyn Saylor
******************************* CESR_TLC_DatasetExist ***********************************
******************************* CESR_TLC_DatasetExist ***********************************;
%macro CESR_TLC_DatasetExist(indataset=, outdataset=);

%CESR_SymbolCheck;
%local inname c_area dsoutname;

*establish macro variable values;
%if &indataset= %then %let indataset=MACRO_VARIABLE_RESOLVES_TO_NULL; *added 11/22/13 (Hopefully this will never be the name of a real data set!);
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(DataSetExists_&inname                     x,1,32);
%else %let dsoutname=&outdataset;

%let QAoutlib=%upcase(&QAoutlib);
title5  "check: Existence of &indataset as Data Set, View or Not At All";

*Creates a dataset to build on;
data dco_feed;
  length Site $4. MemName $32. VarName $32.
         Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
        OutDataSet = 'Data Set Containing Check Specifics';
  memname="&inname";
  varname='NotApplicable';
  site="&_siteabbr";
  check_description="Existence of Table"; 
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&c_area._"||varname||'_'||"Existence"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
%if %sysfunc(exist(&indataset, data)) %then %do;
	*the indataset exists as a data set - fill the DCO_file variables accordingly;
  Reason = "The table &indataset exists as a data set.";
  Result="PASS";
%end;
%else %if %sysfunc(exist(&indataset, view)) %then %do;
	*the indataset exists as a view - fill the DCO_file variables accordingly;
  Reason = "The table &indataset exists as a view.";
  Result="PASS";
%end;
%else %do;
	*the indataset does NOT exist - fill the DCO_file variables accordingly;
  Reason = "The table &indataset does not exist as either a data set or view.";
  Result="FAIL";
%end;
  format dateran datetime.;
run;

%CESR_AppendDS(indataset=dco_feed);

*create output data set;
data &dsoutname (label="&content_area.: Dataset Existence");
  set dco_feed(keep=site memname result reason);
run;

*print results;
ods proclabel = "Dataset Existence";
proc print data=dco_feed noobs label;
  var site memname Result Reason;
run;

*clean up;
proc datasets nolist ;
  delete dco_feed;
run;
quit;

title5;
footnote4;

%mend CESR_TLC_DatasetExist;



******************************* CESR_TLC_Refresh ***********************************
******************************* CESR_TLC_Refresh ***********************************

CESR_TLC_Refresh:

Performs a data check that verifies the given dataset exists.

Creates 1 output report for the user to review:  

	1) Site, Table Name, Refresh Date

Appends 1 test result to the DCO_file.

Contact Information: Don Bachman	-- Don.Bachman@kpchr.org 
										(503)-335-6731 
Created by: 	Kari Walker
Date Created:  	1/17/2010
Modifications:  
 
******************************* CESR_TLC_Refresh ***********************************
******************************* CESR_TLC_Refresh ***********************************;
%macro CESR_TLC_Refresh(indataset=							
						, title =  /*Use Quotes! Leave blank for Default title*/
					  );

*MK;%if &title = %then title3  "Test of Current &indataset" 	;
%else title3 &Title	;  ;

*Creates a proc contents dataset;
proc contents data = &indataset out = refresh_check noprint;
run;

*This step fills in the DCO_variables;
data check_data (drop = modate mod) ;
 		length SITE $4. MEMNAME $50. Varname $32.
			CHECK $50. Reason $256.	Result $8. ;
	set refresh_check (obs = 1 keep = modate);
	MEMNAME = "&indataset"; 
	CHECK = "Table_Refresh"; 
	SITE="&_SiteAbbr";
	varname='ALL';
	Result = "     ";
	mod = put(datepart(modate),date9.);
 	Reason="Dataset Last Modified "||left(trim(mod));
run;

%CESR_AppendDS(indataset=check_data);

proc print data=check_data noobs label;
	var site memname Reason;
   	title3 "Verify that the &indataset is Current";
	label site = "Site" memname = "Table Name" Reason="Refresh Date"; 
run;
title3;

proc datasets nolist ;
   delete check_data refresh_check;
  run;
quit;

%mend CESR_TLC_Refresh;



****************************** CESR_VLC_CATEGORY **********************************
****************************** CESR_VLC_CATEGORY ********************************** 

CESR_VLC_Category:

This Macro produces expected and unexpected counts for the specified variable in the specified
table.  Percentages are calculated and compared to the fail and warn cutoff points that the user
supplies.  Then values less than &lowest_count are set to 0 and percentages are recalculated.
 
This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each value of the specified variable.  Each value is classified as expected or unexpected.   
       Columns in Report are: data set name, variable name, frequency and percent with counts
       less than &lowest_count hidden and percents adjusted accordingly.  Pass, warn, fail result is 
       determined BEFORE percents are adjusted for low counts.

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..Categorize_variable_&variable._in_&inname where Categorize_variable_&variable._in_&inname 
       is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are either: site memname variable note result if the requested variable doesn't exist or 
                                  : site memname var_desc count percent warn_at fail_at result.

Dependencies
Create a format that can be used to associate the string 'expected' with values that are expected 
and the string 'unexpected' with any other values.
Example;				
/*
proc format;
  value $disstat
	"AF", "AL", "AM", "AW", "EX", "HH", "HS", "HO", "IP", "NH", 
	"OT", "RS", "RH", "SH", "SN" ='expected'
	other= 'unexpected';
run;  
*/*

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

    a) supply the name of a SAS table to check.  The table can be permanente with two level name or temporary with single
       level name.
    b) supply the variable contained in the SAS table to be checked.
    c) supply the fail cutoff point.  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
    d) optionally supply the warn cutoff point.  For example, enter 1 if the warn point is >1%.  Enter =1 if the warn point is >=1%.
    e) optionally supply the name of the output dataset which the user can reference to find specifics about the result of the check.

Note that if neither fail nor warn cutoff points are set, the macro will produce a descriptive report without pass/warn/fail message.
Results will be written to the DCO file with result="N/A"

Macro Call:
%CESR_VLC_CATEGORY(indataset= , variable= , FailPercent= , ExpUnExpFormat= , missing= , WarnPercent= , outdataset= )

Example Call:;
/*
proc format;
  value $gender
	"M", "F", "O", "U" ='expected'
	other= 'unexpected';
run;  

%CESR_VLC_CATEGORY(indatasets=VDW.DEMOGRAPHIC, variable=gender, ExpUnExpFormat=$gender. ,missing=Y, warnpercent= 0, failpercent= =1, outdataset=MyLibRef.gender_check)
*/;*

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011

****************************** CESR_VLC_CATEGORY **********************************
****************************** CESR_VLC_CATEGORY **********************************;
%Macro CESR_VLC_CATEGORY(  indataset =
					, variable =
					, ExpUnExpFormat =	/*Whats the name of the Expected/Unexpected format described above  */
 	  				, missing = Y		/*If missings are to be excluded type N otherwise Y is assumed*/ 
					, failpercent =     /*Fail if more than 5%? Then type 5  */
					, warnpercent =		/*Warn if more than  or equal to 3% then type =3  */
					, outdataset =	/*libname.name of permanent dataset	*/
				  );

%CESR_SymbolCheck;
%local inname c_area dsoutname miss message_P message_F message_W selected_variable check_cat result highpercent nlimits title6;

*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Categorize_variable_&variable._in_&inname                         x,1,32); 
%else %let dsoutname=&outdataset;

%IF &missing=N %then %let miss=;
%else %LET miss=MISSING ;

%let variable=%upcase(&variable);

*assess if warn and/or fail cutoff are set;
	%let nlimits = 0;
	%if &failpercent ne %then %do;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&failpercent;
	%end;
	%if &warnpercent ne %then %do;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&warnpercent;
	%end;



title5 "Test for Unexpected Values of &variable in &indataset" ;

proc format	;
  value hide 
   0 = "    Hidden";
run;

*Checks if the variable exists;
proc contents data=&indataset out=exist_check(keep=libname memname name)noprint;
run;
%let selected_variable=0;*variable does not exist in data set;
data one_or_none;
  set exist_check;
  if upcase(name)="&variable";
  call symput("selected_variable","1");*variable does exist in data set;
run;
%if &selected_variable=0 %then %do;
  data dco_feed;
    length Site $4. MemName $32. VarName $32.
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
    label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics';
    memname = "&inname";  
    varname = "&variable";
    site="&_siteabbr";
    check_description="Expected and Unexpected Rates"; 
    content_area="&content_area"; 
    dateran=datetime();
    version="&version";
    check=compress("&c_area._"||varname||'_'||"category"||'_'||"Descriptive",' ');
    outdataset="&dsoutname";
    Reason = "Requested variable &variable does not exist in data set";
		Result=
		%if &failpercent ne %then %do;
		    "FAIL";
		%end; 
		%else %if &warnpercent ne %then %do;
			"WARN";
		%end;
		%else %do;
			"N/A";
		%end;    
	format dateran datetime.;
  run;

  %CESR_AppendDS(indataset=dco_feed);

    data &dsoutname;
    Site="&_siteabbr";
    memname="&inname";
    Variable="&variable";
	Note="Requested variable, &variable, does not exist in the data set &inname..";
	Result=
		%if &failpercent ne %then %do;
		    "FAIL";
		%end; 
		%else %if &warnpercent ne %then %do;
			"WARN";
		%end;
		%else %do;
			"N/A";
		%end;    
    call symput ('title6', 
		%if &nlimits. > 0 %then %do; 
			trim(result) 
		%end;
		%else %do; 
			'Attention' 
		%end;
			||': '||trim(note));
			label site = "Site" memname = "Table Name" 
          variable="Variable Name"
          note="Message" Result="Result"
	;run;

proc print data=&dsoutname noobs label;
    var site memname variable note result;
    title6 "&title6.";
  run;

  proc datasets nolist;
   delete dco_feed type_check one_or_none;
  run;
  quit;
%end;
%else %do;
*get true frequencies of all values of variable;
proc summary data=&indataset(keep=&variable) NWAY;
  class &variable/&miss;
  output out = all_counts;
run;

*clean up low counts and compute percentages - for outdataset; 
data all_counts_clean;
	set all_counts;
	if _freq_ < &lowest_count. then count=0;
	else count=_freq_;
	drop _type_ _freq_;
run;
proc freq data=all_counts_clean noprint;
	tables &variable / &miss out=all_counts_clean;
	weight count / zero;
run;



/*if exploratory: compute unexpected percentage from sum of low-count-suppressed % of all unexpected values and create reason variable*/
%if &nlimits = 0 %then %do;
	%let result=N/A;
	data _null_;
		set all_counts_clean end=eof;
		retain percentU 0 suppressed 0;
		if upcase(put(&variable,&ExpUnExpFormat. ))=:'UNEXPECT' then do;
			percentU+percent;
			if count=0 then suppressed=1;
		end;
		if eof then do;
			if suppressed then call symput('reason',"Unexpected values of &variable occur at rate of >"||compress(put(percentU,8.4))||"%.");
			else call symput('reason',"Unexpected values of &variable occur at rate of "||compress(put(percentU,8.4))||"%.");
		end;
	run;
	%let title6=&reason;
%end;
/*if warn and/or fail limits set, compute unexpected percentage, result and reason*/
%else %do;
*get true frequency and percentage of unexpected values;
proc freq data=all_counts noprint;
	tables &variable / missing out=all_counts ;
	weight _freq_ ;
    format &variable &ExpUnExpFormat. ;
run;
	%let result=PASS;
	%let reason=Unexpected values for the variable &variable occur at an acceptable rate (not >&highpercent.%).;
	data _null_;
		set all_counts;
		if upcase(put(&variable.,&ExpUnExpFormat.))=:'UNEXPECTED' then do;
			%if &failpercent. ne %then %do;
				if percent > &failpercent. then do;
					call symput('result',"FAIL");
					call symput('reason',"Unexpected values of &variable occur at too high a rate (>&failpercent.%).");
				end;
				%if &warnpercent. ne %then %do;
					else if percent > &warnpercent. then do;
						call symput('result',"WARN");
						call symput('reason',"Unexpected values of &variable occur at a concerning rate (>&warnpercent.%, but not >&failpercent.%).");
					end;
				%end;
			%end;
			%else %if &warnpercent. ne %then %do;
				if percent > &warnpercent. then do;
					call symput('result',"WARN");
					call symput('reason',"Unexpected values of &variable occur at a concerning rate (>&warnpercent.%).");
				end;
			%end;
		end;
	run;
	%let title6=&result.: &reason.;
%end;

data dco_feed;
  length Site $4. MemName $32. VarName $32.
  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
        OutDataSet = 'Data Set Containing Check Specifics' ;
  memname = "&inname";
  varname = "&variable";
  site="&_siteabbr";
  check_description="Expected and Unexpected Rates"; 
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&c_area._"||varname||'_'||"category"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
  format dateran datetime.;
  Reason = "&REASON";
  result = "&result";
run;

*append record to DCO_file; 
%CESR_AppendDS(indataset=dco_feed);

*create outdataset;
data all_counts_clean;
	set all_counts_clean;
    var_desc=trim(left(put(&variable,&ExpUnExpFormat. ))) || ' (' || trim(left(&variable)) || ')'; 
	if upcase(var_desc)=:'UNEXPECT' then sortorder=1;
	else if upcase(var_desc)=:'EXPECT' then sortorder=3;
	else sortorder=2;
run;
proc sort data=all_counts_clean out=all_counts_clean (drop=sortorder &variable);
	by sortorder &variable;
run;

data  &dsoutname (keep = site memname var_desc count percent warn_at fail_at result); 
  Site="&_siteabbr";
  memname="&inname";
  set all_counts_clean;
    if _n_=1 then do;
      if "&warnpercent"="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&warnpercent";
      if "&failpercent"="" then fail_at="No Fail Limit Set"; else fail_at=">"||"&failpercent";
      Result="&Result";
    end;
  label site = "Site" memname = "Table Name" 
        var_desc="Value of Variable %upcase(&variable) Is Expected or Unexpected"
        count="Count - Counts Less Than &lowest_count are Hidden"
        percent="Percents are Recalculated If Counts are Hidden"
        warn_at="Warning Issued If Percent of All Unexpected Values Combined is"
        fail_at="Fail Issued If Percent of All Unexpected Values Combined is"
        Result="Result for the Expected/Unexpected Check Described by This Report";
  format percent 5.1;
  run;




  proc print data=&dsoutname noobs label;
    var site memname var_desc count percent warn_at fail_at result;
	format count hide.;
    title6 "&title6.";
	%if &missing=N %then %do;
	title7 "Missing values are excluded from analysis.";
	%end;
	%else %do;
	title7 "Missing values are included in analysis.";
	%end;
    footnote4 "Hidden indicates a count less than &lowest_count..";
    footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
    footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
  run;

  data &dsoutname;
    set &dsoutname;
	format count;
  run;

*clean up;
proc datasets nolist;
  delete all_counts all_counts_clean  
		 one_or_none dco_feed exist_check
 ;run;
quit;

%end;

footnote4;
title5;

%Mend CESR_VLC_CATEGORY;


****************************** CESR_VLC_Frequency **********************************
****************************** CESR_VLC_Frequency **********************************

CESR_VLC_Frequency:

Modified by Don Bachman on 9/13/2012.  Remove a permanent format.

This macro performs a data check that verifies a single variable value is within 
a certain percent range.  

Outputs 
Creates 2 output tables for the User to review:  
	1) Results (Pass/Warning/Fail) Reason (P/W/F Message)
	2) &Variable, Frequency, Percent

Creates 1 dataset:  
Site, &Variable, Count, Percent 	 
  		 
Appends 1 test result to the DCO_file.


Contact Information: Don Bachman	-- Don.Bachman@kpchr.org 
										(503)-335-6731 
Created by: 	Kari Walker
Date Created:  	11/10/2010
Modifications:  2/9/2011 Output weighted frequency added title parameter
				2/3/2011 Updated to hidden frequency format
				1/6/2011 Dons *M* for provider program
				Karis *MK* current date 

****************************** CESR_VLC_Frequency **********************************
****************************** CESR_VLC_Frequency **********************************;
%Macro CESR_VLC_Frequency(indataset=
					, variable=
					, Failvarvalue=     /*What entry are we testing?*/
					, VarFormat=	   /*Whats the name of the Expected/Unexpected format described above*/
 	  				, missing = 	   /*If missings are to be counted type Y else enter N */ 
					, failpercent=  /*Fail if more than 5%? Then type 5.*/
					, warnpercent=  /*Warn if more than 1%? Then type 1.*/

					, message_P	= "An acceptable amount of the fail values occur"	 
					, message_F =  "The fail values occur too often"
					, message_W = "The fail values occur"	
					, outdataset =		/*libname.name of permanent dataset  */
					, title =  /*Use Quotes! Leave blank for Default title*/
					  );

*MK;%if &title = %then title3  Test of Counts of &Failvarvalue in &variable 	;
%else title3 &Title	;  ;

%IF &MISSING = Y %then %let MISS = MISSING;
%else %LET MISS = ;

proc format	;
  value hide 
   0 = "    Hidden";
run;

*Proc Means sets up the frequency;
proc means data= &indataset (keep = &variable)  noprint  ;
  class &variable/&MISS ;
  format &variable &VarFormat; 
  output out = var_counts;
run;

*Cleans up the counts, introduces site, defines percent;
data var_counts_clean (drop = _type_  grandtotal);
  length SITE $4;
  SITE="&_SiteAbbr.";
  set var_counts (rename = (_freq_ = count));
  by _type_;
  if  _type_ = 0 and first._type_ = 1 then grandtotal = count;
  retain grandtotal;
  if  _type_ = 0   then delete;
    call symput('CHECK_FREQ','P');
  	call symput('Result','PASS');
  percent =  (count/grandtotal)*100;
run;

*Checks the FailVarVal isnt between the fail and warn percent
	defines the result variable
	sets counts < 6 to 0;
data vvar_counts_clean;
	set var_counts_clean;
  if upcase(trim(left(&variable))) = upcase(trim(left(&Failvarvalue))) then do;
		if percent> &failpercent then do; 
	  		call symput('CHECK_FREQ','F');
  	  		call symput('Result','FAIL');
  		end;
  		%if &warnpercent ne  %then %do;
  	  		if upcase(&variable) = upcase(&Failvarvalue) and &warnpercent < percent <= &failpercent then do;
	 	  		call symput('CHECK_FREQ','W');
  	  	  		call symput('Result','WARN'); 
	  		END;
  		%end;
  end;
  if count < 6 then count = 0;

  TEST_F = &message_F;
  TEST_P = &message_P;
  %if &warnpercent ne  %then TEST_W =  &message_W; ;
*MK*  TEST_H =  &message_H; 
run;

*Sets up the variables for the DCO_File;
data check_data  (drop = TEST_&CHECK_FREQ);
  length Site $4. MemName $32. VarName $32.
  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
	set vvar_counts_clean   (OBS = 1 keep  =  TEST_&CHECK_FREQ SITE);
	memname = "&indataset";
	varname = "&variable";
	Reason = TEST_&CHECK_FREQ;

	result = "&Result";
	label result = 'Results' Reason = 'Reason';
        content_area="&content_area"; 
        dateran=datetime();
        version="&version"; 
        site="&_siteabbr";
        check_description="Check Frequencies for Expected Percentages"; 

        check=compress(content_area||"_"||varname||'_'||"frequency"||'_'||"Descriptive",' ');
        outdataset="&outdataset";
        format dateran datetime.;


run;

proc print data=  check_data  label noobs;
  VAR result REASON;
run;

%CESR_AppendDS(indataset=check_data);

*MK* This uses Freq to weight the %s the format hides <6;
footnote2 "Hidden indicates a count less than 6.";
proc freq data= vvar_counts_clean noprint;
  tables &variable/&miss out = hide_freq;
  weight count/zero;
  format  count hide.;
 run;

*This is the final print with <6 Hidden; 
proc print data = hide_freq noobs label;
label count ="Frequency" Percent = "Percent";
run;
footnote2;


data &outdataset ;
*MK*;  length SITE $4;
 *MK*;  SITE="&_SiteAbbr.";
*MK*;	set hide_freq;
        where count>=6;
        format count;
run;

 
proc datasets nolist;
   delete var_counts var_counts_clean check_data  hide_freq;
  run;
quit;

title3;

%Mend CESR_VLC_FREQUENCY;






****************************** CESR_VLC_IncludePHI ******************************
****************************** CESR_VLC_IncludePHI ******************************

CESR_VLC_IncludePHI:

Performs a data check to test if one phi variable is present in another 
	variables character string.  

Creates 2 output tables for the User to review:  
	1) Results (Pass/Warning/Fail) Reason (P/W/F Message)
	2) &checkvar Includes &PHIvar, Frequency, Percent 

Creates 1 dataset:  
	Site, Include_PHI, Count, Percent 		 
 
Appends 1 test result to the DCO_file.

Contact Information: Don Bachman	-- Don.Bachman@kpchr.org 
										(503)-335-6731 
Created by: 	Kari Walker
Date Created:  	11/10/2010
Modifications:  2/9/2011  Outdataset set to weighted freq added title parameter
				1/28/2011 Karis *MK* updated with the hidden format. 

****************************** CESR_VLC_IncludePHI ******************************
****************************** CESR_VLC_IncludePHI ******************************;
%Macro CESR_VLC_IncludePHI(indataset =
					, PHIvar =
				    , checkvar = 
					, failpercent =     /*Fail if more than 1%? Then type 1 Fail if more than or equal to 1% type =1*/
					, warnpercent =
 					, message_P	= "The &Checkvar variable contains &PHIvar an acceptable amount of the time."	/*Default*/
					, message_F = "The &Checkvar variable contains &PHIvar too often."	/*Default*/  
					, message_W	= "The &Checkvar variable contains &PHIvar."	/*Default*/   
					, outdataset =		/*libname.name of permanent dataset  */
					, title =  /*Use Quotes! Leave blank for Default title*/
					  );

*MK;%if &title = %then title3  "Test of &PHIvar in &checkvar" 	;
%else title3 &Title	;  ;

*MK*;proc format	;
  value hide 
   0 = "    Hidden";
run;

data phi_check1;
   set &indataset(keep=&PHIvar &checkvar);
   if index(&checkvar,&PHIvar)>0 then include_phi='Yes';
   else include_phi='No ';
run;

proc means data = phi_check1  noprint  ;
   class include_phi/missing; 
   output out = phi_check2   ;
run;

data phi_check_clean  (drop = _type_ grandtotal);
  length SITE $4;
  SITE="&_SiteAbbr.";
  set phi_check2 (rename = (  _freq_ = count));
  by _type_;
  if  _type_ = 0 and first._type_ = 1 then grandtotal = count;
  retain grandtotal;
  if  _type_ = 0   then delete;

  call symput('CHECK_PHI','P');
  call symput('Result','PASS');
  percent = (count/grandtotal)*100;
  label include_phi = "&Checkvar Includes &PHIvar";
run;

data phi_check3;
	set phi_check_clean;
  
  if include_phi = 'Yes' and percent > &failpercent then do;
   		call symput('CHECK_PHI','F');
		call symput('Result','FAIL');
  end;

  %if &warnpercent ne  %then %do;
  else do;
		if include_phi = 'Yes' and &warnpercent < percent <= &failpercent then do;
			call symput('CHECK_PHI','W');
			call symput('Result','WARN');
  		end;
  end;
  %end;  

  if count < 6 then count = 0;

  	TEST_F = &message_F;
	TEST_P = &message_P;
    %if &warnpercent ne  %then TEST_W =  &message_W; ;
run; 

data check_data  (drop = TEST_&CHECK_PHI Check_long x);
*MK* LENGTH TEST $8;
*MK*;length SITE $4. MEMNAME $50. varname $32. 
			CHECK $50. result $8. 	Reason $256. ;
	set phi_check3  (OBS = 1 keep  =  TEST_&CHECK_PHI SITE);
	memname = "&indataset";
	varname = "&checkvar";
	Reason = TEST_&CHECK_PHI;
*MK*;Check_long = "&outdataset"; 
*MK*;x=index(Check_long,'.');
*MK*;check = substr(Check_long,(x+1));
*MK*;	Result = "&Result";
*MK*;	label Result = 'Results' Reason = 'Reason';
run;

proc print data=  check_data  label noobs;
  VAR Result REASON;
run;

%CESR_AppendDS(indataset=check_data);

footnote2 "Hidden indicates a count less than 6.";
proc freq data= phi_check3 noprint;
  tables include_phi/missing  out = hide_freq;
  weight count/zero;
  format  count hide.;
run;
 
proc print data = hide_freq noobs label;
label count= "Frequency" Percent = "Percent";
run;
footnote2;

DATA &outdataset;
  length SITE $4;
  SITE="&_SiteAbbr.";
	set  hide_freq   ;
RUN;

proc datasets nolist;
   delete hide_freq  phi_check1 phi_check2 phi_check3  check_data phi_check_clean
   ;
  run;
quit;

%MEND CESR_VLC_INCLUDEPHI; 



****************************** CESR_VLC_LENGTH_MTSV ***************************
****************************** CESR_VLC_LENGTH_MTSV ***************************

CESR_VLC_LENGTH_MTSV:

This macro performs a data check comparing the specified character variable's actual length 
to the requested check length across multiple data sets.

Numerics are not checked. 

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each data set checked
       Columns in Report are: site, data set name, variable name, length, requested check, result and reason.

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset named by the user or called &QAoutlib..length_of_var_&variable._mtsv 
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &variable receives its value from the user as a parameter value when this macro is invoked.
       The resulting table name will be truncated at 32 characters.
       Columns in table are: site, data set name, variable name, length, requested check, result, reason and type.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

       REMEMBER - data set names MUST be separated with a blank
    a) supply the names of SAS tables to check.  The tables can be permanente with two level name or temporary with single
       level name.
    b) supply the variable contained in the SAS tables to be checked.
    c) supply a qualified length to compare to the variable's actual length.  Three example follow =7, >4, <=5
    d) optionally supply the output data set name.

Example Calls:

%CESR_VLC_LENGTH_MTSV(indatasets=VDW.PHARMACY VDW.CENSUS VDW.VITALS, variable=mrn, length= <=12, outdataset=Mylib.MRN_check)
%CESR_VLC_LENGTH_MTSV(indatasets=VDW.ENC VDW.DX VDW.PX VDW.VITALS, variable=enctype, length= =2)

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  01/2012
****************************** CESR_VLC_LENGTH_MTSV ***************************
****************************** CESR_VLC_LENGTH_MTSV ***************************;

%Macro CESR_VLC_LENGTH_MTSV(indatasets=,variable=,length=, outdataset=);

%CESR_SymbolCheck;
%local found dscounter ds parser num_of_ds match_list no_match_list var_not_in_ds_list result reason i num_list qualifier_or_not
       c_area;

*establish macro variable values;
%let indatasets=%upcase(&indatasets);
  %* %if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
  %* %else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
%let variable=%upcase(&variable);
%let QAoutlib=%upcase(&QAoutlib);
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(length_of_var_&variable._mtsv                  x,1,32);
%else %let dsoutname=&outdataset;

title5 "Check: Length of Character Variable &variable in One or More Tables (Numerics are not checked)";

*parse list data set names separated with blanks;
%let parser=1;
%let DScounter=0;
%if &indatasets ne %then %do;*if data set names were entered when macro was invoked;
  %let found=%scan(&indatasets,&parser,%str( ));*find the first data set name;
  %do %while (&found ne);*as long as there is a value left to work with from the data set list stay in this loop;
    %let DScounter=%eval(&DScounter+1); *increment the data set counter;
    %local indataset&DScounter; *add indataset1, indataset2, ... to local symbol table;
    %let indataset&DScounter=&found; *the data set name will be stored in var1, var2,...;
    %let parser=%eval(&parser+1);
    %let found=%scan(&indatasets,&parser,%str( ));*find the next data set name;
  %end;
  %let num_of_ds=&DScounter;
%end;*if;
%do ds = 1 %TO &num_of_ds;
	proc contents data=&&indataset&ds out=inds_length_&ds(keep=memname name length type) noprint;
   	run;	
%end;

data combined_length(rename=(name=varname));  
  set 
    %DO ds = 1 %TO &num_of_ds;
	  inds_length_&ds(where=(upcase(name)="&variable"))  
	%END; ;
	length Site $4 Requested_check $ 10;
    Site="&_SiteAbbr.";
	Requested_Check="&length";
run;
proc sort data=combined_length;
   by memname;
  run;
data combined_dsname;
  set 
    %DO ds = 1 %TO &num_of_ds;
      inds_length_&ds(keep=memname)  
    %END; ;
	by memname;
	if first.memname;
run;
data combined;
  merge combined_length combined_dsname;
  by memname;
  if type=1 then length=.N;
run; 
%let match_list=;
%let no_match_list=;
%let var_not_in_ds_list=;
%let num_list=;
%let qualifier_or_not=%substr(&length,1,1);
%if %index(=<>,&qualifier_or_not) %then ;%else %let length==&length;
data _null_;
  set combined;
  if length=. then do;
    if symget("var_not_in_ds_list")='' then call symput("var_not_in_ds_list",trim(memname));*if first data set in this category;
    else call symput("var_not_in_ds_list",left(trim(symget("var_not_in_ds_list"))||', '||trim(memname)));
  end;
  else if type=1 then do;*numerics are not checked;
    if symget("num_list")='' then call symput("num_list",trim(memname));*if first data set in this category;
    else call symput("num_list",left(trim(symget("num_list"))||', '||trim(memname)));
  end;
  else if length&length then do;
    if symget("match_list")='' then call symput("match_list",trim(memname));*if first data set in this category;
    else call symput("match_list",left(trim(symget("match_list"))||', '||trim(memname)));
  end;
  else do;*requested_check ne length;
    if symget ("no_match_list")='' then call symput("no_match_list",trim(memname));*if first data set in this category;
    else call symput("no_match_list",left(trim(symget("no_match_list"))||', '||trim(memname)));
  end;
run;
%if &no_match_list&var_not_in_ds_list&num_list= %then %do;
  %let result=PASS;
  %let reason=All data sets (&match_list) correctly have the character variable &variable with length &length..;
%end;
%else %do;
  %let result=FAIL;
  %if &no_match_list= %then %let no_match_list=No data sets;
  %if &var_not_in_ds_list= %then %let var_not_in_ds_list=No data sets;
  %if &num_list= %then %let num_list=No data sets;
  %if &match_list= %then %let reason=No listed data set had the character variable &variable with length &length..  
&no_match_list had character variable &variable with length not &length..  
&var_not_in_ds_list did not have &variable at all.  
&num_list had &variable as numeric. Numerics are not checked.; 
  %else %let reason=Only some listed data sets had the character variable &variable with length &length..  
&no_match_list had character variable &variable with length not &length..  
&var_not_in_ds_list did not have &variable at all.  
&match_list correctly had &variable with length &length.. 
&num_list had &variable as numeric. Numerics are not checked.; 
%end;
data check_data;
  length Site $4. MemName $32. VarName $32.
		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41 Type 8 Length 8 
         Requested_Check $ 10;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
    OutDataSet = 'Data Set Containing Check Specifics' Requested_Check = "Requested Check" ;
  site="&_siteabbr";
  memname="&indatasets";
  varname="&variable";
  check_description="Length of Specified Variable in Multiple Data Sets";
  result="&result";
  reason="&reason";
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&c_area._"||varname||'_'||"lengthMT"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
  format dateran datetime.;
run;

data dco_feed;
  set check_data(drop=type length requested_check);

%CESR_AppendDS(indataset=dco_feed);

proc format;
  value var_length .='Not in Data Set'
                  .N='Numeric: Length not checked';
  value var_type 1='Numeric'
                 2='Character';
run;
data &dsoutname (label="Variable Length");
  length Site $ 4 MemName  $ 32 VarName $ 32 Length 8 Requested_Check $ 10 result $ 8 reason $ 256;
  set combined;
  varname="&variable";
  site="&_siteabbr";
  requested_check="&length";
  result="&result";
  reason="&reason";
run;
proc print data=&dsoutname;
  var site memname varname length requested_check result reason;
  format length var_length.;
  label memname = 'Table Name' varname = 'Variable Name' length = 'Variable Length' requested_check='Requested Check'
    Result = "Result" Reason = "Reason" ;
run;
  
*cleanup; 
proc datasets nolist;
  delete check_data combined combined_dsname combined_length dco_feed %do i=1 %to &num_of_ds; inds_length_&i %end; ;
quit;

title5;
footnote4;

%mend CESR_VLC_Length_MTSV;


****************************** CESR_VLC_Length_STMV **********************************
****************************** CESR_VLC_Length_STMV **********************************

CESR_VLC_Length_STMV:

This macro performs a data check verifying that the length of one or more character variables
    in a single data set satisfy the lengths specified for the variables.  The length of numeric
    variables are not checked.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each character variable check requested with a pass or fail result and a reason explaining
            the result value
         -  one row for any requested numeric variable check with a blank result and a reason explaining that
            numerics aren't being checked
       Columns in Report are: data set name, variable name, result, reason, 
            type, actual length, value to compare length against.

2. Appends check results for requested variables (whether character or numeric) to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAed, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..Lengths_of_Vars_in_&inname where Lengths_of_Vars_in_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, variable name, result, reason, type, length, requested check.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

       REMEMBER - variable names and length MUST be separated with a blank
    a) supply the name of a SAS table to check.  The table can be permanente with a two level name or temporary with a single
       level name.
    b) list variables contained in the SAS table to be checked along with length values to compare with the actual lengths.
       -  Each variable can be followed with a length value with which to compare the actual length.
       -  If several variables are to be compared to the same length the variables can be listed and then the length can be listed once.
    c) The qualifiers <,<=,>=,> or = can be placed directly infront of the length values in the macro invocation.  No space should appear
       between the qualifier and the number.  The qualifiers have to appear exactly as listed here.  For instance no imbedded space
       between the less than and the equal sign.  Also, the order of the greater than symbol and the equal sign cannot be switched.

Example Calls:

%CESR_VLC_Length_STMV(indataset=VDW.DEMO, vars_and_lengths=gender =1 race1 race2 race3 race4 race5 =2 hispanic =1)
  another way to make the same call:
%CESR_VLC_Length_STMV(indataset=VDW.DEMO, vars_and_lengths=gender =1 race1 =2 race2 =2 race3 =2 race4 =2 race5 =2 hispanic =1)

%CESR_VLC_Length_STMV(indataset=VDW.DEMO, vars_and_lengths=MRN <13 gender =1 race1 race2 race3 race4 race5 =2 hispanic =1,outdataset=MyLibRef.Demo_length_checks)


Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011

****************************** CESR_VLC_Length_STMV **********************************
****************************** CESR_VLC_Length_STMV **********************************;

%macro CESR_VLC_Length_STMV(indataset=,vars_and_lengths=,outdataset=);

%CESR_SymbolCheck;
%local FOUND MAX_LEN I J PASSFAILSASCODE VCOUNTER NUM_OF_VARS PARSER DSOUTNAME INNAME c_area;

*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
%let QAoutlib=%upcase(&QAoutlib);
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Length_of_Vars_in_&inname                   x,1,32);
%else %let dsoutname=&outdataset;

title5 "Check: Lengths of One or More Character Variables in Table &indataset (Numerics are not checked)";

*parse variables and lengths;
%let parser=1;
%let Vcounter=1;
%if &vars_and_lengths ne %then %do;*if variables and lengths were entered when macro was invoked;
  %let found=%scan(&vars_and_lengths,&parser,%str( ));*find the first variable name;
  %do %while (&found ne);*as long as there is a value left to work with from the variables and length list stay in this loop;
    %if %index(_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,%substr(&found,1,1)) ne 0 %then %do; *a character or _ has been found;
      %local var&Vcounter len&Vcounter;*add var1, len1, var2, len2,... to local symbol table;
      %let %trim(var%left(&Vcounter))=&found; *the variable name will be stored in var1, var2,...;
      %let Vcounter=%eval(&Vcounter+1); *increment the variable counter;
    %end;
    %else %if %index(=<>1234567890,%substr(&found,1,1)) ne 0 %then %do;*a length has been found;
      %let %trim(len%left%eval(&Vcounter-1))=&found;*the variable name will be stored in len1, len2...;
    %end;
    %let parser=%eval(&parser+1); *point to the next piece of infomation in the list of variables and lengths;
    %let found=%scan(&vars_and_lengths,&parser,%str( )); *find the next piece of information when parsing variables and lengths;
  %end;*while;
  %let num_of_vars=%eval(&Vcounter-1);
%end;*if;
%if &num_of_vars gt 1 %then %do; *fill in lengths for earlier variables listed in a series;
  %do i=&num_of_vars %to 1 %by -1;
      %if %length(&&len&i)=0 %then %do;
      %let j=%eval(&i+1);
      %let len&i=&&len&j;
    %end;
  %end;
%end;*if;
data requested_variables;
  %let max_len=%length(&len1);*find number of storage bytes needed for the length information entered;
  %if &num_of_vars > 1 %then %do;
    %do i=2 %to &num_of_vars;
      %if &max_len < %length(&&len&i) %then %do;
        %let max_len=%length(&&len&i);
      %end;
    %end;
  %end;
  %if &max_len=1 %then %let max_len=2;
  length name $ 32 requested_check $ &max_len;
  %do i=1 %to &num_of_vars;
    name=upcase("&&var&i");
    requested_check="&&len&i";
    output;
  %end;
run;
proc sort data=requested_variables;
  by name;
run;
proc contents data=&indataset out=contents_length(keep=memname name length type) noprint;
run;
data contents_length;
  set contents_length;
  name=upcase(name);
run;
proc sort data=contents_length;
  by name;
run;
data variables_list(rename=(name=varname));
  merge contents_length(in=in_data_set) requested_variables(in=requested);
  by name;
  if requested; *only keep rows of information for requested variables;
  if in_data_set then in_ds=1;
run;
*this macro variables is referred to several times below;
%let PassFailSAScode=%str(
      do;
        result='PASS';
        reason=trim(left(put(length,12.)))||trim(left(requested_check))||' is true.';
        sortorder=2;
      end;
      else do;
        result='FAIL';
        reason=trim(left(put(length,12.)))||trim(left(requested_check))||' is false.';
        sortorder=1;
      end;
    end);*end PassFailSAScode macro variable definition;
data variables_list2(drop = rc1 rc2 in_ds);
  length Site $4. MemName $32. VarName $32.
		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41 Type 8 Length 8 Requested_Check $ &max_len;
  set variables_list;
  if in_ds ne 1 then do;
    result='FAIL';
    reason='A check was requested for this variable, but the variable does not exist in the data set.';
    sortorder=3;
    memname="&inname";
  end;
  else if type=1 then do;
    result='';
    reason='The length of numeric variables are not checked even if requested.';
	length=.N;
    sortorder=4;
  end;
  else if type=2 then do;
    rc1=substr(requested_check,1,1);
    rc2=substr(requested_check,1,2);
    if rc1 ne '<' and  rc1 ne '>' then do;
      if length=input(compress(requested_check,'='),4.) then do;
        result='PASS';
        reason=trim(left(put(length,12.)))||'='||trim(left(compress(requested_check,'=')))||' is true.';*since = is optional must hardcode ||=;
        sortorder=2;
      end;
      else do;
        result='FAIL';
        reason=trim(left(put(length,12.)))||'='||trim(left(compress(requested_check,'=')))||' is false.';*since = is optional must hardcode ||=;
        sortorder=1;
      end;
    end;
    else if rc2 = '<=' then do;
      if length <= input(substr(requested_check,3),10.) then &PassFailSAScode;
    else if rc1 = '<' then do;
      if length < input(substr(requested_check,2),10.) then &PassFailSAScode;
    else if rc2 = '>=' then do;
      if length >= input(substr(requested_check,3),10.) then &PassFailSAScode;
    else if rc1 = '>' then do;
      if length > input(substr(requested_check,2),10.) then &PassFailSAScode;
  end;*if type=2;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
    OutDataSet = 'Data Set Containing Check Specifics' Requested_Check = "Requested Check" ;
  site="&_siteabbr";
  check_description="Length of Variables in Single Data Set"; 
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&c_area._"||varname||'_'||"length"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
  format dateran datetime.;
run;
proc sort data=variables_list2/*(drop=type)*/ out=&dsoutname;
  by sortorder;
run;
proc format;
  value var_length .='Not in Data Set'
                  .N='Numeric not allowed';
  value var_type 1='Numeric'
                 2='Character';
run;
ods proclabel="Variable Lengths in &inname.";
proc print data=&dsoutname (drop=sortorder site check content_area dateran 
                             version check_description outdataset) label;*at this point dsoutname has ALL DCO_file vars plus type, length and requested_check;
  format type var_type. length var_length.;
run;

data dco_feed;
  set &dsoutname(drop=sortorder type length requested_check);
run;

data &dsoutname  (label="Variable Length");
  set &dsoutname(drop=sortorder check content_area dateran version check_description outdataset);
run;

%CESR_AppendDS(indataset=dco_feed);

*cleanup;
proc datasets nolist ;
   delete  contents_length dco_feed requested_variables variables_list variables_list2;
quit; 

title5;
footnote4;

%Mend CESR_VLC_Length_STMV;




****************************** CESR_VLC_Missing **********************************
****************************** CESR_VLC_Missing **********************************

CESR_VLC_Missing:

This Macro produces missing and non-missing counts for the specified variable in the specified
table.  Percentages are calculated and compared to the fail and warn cutoff points that the user
supplies.  Then values less than &lowest_count are set to 0 and percentages are recalculated.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for missing and one row for non-missing counts and percentages. 
       Columns in Report are: data set name, variable name, frequency and percent with counts
       less than &lowest_count hidden and percents adjusted accordingly.

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..%substr(Missing_variable_&variable._in_&inname where Missing_variable_&variable._in_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are either: site memname variable note result if the requested variable doesn't exist or 
                                  : site memname variable status count percent warn_at fail_at result.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

    a) supply the name of a SAS table to check.  The table can be permanente with two level name or temporary with single
       level name.
    b) supply the variable contained in the SAS table to be checked.
    c) optionally, supply the fail cutoff point.  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
    d) optionally, supply the warn cutoff point.  For example, enter 1 if the warn point is >1%.  Enter =1 if the warn point is >=1%.
    e) optionally, supply the name of the output dataset which the user can reference to find specifics about the result of the check.

Note that if neither fail nor warn cutoff points are set, the macro will produce a descriptive report without pass/warn/fail message.
Results will be written to the DCO file with result="N/A"

Macro Call:
%CESR_VLC_MISSING(indataset= , variable= , FailPercent= , WarnPercent= , outdataset= )

Example Calls:
%CESR_VLC_MISSING(indataset=vdw.pharmacy , variable=rxsup , FailPercent=5 , WarnPercent=1 , outdataset=mylib.rx_rxsup_miss )
%CESR_VLC_MISSING(indataset=vdw.pharmacy , variable=rxamt ,  outdataset=mylib.rx_rxamt_miss )
%CESR_VLC_MISSING(indataset=vdw.dx , variable=adate , failpercent=0,  outdataset=mylib.dx_adate_miss )
%CESR_VLC_MISSING(indataset=vdw.dx , variable=principal_dx , warnpercent= =100,  outdataset=mylib.dx_principal_dx_miss )


Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny.Staab@kpchr.org		503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  11/2011
Change: 9/2012     if &variable = ' ' ==> if compress(&variable) in ('', '.')     at two places because of erratic, illogical results observed at GHRI 
Change: 1/2013     make both failpercent and warnpercent optional, if neither is set, result is N/A and reason lists missing percentage, if only one is
					set, only that one comparison is performed (Pass/Warning or Passs/Fail)
;
****************************** CESR_VLC_Missing **********************************
****************************** CESR_VLC_Missing **********************************;
%Macro CESR_VLC_Missing(indataset =
					    ,variable =
					 ,failpercent = /* Enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.*/
					 ,warnpercent = /* Enter 1 if the warn point is >1%.  Enter =1 if the warn point is >=1%.*/
					 ,outdataset  =
					              );

%CESR_SymbolCheck;
%local missingformat result message_p message_f message_w check_miss inname selected_variable title_7 nlimits highpercent lowcountsup;

*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Missing_variable_&variable._in_&inname                         x,1,32); 
%else %let dsoutname=&outdataset;

%let variable=%upcase(&variable);

*assess if warn and/or fail cutoff are set;
	%let nlimits = 0;
	%if &failpercent ne %then %do;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&failpercent;
	%end;
	%if &warnpercent ne %then %do;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&warnpercent;
	%end;

					
title5 "Check: Rate of Occurrence of Missing Values for Variable &variable in Table &indataset";

proc format	;
  value hide        0 = "    Hidden";

  value $mmiss 	"."," "," .","  .","   .","    .","     .","      .","       .","        .",
				"         .","          .","           ."="Missing"
                 other="Non-Missing";

  value mmiss        .="Missing"
                 other="Non-Missing";
run; 

*Checks if the variable exists and if it does is it char or numeric;
proc contents data=&indataset out=type_check(keep=libname memname name type) noprint;
run;
%let selected_variable=0;*variable does not exist in data set;
data one_or_none;
  set type_check;
  if upcase(name)="&variable";
  call symput("selected_variable","1");*variable does exist in data set;
run;
%if &selected_variable=0 %then %do;
  data dco_feed;
    length Site $4. MemName $32. VarName $32.
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
    label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics';
    memname = "&inname";  
    varname = "&variable";
    site="&_siteabbr";
    check_description="Missing and Non-missing Rates"; 
    content_area="&content_area"; 
    dateran=datetime();
    version="&version";
    check=compress("&c_area._"||varname||'_'||"missing"||'_'||"Descriptive",' ');
    outdataset="&dsoutname";
    Reason = "Requested variable &variable does not exist in data set";
		Result=
		%if &failpercent ne %then %do;
		    "FAIL";
		%end; 
		%else %if &warnpercent ne %then %do;
			"WARN";
		%end;
		%else %do;
			"N/A";
		%end;    
	format dateran datetime.;
  run;
  %CESR_AppendDS(indataset=dco_feed);
  data &dsoutname;
    Site="&_siteabbr";
    memname="&inname";
    Variable="&variable";
	Note="Requested variable, &variable, does not exist in the data set &inname..";
	Result=
		%if &failpercent ne %then %do;
		    "FAIL";
		%end; 
		%else %if &warnpercent ne %then %do;
			"WARN";
		%end;
		%else %do;
			"N/A";
		%end;    
    call symput ('title_7', 
		%if &nlimits. > 0 %then %do; 
			trim(result) 
		%end;
		%else %do; 
			'Attention' 
		%end;
			||': '||trim(note));
			label site = "Site" memname = "Table Name" 
          variable="Variable Name"
          note="Message" Result="Result"
	;run;

proc print data=&dsoutname noobs label;
    var site memname variable note result;
    title7 "&title_7.";
  run;

  proc datasets nolist;
   delete dco_feed type_check one_or_none;
  run;
  quit;
%end;
%else %do;
  *Defines the missingformat as $mmiss. or mmiss.;
  data _null_;
    set type_check(where=(upcase(name)="&variable"));
    if type=2 then call symput("missingformat","$mmiss.");
    if type=1 then call symput("missingformat","mmiss.");
  run;	

  proc summary data=&indataset(keep=&variable) ;
    class &variable/missing; 
    format &variable &missingformat.;
    output out=step1;
  run;
  
  %let lowcountsup=0;
  data step1_clean(drop=_type_ &variable );
    length Site $4;
    Site="&_SiteAbbr.";
    set step1(rename=(_freq_=count)) end=eof;
    by _type_;
    retain grandtotal ;
    if  _type_=0 then do; 
		grandtotal=count;
    	delete;
	end;
	else do;
	    origpercent=(count/grandtotal)*100;
		if count < &lowest_count. then do;
			count=0;
			call symput('lowcountsup','1');
		end;
		grandtotal0 + count;
		status=put(&variable,&missingformat);
	end;
  run;

  proc freq data=step1_clean noprint;
  	tables status / out=step2 (keep=status percent);
	weight count / zero;
  run;

proc sort data=step1_clean; by status; run;
proc sort data=step2; by status; run;

 data 
	dco_feed (keep=site memname varname check_description result reason dateran version content_area check outdataset )
	&dsoutname (keep= site memname var: status count percent warn_at fail_at result reason rename=(varname=variable))
	;
    length Site $4. MemName $32. VarName $32. status $11. count 8 percent 8 warn_at $17 fail_at $17 result $8
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41
		   displaypercent $30.;
	merge step1_clean step2; by status;
	retain lowcount 0;
    memname = "&inname";
    varname = "&variable";
    site="&_siteabbr";
    check_description="Missing and Non-missing Rates"; 
    content_area="&content_area"; 
    dateran=datetime();
    version="&version";
    check=compress("&c_area._"||varname||'_'||"missing"||'_'||"Descriptive",' ');
    outdataset="&dsoutname";

	if _n_=1 then do;
		warn_at=
			%if &warnpercent ne %then %do;
				compress(">"||"&warnpercent."); 
			%end;
			%else %do;
				"No Warn Limit Set";
			%end;
		fail_at=
			%if &failpercent ne %then %do;
				compress(">"||"&failpercent."); 
			%end;
			%else %do;
				"No Fail Limit Set";
			%end;
		%if &nlimits > 0 %then %do;
			if status="Missing" then comparepercent=origpercent;
			else comparepercent = 0;
			%if &failpercent. ne %then %do;
				if comparepercent > &failpercent. then do;
					result="FAIL";
					reason="Mising values of &variable occur at too high a rate (>&failpercent.%).";
				end;
				%if &warnpercent. ne %then %do;
					else if comparepercent > &warnpercent. then do;
						result="WARN";
						reason="Missing values of &variable occur at a concerning rate (>&warnpercent.%, but not >&failpercent.%).";
					end;
				%end;
			%end;
			%else %if &warnpercent. ne %then %do;
				if comparepercent > &warnpercent. then do;
					result="WARN";
					reason="Missing values of &variable occur at a concerning rate (>&warnpercent.%).";
				end;
			%end;
				else  do;
					result="PASS";
					reason="Missing values of &variable occur at an acceptable rate (not >&highpercent.%).";
				end;
			call symput ('title_7', trim(result)||': '||trim(reason));
		%end;
		%else %do;
			if status="Missing" then do;
				if not &lowcountsup. then displaypercent=compress(put(percent,8.4))||'%';
				else if percent=0 then displaypercent='>0.0000%, but <'||compress(put(100*&lowest_count./grandtotal,8.4))||'%';
				else displaypercent='>'||compress(put(100*(grandtotal-&lowest_count.)/grandtotal,8.4))||'%, but <100.0000%';
			end;
			else displaypercent='0.0000%';

			result="N/A";
			reason="Missing values of &variable occur at rate of "||trim(displaypercent)||".";
			call symput ('title_7', trim(reason));
		%end;

		output dco_feed;
		output &dsoutname;
	end;

	else do;
		output &dsoutname;
	end;

    format dateran datetime.;
    label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics' 		  
	  status="Variable Value Status"
      count="Count - Counts Less Than &lowest_count are Hidden"
      percent="Percents are Recalculated if Counts are Hidden"
      warn_at="Warning Issued If Missing Percent Is"
      fail_at="Fail Issued If Missing Percent Is"
	;
run;




  %CESR_AppendDS(indataset=dco_feed);




  proc print data=&dsoutname noobs label;
    var site memname variable status count percent warn_at fail_at result;
	format count percent hide.;
    title7 "&title_7.";
    footnote4 "Hidden indicates a count less than &lowest_count..";
    footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
    footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
  run;

  data &dsoutname;
    set &dsoutname;
	format count;
  run;

/*  proc datasets nolist;*/
/*    delete step1 step1_clean dco_feed type_check one_or_none step2;*/
/*    run;*/
/*  quit; */
%end;

title5; 
footnote4;

%MEND   CESR_VLC_Missing;



****************************** CESR_VLC_Obsolete **********************************
****************************** CESR_VLC_Obsolete **********************************

CESR_VLC_Obsolete:

Performs a data check to determine if there are any obsolete values for a given
	character variable.  Up to 10 obsolete values can be checked at a time.

Creates 2 output table for the User to review.  
	1) Results (Pass/Warning) Reason (P/W Message)
	2) Obsolete Values, Frequency, Percent

Creates 1 permanent dataset.  
	Site, Obsolete, Count, Percent
 	 
Appends 1 test result to the DCO_file.  	

Contact Information: Don Bachman	-- Don.Bachman@kpchr.org 
										(503)-335-6731 
Created by: 	Kari Walker
Date Created:  	1/28/2010
Modifications:  

****************************** CESR_VLC_Obsolete **********************************
****************************** CESR_VLC_Obsolete **********************************;
%Macro CESR_VLC_Obsolete(indataset =
					, variable =
					, value1 = , value2 = , value3 = , value4 = , value5 = 
					, value6 = , value7 = , value8 = , value9 = , value10 =
					, message_P = "The values for &variable match current table specifications." /*Default*/
					, message_W	= "There exists obsolete values for &variable.. Please refer to table specifications."  /*Default*/ 
					, outdataset =			/*libname.name of permanent dataset  					*/
					, title =  /*Use Quotes! Leave blank for Default title*/
					  );

*MK;%if &title = %then title3  "Test of Obsolete Values in &variable in &indataset" 	;
%else title3 &Title	;  ;

%DO j = 1 %TO 10;
%IF &&value&j ne  %THEN %LET numberofvals = &j; ;
%END;

proc format	;
  value hide 
   0 = "    Hidden";
run; 

%let OBS_VAL = P;
%put &obs_val;

*Determine if there are obsolete values and turn on a flag for that;
data obs_list;
    length SITE $4;
	set &indataset;
	SITE="&_SiteAbbr.";
	if trim(left(upcase(&variable))) in 		
		(%DO i = 1 %to &numberofvals-1;
			%upcase(&&value&i),
		 %END;
			%upcase(&&value&numberofvals)		
		)
	then do;
		obsolete_desc ="Obsolete" || ' (' || trim(left(&variable)) || ')';
		call symput("OBS_VAL","W");
	end;
	RESULT_W = "WARN";
	RESULT_P = "PASS";
run;

*Depending on the Obs_Val value print off result dataset and append
a check to the DCO file;
data check_data  (drop = RESULT_&Obs_Val. Check_long x);
    length SITE $4. MEMNAME $50. varname $32. 
			CHECK $50. result $8. 	Reason $256. ;
	set obs_list (OBS = 1 keep  = SITE RESULT_&Obs_Val. );
	memname = "&indataset";
	varname = "&variable";
	Reason = &&MEssage_&Obs_Val.;
*MK*;Check_long = "&outdataset"; 
*MK*;x=index(Check_long,'.');
*MK*;check = substr(Check_long,(x+1));
	Result = RESULT_&Obs_Val.;
	label Result = 'Results' Reason = 'Reason';
run;

proc print data=  check_data  label noobs;
  VAR Result Reason;
run;

%CESR_AppendDS(indataset=check_data);


*Now if there do appear to be obsolete values then print off a frequency 
and save a dataset;
%put &obs_val;
%IF &OBS_VAL = W %then %DO;
proc means data = obs_list (keep = site obsolete_desc ) noprint  ;
  class obsolete_desc; 
  output out = step1  ;
run;

data step1_clean (drop = _type_ grandtotal);
  set step1 (rename = (_freq_ = count));
  by _type_;
  if  _type_ = 0 and first._type_ = 1 then grandtotal = count;
  retain grandtotal;
  if  _type_ = 0   then delete;
  percent = (count/grandtotal)*100;
run;

data step2;
 *mk*   length SITE $4;
  set step1_clean;
 *mk*	SITE="&_SiteAbbr.";
  if count < 6 then count = 0;
run;
 
footnote2 "Hidden indicates a count less than 6.";
proc freq data= step2 noprint;
  tables obsolete_desc/  out = hide_freq;
  weight count/zero;
  format  count hide.;
run;

proc print data = hide_freq noobs label;
label obsolete_desc = "Obsolete Values" count ="Frequency" Percent = "Percent";
run;
footnote2;

DATA &outdataset (rename = (obsolete_desc = obsolete));
    length SITE $4;
	SITE="&_SiteAbbr.";
	set  hide_freq (keep =  obsolete_desc count percent) ;
RUN;


proc datasets nolist;
   delete  step1 step2 hide_freq step1_clean;
  run;
quit; 

%END;

proc datasets nolist;
   delete  obs_list check_data;
  run;
quit; 

%MEND   CESR_VLC_Obsolete;


****************************** CESR_VLC_Trend **********************************
****************************** CESR_VLC_Trend **********************************
CESR_VLC_Trend

Tests the differences between counts of consecutive time periods. 

Modified by Don Bachman on 9/12/2012 to prevent missing value messages.   

This macro:
1. Prints 3 output reports for the user to review.
       Report 1 contains
         -  one row   
       Columns in Report are: site, result, reason, percent at which a fail is issued, percent at which a 
         warning is issued.
       Report 2 contains
         _ one row for each time period checked.
       Columns in Report are: site, variable examined, counts with values less than &lowest_count set to 0, percents 
          adjusted accordingly, percent change from earlier consecutive year, result for change and reason for 
          result.
       Report 3 contains
         _ plot of frequency by the time period designated for the values of the variable being examined.

2. Appends 1 row explaining the overall result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..Trend_&variable._in_&inname where 
       Trend_&variable._in_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site &variable count percent PctDifference ResultFlag.

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  01/2012

****************************** CESR_VLC_Trend **********************************
****************************** CESR_VLC_Trend **********************************;
%macro CESR_VLC_TREND(indataset =
					, variable=      /* Must be a SAS Date variable */
					, ClassVariable=      /* Classification Variable, Leave Blank if no classification variable - *Modified by Don on 4/5/2012 */
					, TimePeriod=Y   /*Y=Year, M=Month, D=Day*/
 	  				, missing=N  	 /*If missings are to be counted type Y else enter N */
					, failpercent=   /*Fail if more than 1%? failpercent=1 . Fail if more than or equal to 1%? - filepercent==1 */
					, warnpercent=   /*optional*/
					, outdataset=	 /* optional  ,  libname.name if permanent dataset  					*/
					  );

%CESR_SymbolCheck;
*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Trend_&variable._in_&inname                         x,1,32); 
%else %let dsoutname=&outdataset;

%let variable=%upcase(&variable);

title5  "Checking the Trend of Variable &variable in Data Set &indataset" 	;

%let message_P= "The percent difference between every pair of consecutive time periods is within a reasonable range.";*99;	
%let message_F= "The percent difference between at least 1 pair of consecutive time periods is not within a reasonable range.";	*108;
%let message_W= "There is concern about the percent difference between at least 1 pair of consecutive time periods.";*98;	

%IF &missing = Y %then %let miss = MISSING;
%else %LET miss = ;

%if &TimePeriod=Y %then title6 "By Year";;
%if &TimePeriod=M %then title6 "By Month";;
%if &TimePeriod=D %then title6 "By Day";;

*** set default values ***;
*Modified by Don on 4/5/2012*; %let check_trend=F;
*Modified by Don on 4/5/2012*; %let result=FAIL;

proc format	;
  value hide
  0 = "    Hidden";
run;

proc means data= &indataset (keep = &variable)  noprint;
  class &variable/&miss;
  %if &TimePeriod=Y %then format &variable year.;;
  %if &TimePeriod=M %then format &variable yymmn6.;;
  output out = counts;
run;

data counts_clean (drop = _type_);
  length site $4;
  site="&_SiteAbbr";
  set counts(rename=(_freq_=count));
  by _type_;
  if &variable ne . then do;
     %if &TimePeriod=Y %then &variable=year(&variable);;
     %if &TimePeriod=M %then &variable=int(put(&variable,yymmn6.));;
     format &variable;
  end;
  if  _type_=0 and first._type_ then grandtotal=count;
  retain grandtotal;
  if  _type_=0 then delete;
  	call symput('CHECK_TREND','P');
    call symput('Result','PASS');
  run;

*** set default value, if this macro var is 0 later, then the input file has 0 records ***;
*Modified by Don on 4/5/2012*; %let vcounts_clean_rec_cnt=0;

data vcounts_clean;
  set counts_clean end=eof;
  retain rResultFlag 'PASS   ';
  if count < &lowest_count then count = 0;
  x = lag(count);
  retain  x;
  percent = (count/grandtotal)*100;
  if x in (.,0) or eof or _n_<=2 then PctDifference=.;  
  else PctDifference=((count-x)/x)*100;
  length ResultFlag $60;
  resultflag='PASS';

  if PctDifference ne . then do; 
    %if &failpercent ne  %then %do;
      if abs(PctDifference) > &failpercent then do;
          rResultFlag='FAIL   ';
	  resultFlag="FAIL (Change>&failpercent.%)";  
      end;
    %end;

    %if &warnpercent ne  %then %do;
      else do;
	  if abs(PctDifference)>&warnpercent then do;
        if rResultFlag ne 'FAIL   ' then rResultFlag='WARN';
        ResultFlag="WARNING (Change is >&warnpercent but not >&failpercent.%)"; *reworded because &warnpercent could be, for example, =20 which means >=20;
  	  end;                                                                      *or just 20 which means >20;
      end;
    %end;
  end;

  if _n_=1 then ResultFlag='First Time Period Not Checked for Percent Change ';
  if _n_=2 then ResultFlag='Second Time Period Not Checked for Percent Change'; *since first timeperiod is likely incomplete;

  if eof then do;

*** Determine if the input file has 0 records, if this do loop is executed, then it does not ***;
*Modified by Don on 4/5/2012*; call symput('vcounts_clean_rec_cnt',left(_n_));

    ResultFlag='Most Recent Time Period Not Checked for Percent Change';
    if rResultFlag='FAIL   ' then do;
      call symput('CHECK_TREND','F');
	  call symput('Result','FAIL');
    end;
    else if rResultFlag='WARN' then do;
      call symput('CHECK_TREND','W');
      call symput('Result','WARN');
    end;
  end;

  TEST_F = &message_F;
  TEST_P = &message_P;
  %if &warnpercent ne  %then TEST_W = &message_W; ;
    label site="Site" 
    &variable="Variable Examined: &variable" 
    count="Count With Values Less Than &lowest_count Set to Zero" 
    percent="Percent Determined After Counts Zeroed"
    pctdifference='Percent Difference From Earlier Time Period'
    resultflag='Result Flag (one time period only)';
run;

data check_data  (drop = TEST_&CHECK_TREND);
  
*Modified by Don on 4/5/2012 start*;

%if &vcounts_clean_rec_cnt ne 0 %then %do;  *execute as original code if the input file has data*;
   set vcounts_clean  (OBS = 1 keep  =  TEST_&CHECK_TREND SITE);
      Reason = TEST_&CHECK_TREND;
      Result = "&Result";

%end;
%else %do;  *** set these variables when the input file has 0 observations ***;
      Reason = "Input File had 0 records.  Test Not Done.";
      Result = "WARN";
      length site $ 4;
      site="&_SiteAbbr";
      TEST_F = "Input File had 0 records.  Test Not Done.";
      TEST_W = "Input File had 0 records.  Test Not Done.";
%end;
  length varname $ 32;
  if length("&classvariable")>1 then do;
     varname = substr(upcase("&variable (&classvariable)                                   x"),1,32);   
  end;
  else do;
     varname = "&variable"; 
  end;

*Modified by Don on 4/5/2012 end*; 

  check_description="Trend Test for Variable";
  memname = "&inname";

  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  if "&warnpercent"="" then warn='No Warning Percentage Entered'; else warn=">"||"&warnpercent"||"%";
  fail=">"||"&failpercent"||"%";
  check=compress("&content_area._"||varname||'_'||"trend"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
  format dateran datetime.;
  label Result = "Result" 
    Reason = "Reason" 
    warn="Warn at" 
    fail="Fail at";
run;

proc print data=check_data label noobs;
  var site result reason warn fail;
run;

title7 "FAIL if Percentage Difference Between Consecutive Years is >&failpercent";
%if &warnpercent ne %then title8 "WARN if Percentage Difference is >&warnpercent.% but not >&failpercent.%";;
proc print data=vcounts_clean label noobs;
  var site &variable count percent pctdifference resultflag;
run;

data check_data;
  set check_data(drop=fail warn);
run;

%CESR_AppendDS(indataset=check_data);

proc plot data=vcounts_clean;
  plot count*&variable/vzero;
  label count="FREQUENCY" &variable="&variable";;
quit;

data &dsoutname;
   set vcounts_clean;
   keep site &variable count percent pctdifference resultflag;
run;
  
proc datasets nolist;
   delete  vcounts_clean counts_clean counts check_data;
run;
quit;
title5;
footnote4;
  
%mend CESR_VLC_TREND;


****************************** CESR_VLC_TYPE_MTSV ***************************
****************************** CESR_VLC_TYPE_MTSV ***************************

CESR_VLC_TYPE_MTSV:

This macro performs a data check comparing the specified variable's actual type 
to the requested check type across multiple data sets.  

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each data set checked
       Columns in Report are: site, data set name, variable name, type, requested type check.

2. Appends 1 row explaining the results for the requested variable and data sets to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, requested check, result, reason. 

3. Creates 1 dataset called &QAoutlib..type_of_var_&variable._mtsv 
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &variable receives its value from the user as a parameter value when this macro is invoked.
       Columns in table are: site, data set name, variable name, type, requested type check.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:
       REMEMBER - data set names MUST be separated with a blank
                - 1 corresponds to numeric
                - 2 corresponds to character 
    a) supply the names of SAS tables to check.  The tables can be permanente with two level name or temporary with single
       level name.
    b) supply the variable contained in the SAS tables to be checked.
    c) supply a type to compare to the variable's actual type.  Numeric type=1.  Character type=2.

Example Calls:

%CESR_VLC_TYPE_MTSV(indatasets=VDW.PHARMACY VDW.CENSUS VDW.VITALS, variable=mrn, type=2)
%CESR_VLC_TYPE_MTSV(indatasets=VDW.ENC VDW.DX VDW.PX VDW.VITALS, variable=enc_id, type=2)

Contact Information: Don Bachman	-- Don.Bachman@kpchr.org 
										(503)-335-6731 
Created by: 	Kari Walker
Date Created:  	11/10/2010
Modifications:  Dons *M* from 1/6/2011 provider program
				Karis *MK* defensive coding to make sure pass/fail
					messages arent cut off. 
                Gwyn 6/2011 overhaul 
****************************** CESR_VLC_TYPE_MTSV ***************************
****************************** CESR_VLC_TYPE_MTSV ***************************;

%Macro CESR_VLC_TYPE_MTSV(indatasets=,variable=,type=);
%CESR_SymbolCheck;
%let indatasets=%upcase(&indatasets);
%let variable=%upcase(&variable);
%let QAoutlib=%upcase(&QAoutlib);
%local found dscounter ds parser num_of_ds match_list no_match_list var_not_in_ds_list result reason;
title5 "Check: Type of Variable &variable in One or More Tables";
*parse list data set names separated with blanks;
%let parser=1;
%let DScounter=0;
%if &indatasets ne %then %do;*if data set names were entered when macro was invoked;
  %let found=%scan(&indatasets,&parser,%str( ));*find the first data set name;
  %do %while (&found ne);*as long as there is a value left to work with from the data set list stay in this loop;
    %let DScounter=%eval(&DScounter+1); *increment the data set counter;
    %local indataset&DScounter; *add indataset1, indataset2, ... to local symbol table;
    %let indataset&DScounter=&found; *the data set name will be stored in var1, var2,...;
    %let parser=%eval(&parser+1);
    %let found=%scan(&indatasets,&parser,%str( ));*find the next data set name;
  %end;
  %let num_of_ds=&DScounter;
%end;*if;
%do ds = 1 %TO &num_of_ds;
	proc contents data=&&indataset&ds out=inds_type_&ds(keep=memname name type ) noprint;
   	run;	
%end;

data combined_type(rename=(name=varname));  
  set 
    %DO ds = 1 %TO &num_of_ds;
	  inds_type_&ds(where=(upcase(name)="&variable"))  
	%END; ;
	length Site $4;
    Site="&_SiteAbbr.";
	Requested_Check=&type;
run;
data combined_dsname;
  set 
    %DO ds = 1 %TO &num_of_ds;
      inds_type_&ds(keep=memname)  
    %END; ;
	by memname;
	if first.memname;
run;
data combined;
  merge combined_type combined_dsname;
  by memname;
run; 
%let match_list=;
%let no_match_list=;
%let var_not_in_ds_list=;
data _null_;
  set combined;
  if type=. then do;
    if symget("var_not_in_ds_list")='' then call symput("var_not_in_ds_list",trim(memname));*if first data set in this category;
    else call symput("var_not_in_ds_list",left(trim(symget("var_not_in_ds_list"))||', '||trim(memname)));
  end;
  else if requested_check=type then do;
    if symget("match_list")='' then call symput("match_list",trim(memname));*if first data set in this category;
    else call symput("match_list",left(trim(symget("match_list"))||', '||trim(memname)));
  end;
  else do;*requested_check ne type;
    if symget ("no_match_list")='' then call symput("no_match_list",trim(memname));*if first data set in this category;
    else call symput("no_match_list",left(trim(symget("no_match_list"))||', '||trim(memname)));
  end;
run;
%if &no_match_list&var_not_in_ds_list= %then %do;
  %let result=PASS;
  %if &type=1 %then %let reason=All data sets (&match_list) correctly have the variable &variable as a numeric.;
  %else %let reason=All data sets (&match_list) correctly have the variable &variable as a character.; 
%end;
%else %do;
  %let result=FAIL;
  %if &no_match_list= %then %let no_match_list=No data sets;
  %if &var_not_in_ds_list= %then %let var_not_in_ds_list=No data sets;
  %if &type=1 %then %do;
    %if &match_list= %then %let reason=No listed data set had the variable &variable as numeric.  &no_match_list had &variable as character.  &var_not_in_ds_list did not have &variable at all.;     
    %else %let reason=Only some listed data sets had the variable &variable as numeric. &no_match_list had &variable as character.  &var_not_in_ds_list did not have &variable at all.  &match_list correctly had &variable as numeric.; 
  %end;
  %else %do;
    %if &match_list= %then %let reason=No listed data set had the variable &variable as character. &no_match_list had &variable as numeric.  &var_not_in_ds_list did not have &variable at all.;     
    %else %let reason=Only some listed data sets had the variable &variable as character.  &no_match_list had &variable as numeric.  &var_not_in_ds_list did not have &variable at all.  &match_list correctly had &variable as character.; 
  %end;
%end;
data check_data;
		length SITE $4. MEMNAME $32. Varname $32.
			CHECK $50. Result $8.  	Reason $256. ;
  site="&_siteabbr";
  memname="&indatasets";
  varname="&variable";
  check="Type of Specified Variable in Multiple Data Sets";
  result="&result";
  reason="&reason";
run;

%CESR_AppendDS(indataset=check_data);

proc format;
  value var_type 1='Numeric'
                 2='Character'
                 .='Not in Data Set';
run;
data &QAoutlib..%substr(type_of_var_&variable._mtsv                  x,1,32)  (label="Variable Type");
  length Site $ 4 MemName  $ 41 VarName $ 32 Type  Requested_Check 8;
  set combined;
  varname="&variable";
  site="&_siteabbr";
  requested_check=&type;
run;
proc print data=&QAoutlib..%substr(type_of_var_&variable._mtsv                  x,1,32) label="Variable Type";
  format type requested_check var_type.;
  LABEL  memname = 'Table Name' varname = 'Variable Name' type = 'Variable Type' requested_check='Requested Check';
run;

*cleanup; 
proc datasets nolist;
  delete check_data combined combined_dsname combined_type %do i=1 %to &num_of_ds; inds_type_&i %end; ;
quit; 
title5;
footnote4;

%mend CESR_VLC_TYPE_MTSV;


****************************** CESR_VLC_TYPE_STMV **********************************
****************************** CESR_VLC_TYPE_STMV **********************************

CESR_VLC_TYPE_STMV:

This macro performs a data check verifying that the types of one or more variables
    in a single data set satisfy the types specified for the variables.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each variable check requested with a pass or fail result and a reason explaining
            the result value
       Columns in Report are: data set name, variable name, result, reason, 
            type, requested type check,.

2. Appends check results for requested variables to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called &QAoutlib..Types_of_Vars_in_&inname 
       where inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, variable name, result, reason, type, requested check.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:
       REMEMBER - variable names and types MUST be separated with a blank
                - 1 corresponds to numeric
                - 2 corresponds to character 
    a) supply the name of a SAS table to check.  The table can be permanent with a two level name or temporary with a single
       level name.
    b) list variables contained in the SAS table to be checked along with type values to compare with the actual types.
       -  Each variable can be followed with a type value with which to compare the actual type.
       -  If several variables are to be compared to the same type the variables can be listed and then the type can be listed once.
    c) optionally supply the name of an output SAS table.  The table would most likely be permanent with a two level name, but it could be
       temporary with a single level name. 

Example Calls:

%CESR_VLC_TYPE_STMV(indataset=VDW.PHARMACY, vars_and_types=mrn 2 rxdate 1 ndc 2 rxsup 1 rxamt 1 rxmd 2 , outdataset=MyLibRef.Pharmacy_Checks)
  another way to make a very similar call:
%CESR_VLC_TYPE_STMV(indataset=VDW.PHARMACY, vars_and_types=mrn ndc rxmd 2 rxdate rxsup rxamt 1) *This call would create an output dataset
                                                                                                 called &QAoutlib..Types_of_Vars_in_Pharmacy. 

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    DCC Consultants and Analysts
Published:  11/2011


****************************** CESR_VLC_TYPE_STMV **********************************
****************************** CESR_VLC_TYPE_STMV **********************************;
%Macro CESR_VLC_TYPE_STMV(indataset=,vars_and_types=,outdataset=);

%CESR_SymbolCheck;
%local FOUND MAX_LEN I J VCOUNTER NUM_OF_VARS PARSER DSOUTNAME INNAME;

*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&indataset;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Types_of_Vars_in_&inname                   x,1,32);
%else %let dsoutname=&outdataset;

%let QAoutlib=%upcase(&QAoutlib);
title5 "Check: Types of One or More Variables in Table &indataset";

*parse variables and types;
%let parser=1;
%let Vcounter=1;
%if &vars_and_types ne %then %do;*if variables and types were entered when macro was invoked;
  %let found=%scan(&vars_and_types,&parser,%str( ));*find the first variable name;
  %do %while (&found ne);*as long as there is a value left to work with from the variables and type list stay in this loop;
    %if %index(_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,%substr(&found,1,1)) ne 0 %then %do; *a character or _ has been found;
      %local var&Vcounter typ&Vcounter;*add var1, typ1, var2, typ2,... to local symbol table;
      %let %trim(var%left(&Vcounter))=&found; *the variable name will be stored in var1, var2,...;
      %let Vcounter=%eval(&Vcounter+1); *increment the variable counter;
    %end;
    %else %if %index(12,%substr(&found,1,1)) ne 0 %then %do;*a type has been found;
      %let %trim(typ%left%eval(&Vcounter-1))=&found;*the variable type will be stored in typ1, typ2...;
    %end;
    %let parser=%eval(&parser+1); *point to the next piece of infomation in the list of variables and lengths;
    %let found=%scan(&vars_and_types,&parser,%str( )); *find the next piece of information when parsing variables and types;
  %end;*while;
  %let num_of_vars=%eval(&Vcounter-1);
%end;*if do;
%if &num_of_vars gt 1 %then %do; *fill in types for earlier variables listed in a series;
  %do i=&num_of_vars %to 1 %by -1;
      %if %length(&&typ&i)=0 %then %do;
      %let j=%eval(&i+1);
      %let typ&i=&&typ&j;
    %end;
  %end;
%end;*if do;
data requested_variables;
  %let max_len=%length(&typ1);*find number of storage bytes needed for the length information entered;
  %if &num_of_vars > 1 %then %do;
    %do i=2 %to &num_of_vars;
      %if &max_len < %length(&&typ&i) %then %do;
        %let max_len=%length(&&typ&i);
      %end;
    %end;
  %end;
  length name $ 32 requested_check $ &max_len;
  %do i=1 %to &num_of_vars;
    name=upcase("&&var&i");
    requested_check="&&typ&i";
    output;
  %end;
run;
proc sort data=requested_variables;
  by name;
run;
proc contents data=&indataset out=contents_type(keep=memname name length type) noprint;
run;
data contents_type;
  set contents_type;
  name=upcase(name);
run;
proc sort data=contents_type;
  by name;
run;
data variables_list(rename=(name=varname));
  merge contents_type(in=in_data_set) requested_variables(in=requested);
  by name;
  if requested; *only keep rows of information for requested variables;
  if in_data_set then in_ds=1;
run;
data variables_list2(drop = in_ds);
  length Site $4. MemName $32. VarName $32.
		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41 Type 8 Length 8 Requested_Check $ &max_len;
  set variables_list;
  if in_ds ne 1 then do;
    result='FAIL';
    reason='A check was requested for this variable, but the variable does not exist in the data set.';
    sortorder=3;
    memname="&inname";
  end;
  else if type=input(requested_check,&max_len..) then do;
    result='PASS';
	if type=1 then reason="Requested type and actual type are both numeric.";
	else reason="Requested type and actual type are both character.";
    sortorder=2;
  end;
  else if type ne input(requested_check,&max_len..) then do;
    result='FAIL';
    if type = 1 then reason="Requested type is character, but actual type is numeric.";
    else reason="Requested type is numeric, but actual type is character.";
    sortorder=1;
  end;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
    OutDataSet = 'Data Set Containing Check Specifics' Requested_Check = "Requested Check" ;
  site="&_siteabbr";
  check_description="Type of Variables in Single Data Set"; 
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&c_area._"||varname||'_'||"type"||'_'||"Descriptive",' ');
  outdataset="&dsoutname";
  format dateran datetime.;
run;

proc sort data=variables_list2(drop=length) out=&dsoutname;
  by sortorder;
run;
proc format;
  value var_type 1='Numeric'
                 2='Character'
                 .='Not in Data Set';
  value $v_type '1'='Numeric'
                '2'='Character';
run;
ods proclabel="Variable Types in &inname.";
proc print data=&dsoutname (drop=sortorder site check content_area dateran 
                             version check_description outdataset) label; *at this point dsoutname has ALL DCO_file vars plus type and requested_check;
  format type var_type. requested_check $v_type.;
run;

data dco_feed;
  set &dsoutname(drop=sortorder type requested_check);
run;

data &dsoutname  (label="Variable Type");
  set &dsoutname(drop=sortorder check content_area dateran version check_description outdataset);
run;

%CESR_AppendDS(indataset=dco_feed);

*cleanup;
proc datasets nolist ;
   delete  contents_type dco_feed requested_variables variables_list variables_list2;
quit;

title5;
footnote4;

%Mend CESR_VLC_TYPE_STMV;



****************************** CESR_VLC_UNIQUENESS_SV **********************************
****************************** CESR_VLC_UNIQUENESS_SV **********************************

CESR_VLC_UNIQUENESS_SV:

This macro checks if the values of a specific variable are unique or have duplicate values at a higher
than user specified percent.  Missing values can be included or excluded.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row showing duplicate information and one row showing unique value informationfor variable
            checked with a pass, warn or fail result and a reason explaining the result value
       Columns in Report are: site, data set name, variable name, duplicate or not, count, 
                              warn point, fail point, result. 

2. Appends check results for variable to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called &QAoutlib..Uniqueness_of_&variable_in_&inname 
       where inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset receives its values from the user as a parameter value when this macro is invoked.
       Columns in table are: site, data set name, variable name, duplicate or unique value, count, warn_at, fail_at, result. 

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
					 Jenny.Staab@kpchr.org		503-335-6683
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  12/2011
Modified:	11/6/13 - Gwyn Saylor
						- does not fill all columns if missing=N results in 0 records

****************************** CESR_VLC_UNIQUENESS_SV **********************************
****************************** CESR_VLC_UNIQUENESS_SV **********************************;



%Macro CESR_VLC_UNIQUENESS_SV(indataset =
				    , variable =		 
					, failpercent =  /*Fail if more than 1%? Then type 1 Fail if more than or equal to 1% type =1*/
					, warnpercent =
					, missing = Y 	/*If missings are to be counted type Y else enter N , Y is Default*/ 
					, outdataset = /*libname.name of permanent dataset with check results*/
					, dupedataset = /*libname.name of dataset where duplicate records get stored*/
                    );

	%CESR_SymbolCheck;

	%local inname dsoutname missing_note counts_lt_lowest_count real_percent zeroed_percent result reason macroname;
	       
	*establish macro variable values;
	%let indataset=%upcase(&indataset);
	%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
	%else %let inname=&indataset;
	%let variable=%upcase(&variable);
	%let missing=%upcase(&missing);


	*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
	%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Uniqueness_of_&variable._in_&inname                          x,1,32);
	%else %let dsoutname=&outdataset;
	%if &missing=N %then %let missing_note=Missing values, if they exist, were excluded.;
	%else %let missing_note=Missing values, if they exist, were included.;


	%let QAoutlib=%upcase(&QAoutlib);
	title5  "Test of Duplicates in the Variable &variable in the Data Set &indataset";

	proc format	;
	  value hide 0 = "    Hidden";
	run;

	proc sort data=&indataset(keep=&variable) out=var_sort;
	  by &variable;
	run;

	           *When the DATA= input data set is stored as a table or view in a database management system (DBMS), the PROC SORT procedure can use 
	           in-database processing to sort the data. In-database processing can provide the advantages of faster processing and reduced data transfer
	           between the database and SAS software.  The order in which alphanumeric characters are sorted is known as the collating sequence.  
	           This sort order is determined by the session encoding. 
               By default, PROC SORT uses either the EBCDIC or the ASCII collating sequence when it compares character values, depending on the environment
               under which the procedure is running.  For example, EBCDIC (z/OS) orders _aA9 and ASCII (UNIX, Windows and VMS) would order the same characters 9A_a. ;
               option nobysorted;*the sorted order of the possibly in-database proc sort above may not correspond to the needs of the data step 
			                      below this statement.;*added 11/6/13; 

	*if &missing=N delete records with missing value from being part of review.
	*creates categorical variable to tag duplicates;
	data 
		var_dups (keep = unique dupe total)
		%if "&dupedataset." ne "" %then %do;
		&dupedataset (keep = &variable nrecords)
		%end;
		;
	*length duplicate $12; *commented out 11/6/13;
	  set var_sort end=eof; 
	  %if &missing = N %then %do; 
		if NOT missing(&variable);
	  %end;
	  by &variable.;
	  retain unique dupe nrecords 0;

	  if first.&variable then nrecords=0;

	  nrecords + 1;

	  if last.&variable. then do;
		if nrecords=1 then unique+1;
	  	else do;
			dupe+nrecords;
			%if "&dupedataset." ne "" %then %do;
			output &dupedataset.;
			%end;
		end;
	  end;

	  if eof then do;
	  		total=unique+dupe;
			output var_dups;
	  end;
	  label nrecords = "Number of Records with this Value of &Variable.";
	run;
               option bysorted;*the sorted order of the possibly in-database proc sort above may not correspond to the needs of the data step 
			                    above this statement.;*added 11/6/13; 

*find total records, total duplicates and total unique records.  (total duplicates+total unique records=total records);
*calculate the percent of unique records and the percent of duplicated records;
	data var_dups_count;
	length duplicate $12;
		set var_dups;

		if 0< unique < &lowest_count. then unique0=0;
		else unique0=unique;
		if 0< dupe < &lowest_count. then dupe0=0;
		else dupe0=dupe;
		total0=dupe0+unique0;

			duplicate="Duplicates";
			zeroed_count=dupe0;
			zeroed_percent=100*dupe0/total0;
			dupe_percent=100*dupe/total;
			if dupe>0 then output;
			%if %eval(&warnpercent= ) %then %do;*optional parameter warnpercent not used;
			    if dupe_percent>&failpercent then do; *greater than fail percent;
			      result="FAIL";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records is >&failpercent % and is therefore not an acceptable percent of duplicates for variable &variable.."; 
			    end;
				else do;
			      result="PASS"; *there is no warn and not greater than fail;
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for variable &variable is not >&failpercent % and is, therefore, within acceptable range.";
			    end;
			%end;	
			%else %do;*optional parameter warnpercent was used;
			    if dupe_percent>&failpercent then do; *greater than fail percent;
			      result="FAIL";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records is >&failpercent % and is therefore not an acceptable percent of duplicates for variable &variable.."; 
			    end;
			    else if dupe_percent>&warnpercent then do; *greater than warn but less than fail;
			      result="WARN";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for variable &variable is >&warnpercent % but not >&failpercent %."; 
				end;
				else do;
			      result="PASS"; *not greater than warn;
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for variable &variable is not >&warnpercent % and is, therefore, within acceptable range."; 
				end;
			%end;
	  		call symput ("result",result);
	  		call symput ("reason",reason);

			duplicate="Unique Value";
			zeroed_count=unique0;
			zeroed_percent=100*unique0/total0;
			if unique>0 then output;

		keep duplicate zeroed_count zeroed_percent;
	run;



	data dco_feed;
	  length Site $4. MemName $32. VarName $32.
	         Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
	  label site = "Site" memname = "Table Name" varname = "Variable Name"
	    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
	    OutDataSet = 'Data Set Containing Check Specifics';
	  memname = "&inname";  
	  varname = "&variable";
	  site="&_siteabbr";
	  check_description="Uniqueness of Values of a Variable in Single Data Set"; 
	  content_area="&content_area"; 
	  dateran=datetime();
	  version="&version";
	  check=compress("&content_area._"||varname||'_'||"uniqueness"||'_'||"Descriptive");
	  outdataset="&dsoutname";
	  result=trim("&result.");
	  reason=trim("&reason.");
	  format dateran datetime.;
	run;

	%CESR_AppendDS(indataset=dco_feed);


	data &dsoutname (label="Uniqueness of &variable. in &Content_Area. Table");
	  site="&_siteabbr";
	  memname="&inname";
	  variable="&variable.";
	  set var_dups_count;
	    count=zeroed_count;
	    percent=zeroed_percent;
	    if _n_=1 then do;
	 	 if "&warnpercent"="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&warnpercent";
	     fail_at=">"||"&failpercent";
	     result="&result";
	    end;

		label site = "Site" memname = "Table Name" 
	          variable="Variables"
			  duplicate="Duplicate or Unique Value"
	          count="Count - Counts Less Than &lowest_count are Hidden"
	          percent="Percents are Recalculated if Counts are Hidden"
	          warn_at="Warning Issued If Duplicate Percent Is"
	          fail_at="Fail Issued If Duplicate Percent Is"
	          Result="Result";
		keep site memname variable DUPLICATE count percent warn_at fail_at result;
	run;

	ods proclabel = "Uniqueness of &variable. in &Content_Area. Table";
	proc print data=&dsoutname noobs label;
	  var site memname variable duplicate count percent warn_at fail_at result;
	  format count percent hide.;
	  title6 "&result";
	  title7 "&reason";
	  title8 "&missing_note";
	  title9 "Hidden indicates a count less than &lowest_count..";
	  title10 "FIRST comparisons are made to the fail and warn percentage cutoff values. THEN counts less than &lowest_count are hidden and percentages are recalculated.";
	%if "&dupedataset." ne "" %then %do;
	  footnote4 "Duplicate Combinations and their record counts  are stored in %upcase(&dupedataset.).";
	%end;
	run;

*clean up;
	proc datasets nolist;
	  delete dco_feed var_dups var_dups_count var_sort; 
	run;
	quit;

title5;
footnote4;

%Mend CESR_VLC_UNIQUENESS_SV;


****************************** CESR_VLC_UNIQUENESS_MV **********************************
****************************** CESR_VLC_UNIQUENESS_MV **********************************

This macro checks if the values of a specific variable are unique or have duplicate values at a higher
than user specified percent.  Missing values can be included or excluded.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row showing duplicate information and one row showing unique value informationfor variable
            checked with a pass, warn or fail result and a reason explaining the result value
       Columns in Report are: site, data set name, variable names, duplicate or not, count, 
                              warn point, fail point, result. 

2. Appends check results for variable to the DCO_file.
       Columns in DCO_file are: site, data set name, variable names, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called &QAoutlib..Uniqueness_of_&valist_._in_&inname 
       where inname is the data set name without the libname in front
	   and varlist_ is the list of variables concatenated with underscores (_).
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset receives its values from the user as a parameter value when this macro is invoked.
       Columns in table are: site, data set name, variable name, duplicate or unique value, count, warn_at, fail_at, result. 


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
					 Jenny.Staab@kpchr.org.		503-335-6683
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  12/2011
Modified:	11/6/13 - Gwyn Saylor


****************************** CESR_VLC_UNIQUENESS_MV **********************************
****************************** CESR_VLC_UNIQUENESS_MV **********************************;

%Macro CESR_VLC_UNIQUENESS_MV(indataset =
				    , variables =
					, failpercent =  /*Fail if more than 1%? Then type 1 Fail if more than or equal to 1% type =1*/
					, warnpercent =
					, outdataset = /*libname.name of permanent dataset with check results*/
					, dupedataset = /*libname.name of dataset with duplicate value combinations*/
					  );

	%CESR_SYMBOLCHECK;


	proc format	;
	  value hide 
	   0 = "    Hidden";
	run;


	*establish macro variable values;
	%let indataset=%upcase(&indataset);
	%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
	%else %let inname=&indataset;

	*clean up and extract info from variable list;
	%let variables=%upcase(&variables.);
	%let variables=%sysfunc(compbl(&variables.));
	%let varlist_=%sysfunc(translate(&variables,%str(_),%str( )));

	%let lastvar=%scan(&variables., -1);



	*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
	%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Uniqueness_of_&varlist_._in_&inname                          x,1,32);
	%else %let dsoutname=&outdataset;



	%let QAoutlib=%upcase(&QAoutlib);
	title5  "Test of Duplicates of (&variables.) Combinations in the Data Set &indataset";

	proc format	;
	  value hide 0 = "    Hidden";
	run;

	proc sort data=&indataset(keep=&variables.) out=var_sort;
	  by &variables.;
	run;


	*creates categorical variable to tag duplicates;
	*find total records, total duplicates and total unique records.  (total duplicates+total unique records=total records);

	           *When the DATA= input data set is stored as a table or view in a database management system (DBMS), the PROC SORT procedure can use 
	           in-database processing to sort the data. In-database processing can provide the advantages of faster processing and reduced data transfer
	           between the database and SAS software.  The order in which alphanumeric characters are sorted is known as the collating sequence.  
	           This sort order is determined by the session encoding. 
               By default, PROC SORT uses either the EBCDIC or the ASCII collating sequence when it compares character values, depending on the environment
               under which the procedure is running.  For example, EBCDIC (z/OS) orders _aA9 and ASCII (UNIX, Windows and VMS) would order the same characters 9A_a. ;
               option nobysorted;*the sorted order of the possibly in-database proc sort above may not correspond to the needs of the data step 
			                      below this statement.;*added 11/6/13; 

	data 
		var_dups (keep = unique dupe total)
		%if "&dupedataset." ne "" %then %do;
		&dupedataset (keep = &variables nrecords)
		%end;
		;
	  set var_sort end=eof; 
	  by &variables.;
	  retain unique dupe nrecords 0;

	  if first.&lastvar. then nrecords=0;

	  nrecords + 1;

	  if last.&lastvar. then do;
		if nrecords=1 then unique+1;
	  	else do;
			dupe+nrecords;
			%if "&dupedataset." ne "" %then %do;
			output &dupedataset.;
			%end;
		end;
	  end;

	  if eof then do;
	  		total=unique+dupe;
			output var_dups;
	  end;
	  label nrecords = "Number of Records with this Variable Combination";

	run;
               option bysorted;*the sorted order of the possibly in-database proc sort above may not correspond to the needs of the data step 
			                    above this statement.;*added 11/6/13; 

	*transpose variables, fix low counts, compute percentages;
	data var_dups_count;
	length duplicate $12;
		set var_dups;

		if 0< unique < &lowest_count. then unique0=0;
		else unique0=unique;
		if 0< dupe < &lowest_count. then dupe0=0;
		else dupe0=dupe;
		total0=dupe0+unique0;

			duplicate="Duplicates";
			zeroed_count=dupe0;
			zeroed_percent=100*dupe0/total0;
			dupe_percent=100*dupe/total;
			if dupe>0 then output;
			%if %eval(&warnpercent= ) %then %do;*optional parameter warnpercent not used;
			    if dupe_percent>&failpercent then do; *greater than fail percent;
			      result="FAIL";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records is >&failpercent % and is therefore not an acceptable percent of duplicates for (&variables.) combinations."; 
			    end;
				else do;
			      result="PASS"; *there is no warn and not greater than fail;
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for (&variables.) combinations is not >&failpercent % and is, therefore, within acceptable range.";
			    end;
			%end;	
			%else %do;*optional parameter warnpercent was used;
			    if dupe_percent>&failpercent then do; *greater than fail percent;
			      result="FAIL";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records is >&failpercent % and is therefore not an acceptable percent of duplicates for (&variables.) combinations."; 
			    end;
			    else if dupe_percent>&warnpercent then do; *greater than warn but less than fail;
			      result="WARN";
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for (&variables.) combinations is >&warnpercent % but not >&failpercent %."; 
				end;
				else do;
			      result="PASS"; *not greater than warn;
			      Reason="The "||strip(put(zeroed_percent,8.4))||" % duplicate records for (&variables.) combinations is not >&warnpercent % and is, therefore, within acceptable range."; 
				end;
			%end;
	  		call symput ("result",result);
	  		call symput ("reason",reason);

			duplicate="Unique Value";
			zeroed_count=unique0;
			zeroed_percent=100*unique0/total0;
			if unique>0 then output;

		keep duplicate zeroed_count zeroed_percent;
	run;


	data dco_feed;
	  length Site $4. MemName $32. VarName $32.
	         Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
	  label site = "Site" memname = "Table Name" varname = "Variable Name"
	    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
	    OutDataSet = 'Data Set Containing Check Specifics';
	  memname = "&inname";  
	  varname = "&varlist_.";
	  site="&_siteabbr";
	  check_description="Uniqueness of Combinations of Values of Multiple Variables in Single Data Set"; 
	  content_area="&content_area"; 
	  dateran=datetime();
	  version="&version";
	  check=compress("&content_area._"||"&varlist_."||'_'||"uniqueness"||'_'||"Descriptive",' ');
	  outdataset="&dsoutname";
	  result=trim("&result.");
	  reason=trim("&reason.");
	  format dateran datetime.;
	run;

	%CESR_AppendDS(indataset=dco_feed);



	data &dsoutname (label="Uniqueness of (&variables.) in &Content_Area. Table");
	  site="&_siteabbr";
	  memname="&inname";
	  variable="&variables.";
	  set var_dups_count;
	    count=zeroed_count;
	    percent=zeroed_percent;
	    if _n_=1 then do;
	 	 if "&warnpercent"="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&warnpercent";
	     fail_at=">"||"&failpercent";
	     result="&result";
	    end;

		label site = "Site" memname = "Table Name" 
	          variable="Variables"
			  duplicate="Duplicate or Unique Value"
	          count="Count - Counts Less Than &lowest_count are Hidden"
	          percent="Percents are Recalculated if Counts are Hidden"
	          warn_at="Warning Issued If Duplicate Percent Is"
	          fail_at="Fail Issued If Duplicate Percent Is"
	          Result="Result";
		keep site memname variable DUPLICATE count percent warn_at fail_at result;
	run;
	
	ods proclabel = "Uniqueness of Variable Combination in &Content_Area. Table";
	proc print data=&dsoutname noobs label;
	  var site memname variable duplicate count percent warn_at fail_at result;
	  format count percent hide.;
	  title6 "&result";
	  title7 "&reason";
	  title8 "Missing values, if present, were included.";
	  title9 "Hidden indicates a count less than &lowest_count..";
	  title10 "FIRST comparisons are made to the fail and warn percentage cutoff values. THEN counts less than &lowest_count are hidden and percentages are recalculated.";
	%if "&dupedataset." ne "" %then %do;
	  footnote4 "Duplicate Combinations and their record counts  are stored in %upcase(&dupedataset.).";
	%end;
	run;

	*clean up;
	proc datasets nolist;
	  delete dco_feed var_dups var_dups_count ; 
	run;
	quit;
	title5;
	footnote4;

%MEND CESR_VLC_UNIQUENESS_MV;


******************************* CESR_VLC_VarExist ***********************************
******************************* CESR_VLC_VarExist ***********************************

CESR_VLC_VarExist:

This macro performs a data check that verifies any number of variables existence in a given dataset.  

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each data set variable checked 
       Columns in Report are: site, data set name, variable name, result and reason.

2. Appends 1 row explaining the result for the requested table to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..Variable_existence_in_&inname where Variable_existence_in_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, variable name, result, reason

CHECK EXISTENCE:
If the pass keyword parameter contains Y (the default) then variables that are in the &indataset will receive a PASS and those
not in the dataset will receive a FAIL.

CHECK NONEXISTENCE:
If the pass keyword parameter contains N then variables that are in the &indataset will receive a FAIL and those
not in the dataset will receive a PASS.

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  1/2012

******************************* CESR_VLC_VarExist ***********************************
******************************* CESR_VLC_VarExist ***********************************;
%Macro CESR_VLC_VarExist(indataset = 								 
			 		    , vars = 
					    , Pass = Y	 /*Default=Y */ 
					    , outdataset =
                        );
%CESR_SymbolCheck;
%local inname c_area dsoutname j num_of_vars k memname message_N message_Y parser Vcounter num_of_vars found;

*establish macro variable values;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%if &content_area= %then %let c_area=&inname;
%else %let c_area=&content_area;
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Variable_Existence_in_&inname                         x,1,32); 
%else %let dsoutname=&outdataset;

%let pass=%upcase(&pass);

%if &pass = Y %then title5  "Test Existence of Variables in &indataset" ;
%else %if &pass = N %then title5  "Test Non-Existence of Variables in &indataset" ;
;
%let message_Y	= "Variable Exists";  
%let message_N	= "Variable Does Not Exist"; 

*parse variables and types;
%let vars=%upcase(&vars);
%let parser=1;
%let Vcounter=1;
%if &vars ne %then %do;*if variables entered when macro was invoked;
  %let found=%scan(&vars,&parser,%str( ));*find the first variable name;
  %do %while (&found ne );*as long as there is a value left to work with from the variables list stay in this loop;
    %if %index(_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,%substr(&found,1,1)) ne 0 %then %do; *a character or _ has been found;
      %local var&Vcounter ;*add var1, var2,... to local symbol table;
      %let %trim(var%left(&Vcounter))=&found; *the variable name will be stored in var1, var2,...;
      %let Vcounter=%eval(&Vcounter+1); *increment the variable counter;
    %end;
    %let parser=%eval(&parser+1); *point to the next piece of infomation in the list of variables and lengths;
    %let found=%scan(&vars,&parser,%str( )); *find the next piece of information when parsing variables and types;
  %end;*while;
  %let num_of_vars=%eval(&Vcounter-1);
%end;*if do;

*When checking for existence this defines global macro variables for all variables checked;
/*%IF &pass = Y %THEN %DO;*/
/*  %DO k = 1 %TO &num_of_vars;*/
/*	%global  CESR_&&var&k ;	*/
/*  %END;*/
/*  %global CESR_num_of_vars;*/
/*  %let CESR_num_of_vars=&num_of_vars;*/
/*%END;*/

proc contents data=&indataset noprint out=table_vars(keep=name memname);
   run;

*This will output a single row dataset with all the variables filled in if the
   variable exists and empty if it does not exist;
data table_VARS_FLAGS;
   set table_vars end=eof;
   by memname;
   %DO k = 1 %TO &num_of_vars;
		length  &&var&k $32.;
   		retain 	&&var&k;
	%END;

   if _n_=1 then do;
   		%DO k = 1 %TO &num_of_vars;
			&&var&k = ' ';
		%END;
   end;  

	%DO k = 1 %TO &num_of_vars;
		if upcase(name) = upcase("&&var&k") then  &&var&k = upcase("&&var&k");
	%END;

   if eof then do;
/*  	%IF &pass = Y %THEN %DO;*/
/*	%DO k = 1 %TO &num_of_vars;*/
/*		call symput("CESR_&&var&k..",&&var&k);*/
/*	%END;*/
/*	%END;*/
		call symput("memname", memname);
   end;
  	
   if last.memname then output;
run;

PROC TRANSPOSE DATA = table_VARS_FLAGS (drop = name) 
		out = table_vars_list (rename = (_name_ = varname));
	var     %DO k = 1 %TO &num_of_vars;
				&&var&k
			%END;;
run;


data &dsoutname  (drop = col1 label="Variable Existence");
  length Site $4. MEMNAME $32. varname $32. 
		   Result $8. 	Reason $256. ;
	set table_vars_list;
	/*N = 'N';
	Y = 'Y';*/
	if upcase(varname) = col1 then do;
		if "&pass" = "N" then Result = 'FAIL';
		if "&pass" = "Y" then Result = 'PASS';
		Reason =  &message_Y;
	end;
	
	if upcase(varname) ne col1 then do;
		if "&pass" = "N" then Result = 'PASS';
		if "&pass" = "Y" then Result = 'FAIL';
		Reason =  &message_N;
	end;

	memname = "&memname.";
	Site="&_SiteAbbr.";
	label varname = 'Variable Name' memname = 'Table Name' Result = 'Results' Reason = 'Reason' Site='Site';
run;

ods proclabel="Variable Existence in &inname.";
proc print data = &dsoutname  noobs label;
	var Site memname varname Result Reason;
run;

data check_data ;
  length Site $4. MemName $32. VarName $32.
         Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
  set &dsoutname;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
    check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
    dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
    OutDataSet = 'Data Set Containing Check Specifics';
    check_description="Existence of Variable"; 
    content_area="&content_area"; 
    dateran=datetime();
    version="&version";
    check=compress("&c_area._"||varname||'_'||"existence"||'_'||"Descriptive",' ');
    outdataset="&dsoutname";
    format dateran datetime.;
run;

%CESR_AppendDS(indataset=check_data);

proc datasets nolist;
  delete  table_VARS_FLAGS table_vars table_vars_list check_data  ;
  run;
quit;

title5;
footnote4;

%MEND CESR_VLC_VarExist;



******************************* CESR_VLC_VarNotExist ***********************************
******************************* CESR_VLC_VarNotExist ***********************************

CESR_VLC_VarNotExist:

This macro checks for NONEXISTENCE of one or more variables.
The variables that are in the &indataset will receive a FAIL and those not in the dataset will receive a PASS.
This macro performs a data check that verifies obsolete variables are no longer present.  The 
nonexistence of any number of variables in a single data set can be tested.  

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each data set variable checked 
       Columns in Report are: site, data set name, variable name, result and reason.

2. Appends 1 row explaining the result for the requested table to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAed, type, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..Variable_NonExistence_in_&inname where Variable_nonexistence_in_&inname is truncated at 32 characters.
       inname is the data set name without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, variable name, result, reason

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  1/2012

******************************* CESR_VLC_VarNotExist ***********************************
******************************* CESR_VLC_VarNotExist ***********************************;

%Macro CESR_VLC_VarNotExist(indataset = 								 
			 		    , vars = 
					    , outdataset =
                        );
%if &outdataset= %then %do;
  %local inname;
  %let indataset=%upcase(&indataset);
  %if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
  %else %let inname=&indataset;
  *trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
  %if &outdataset= %then %let outdataset=&QAoutlib..%substr(Variable_NonExistence_in_&inname                         x,1,32); 
%end; 
%CESR_VLC_VarExist(indataset = &indataset								 
                    ,vars=&vars
					, Pass = N	 
					, outdataset = &outdataset
					);

%mend CESR_VLC_VarNotExist;
******************************* CESR_VLC_VarNotExist ***********************************
******************************* CESR_VLC_VarNotExist ***********************************;


****************************** CESR_VLC_Linkage_SV **********************************
****************************** CESR_VLC_Linkage_SV **********************************

CESR_VLC_Linkage_SV:

This Macro produces counts of records and, optionally, distinct values of a specified linking variable that can be 
linked to a values of a target variable (in the same or a different dataset).
Percentages are calculated and compared to the fail and warn cutoff points that the user
supplies.  Then values less than &lowest_count are set to 0 and percentages are recalculated.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for linked and one row for unlinked counts and percentages, unless the count in the
			dataset is 0. 
       Columns in Report are: data set name, variable name, frequency and percent with counts
       less than &lowest_count hidden and percents adjusted accordingly.

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..&content_area._&linkingvar._&linkname._link where &content_area._&linkingvar._&linkname._link is truncated at 32 characters.
       &linkname is either named by the user or called to_&targetfile, where &targetfile is the name of the dataset to which the
	   linking variable (&linkingvar) is linked without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site memname varnmae status count percent warn_at fail_at result

4. Can create 1 dataset that is named &unlinkeddataset, if the parameter unlinkeddataset is set during the macro call. If no name is supplied,
	   the dataset will not be created.

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:
	a) supply the name of a SAS table to check.  The table can be permanent with two level name or temporary with single
       level name.
	b) supply the name of the linking variable (aka foreign key) whose presence in the target data set/variable is to be 
	  checked
	c) supply the name of the dataset to which the linking variable is to be linked
	d) if different from the linking variable, supply the name of the variable to which the linking variable is to be linked
	e) indicate whether the target variable in the target datasets needs to be deduplicated (i.e. if the target variable is not already unique in the target dataset),
		default is N
	f) indicate whether to also compute results for distinct values of the linking variable (i.e. regardless how often a value occurs), default is N
	   The default is Y (distinct values).
	g) optionally, supply the fail cutoff point (% of unlinked values).  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
	h) optionally, supply the warn cutoff point (% of unlinked values).  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
	i) supply the name of the dataset to contain the check results
	j) optionally, supply the name of the dataset that will contain all unlinked values of the linking variable
	k) optionally, supply a phrase to be inserted into the check name (and the output dataset name if &OutDataSet is not specified)
	j) optionally, if the indataset contains pre-summarized data (i.e. one record per linkingvariable with the asssociated count/frequency),
					supply the name of the variable containing the frequency counts of the linking variable

Note that if neither fail nor warn cutoff points are set, the macro will produce a descriptive report without pass/warn/fail message.
Results will be written to the DCO file with result="N/A"

Macro Call:
%CESR_VLC_Linkage_SV 	(InDataSet =, LinkingVar =, TargetDataSet =, TargetVar =, DedupeTarget = N, Distinct = N, 
						FailPercent =, WarnPercent =, OutDataSet =, UnlinkedDataSet =, LinkName =)

Example Calls:
%CESR_VLC_Linkage_SV (	InDataSet = &_vdw_px , 
					LinkingVar = performingprovider, 
					TargetDataSet = &_vdw_provider_specialty, TargetVar = provider, 
					DedupeTarget = N, Distinct = Y,
					FailPercent = 5, WarnPercent = 0, 
					OutDataSet = px_performingprov_to_prov, 
					UnlinkedDataSet = outlocal.px_unlinked_prov,
					LinkName = to_prov
					)

%CESR_VLC_Linkage_SV (	InDataSet = vdw_everndc , 
					LinkingVar = ndc, 
					TargetDataSet =&_vdw_rx, 
					DedupeTarget = Y, 
					OutDataSet =everndc_ndc_link_to_rx, 
					LinkName = to_rx,
					WeightVar = freq
					)

Contact Information: CESR Research Network Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny.Staab@kpchr.org		503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     
Authors:    CESR Research Network Consultants and CESR Analysts
Published:  02/2013
Modified:	7/19/2022   - Jenny Staab adopted Roy Pardee's modification:
										- added optional weightvar to use presummarized InDataSet where weightvar=number of occurrences of LinkingVar
			5/3/2017	- Jenny Staab	- corrected for errors introduced in previous modification
										- introduced deduping of target dataset option
										- made record count obligatory, simultaneous distinct value count optional
										- disallowed counting of missing values
			5/25/2016 	- Andy Karnopp 	- updated SQL syntax to improve performance
										- correction for missing=N when producing an unlinked dataset
			11/6/13		- Gwyn Saylor
;


****************************** CESR_VLC_Linkage_SV **********************************
****************************** CESR_VLC_Linkage_SV **********************************;
%macro CESR_VLC_Linkage_SV (
						InDataSet = ,			/*Dataset with Linking Variable*/
						LinkingVar = ,			/*Variable whose linkage to another dataset/variable is to be checked*/
						TargetDataSet = ,		/*Dataset in which linking variable is looked up*/
						TargetVar = ,			/*optional, will be set to Linkingvar if not assigned*/
						DedupeTarget = N,		/*Y/N: inidcate whether &targetdataset has to be deduped before being used as lookup table for &targetvar*/
						Distinct = N,			/*Y/N:, indicate whether to also produce statistics for distince values of &linkingvar.*/
						WarnPercent = ,			/* Enter 1 if the warn point is >1%.  Enter =1 if the warn point is >=1%.*/
						FailPercent = ,			/* Enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.*/
						OutDataSet = ,			/*Name of dataset with check results*/
						UnlinkedDataSet = ,		/*If desired, name of dataset containing unlinked values of the linking variable*/
						LinkName = 		,	  	/*optional, part of check name expressing what the linking variable is linked to, e.g. to_demog*/
						WeightVar = 1 			/* Optional var InDataSet which if present is used to weight the observations. Leave set to 1 if indataset is raw observations */
						);



	%CESR_SymbolCheck;

	%let linkingvar = %upcase (&linkingvar.);
	%if &targetvar = %then %let targetvar=&linkingvar ; *set targetvar to linkingvar if no targetvar given;
	%let targetvar = %upcase (&targetvar.);
	%let targetdataset=%upcase(&targetdataset);
	%let indataset=%upcase(&indataset);
	%let targetfile = %substr(&targetdataset , %eval(%index(&targetdataset., . )+1) ); *make short name for display purposes;
	data _NULL_;
		set sashelp.vmacro  ;
		where scope="GLOBAL" and (upcase(name) like '_VDW_%' or upcase(name) like '_CESR_%');
		if upcase(value) = "&targetdataset." then call symput('targetfile',substr(name,2));
	run;
	%let infile = %substr(&indataset , %eval(%index(&indataset., . )+1) ); *make short name for display purposes;
	
	%if &linkname = %then %let linkname = TO_&TARGETFILE ; *if no linkname given, create default;
	%if &outdataset= %then %let outdataset=&QAoutlib..%substr(&content_area._&linkingvar._&linkname._link                        x,1,32); *if no outdataset name given, craete default;

	%let title_7 = ;

	*assess which limits were set and set parameters accordingly;
	%let nlimits = 0;
	%if &failpercent ne %then %do;
		%let fail_at = >&failpercent.;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&failpercent;
	%end;
	%else %let fail_at = No Fail Limit Set.;
	%if &warnpercent ne %then %do;
		%let warn_at = >&warnpercent.;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&warnpercent;
	%end;
	%else %let warn_at = No Warn Limit Set.;

	*check whether everything needed exists;
	%let missingpiece = ;
	proc contents data=&indataset. out=invars (keep=name) noprint;
	run;
	data _null_;
		set invars end=eof;
		retain found 0;
		if upcase(name)="&linkingvar." then found=1;
		if eof and not found then call symput ('missingpiece',"Variable &linkingvar does not exist in &indataset.");
	run;
	proc delete data=invars; run;
	%if "&missingpiece." = "" %then %do;
		%if %sysfunc(exist(&targetdataset., data)) or %sysfunc(exist(&targetdataset., view)) %then %do;
			proc contents data=&targetdataset. out=targetvars (keep=name) noprint;
			run;
			data _null_;
				set targetvars end=eof;
				retain found 0;
				if upcase(name)="&targetvar." then found=1;
				if eof and not found then call symput('missingpiece',"Variable &targetvar does not exist in &targetdataset.");
			run;
			proc delete data=targetvars; run;
		%end;
		%else %let missingpiece = &targetdataset. does not exist.;
	%end;
	
*if a piece is missing;
%if "&missingpiece." ne "" %then %do;
	data linkds_ (drop= count percent)
		 linkds_clean (drop= raw_percent)
			;
		length method $20 linkage $10 count 8 percent 8 raw_percent 8;
		call missing(of _all_);
		output;
	run;
	%let unlinked = 0;
%end;
%else %do;
  *if all tables and variables exist;
	proc format;
		value hide 0='Hidden';
	run;
	proc sql noprint;
		create table linkds as
			select 
					sum(&weightvar.) as recs
					,sum (case
							when d2.&targetvar. is null then 0
							else &weightvar.
						 end) as linked_recs

				%if &Distinct. = Y %then %do;
					,count (distinct d1.&linkingvar.) as vals
					,count (distinct d2.&targetvar.) as linked_vals
				%end;
				%else %do;
					,. as vals
					,. as linked_vals
				%end;
	
			from &indataset. d1
		%if &dedupetarget. = Y %then %do;
			left join (select distinct &targetvar. from &targetdataset.) d2
		%end;
		%else %do;
			left join &targetdataset. d2
		%end;
				on d1.&linkingvar.=d2.&targetvar.
			where d1.&linkingvar. is not null
			;
	quit;

	*one record per count;
	data linkds (keep = method linkage freq count);
	length method $20 linkage $10;
		set linkds;
		Method = 'Records';
			if linked_recs then do;
				Linkage = 'Linked';
				freq = linked_recs;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
			unlinked_recs = recs - linked_recs;
			if unlinked_recs then do;
				Linkage = 'Unlinked';
				freq = unlinked_recs;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;

		if vals then do;
		Method = 'Distinct Values';
			if linked_vals then do;
				Linkage = 'Linked';
				freq = linked_vals;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
			unlinked_vals = vals - linked_vals;
			if unlinked_vals then do;
				Linkage = 'Unlinked';
				freq = unlinked_vals;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
		end;

		call symput('unlinked',put(min(1,unlinked_recs),1.0));
	run;
	*compute percentages;
	proc freq data=linkds noprint;
		where method='Records';
		by method notsorted;
		tables linkage / out = linkds_ (drop=count rename=(percent = raw_percent));
		weight freq / zero;
	run;	
	proc freq data=linkds noprint;
		by method notsorted;
		tables linkage / out = linkds_clean ;
		weight count / zero;
	run;
	proc sort data=linkds_;	
		by descending method descending linkage;
	proc sort data=linkds_clean;
		by descending method descending linkage;
	run;


	*create dataset with unlinked records if requested;
	%if "&unlinkeddataset." ne "" %then %do;
		%if &unlinked. %then %do; *if dataset of unlinked linkingvar values requested and unliked values present;
		proc sql;
			create table &unlinkeddataset 
				(label="This file contains all records from &infile. file where &linkingvar. cannot be linked to &targetvar. in the &targetfile. file.") as
				select d1.*
				from &indataset d1
				left outer join &targetdataset d2
					on d1.&linkingvar=d2.&targetvar
				where d2.&targetvar. is null and d1.&linkingvar. is not null
				;
		quit;
		%end;
		%else %do;
		data &unlinkeddataset;
			if 0 then set &indataset (keep = &linkingvar.);
			stop;
		run;
		%end;
	%end;
%end;


	data 
		&outdataset 
			(keep= site  memname  varname  status count  percent  warn_at fail_at result reason
			 label="Linkage of &linkingvar. to &targetfile.")
		dco_add 	
			(keep = Site  MemName  VarName Check_description  Result  Reason  DateRan  Version  Content_Area  Check  OutDataSet )
		;

		length Site $4. MemName $32 VarName $32 status $24 count 8 percent 8 warn_at $17 fail_at $17 result $8
				Check_description $256 Reason $256 DateRan 8 Version $4 Content_Area $8 Check $120 OutDataSet $ 41;
		
		merge linkds_ linkds_clean end=eof;
			by descending method descending linkage;

		site="&_siteabbr.";
		memname="&infile";
		varname="&linkingvar";
		Version="&version";
		content_area="&content_area";
		check="&content_area._&targetvar._&linkname._descriptive";
		Check_description="Percent of &linkingvar. that can be linked to &targetfile..";
		outdataset="&outdataset.";
		DateRan=datetime();

		if _n_=1 then do;
			call missing(result); call missing(reason);
			warn_at="&warn_at.";
			fail_at="&fail_at.";
			if missing(linkage) then do;
				result="FAIL";
				reason="&missingpiece.";
			end;
			else if linkage = 'Unlinked' then unlinkedpercent = raw_percent;
			else unlinkedpercent = 0;

			*compute result and reason if warn and/or fail percent set;
			if missing(result) then do;
			%if "&warnpercent." ne "" %then %do;
				if UnlinkedPercent > &warnpercent. then do;
					result="WARN";
					reason="Unlinked values of &linkingvar occur at a concerning rate (&warn_at.%).";
				end;
				else  do;
					result="PASS";
					reason="Unlinked values of &linkingvar occur at an acceptable rate (not &warn_at.%).";
				end;
			%end;
			%if "&failpercent." ne "" %then %do;
				if UnlinkedPercent > &failpercent. then do;
					result="FAIL";
					reason="Unlinked values of &linkingvar occur at too high a rate (&fail_at.%).";
				end;
				else if missing(result) then do;
					result="PASS";
					reason="Unlinked values of &linkingvar occur at an acceptable rate (not &fail_at.%).";
				end;
			%end;
			end;
			if missing(result) then do;
				result="N/A";
				reason="Unlinked values of &linkingvar occur at rate of "||compress(put(unlinkedpercent,8.4))||"%.";
			end;


			if result="N/A" then call symput ('title_7', trim(reason));
			else call symput ('title_7', trim(result)||': '||trim(reason));

			output dco_add;

		end;

		if missing(linkage) then do;
			call missing(count, percent, raw_percent);
			if index(reason,"&linkingvar.") then status='Linking variable missing';
			else if index(reason,"&targetvar.") then status='Target variable missing';
			else if index(reason,"&targetdataset.") then status='Target dataset missing';
		end;
		else status=catx(' ',linkage,method);
		output &outdataset.;

	         	label site = "Site" memname = "Table Name" varname = "Variable Name"
				check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	            dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed"
	            OutDataSet = 'Data Set Containing Check Specifics'
				Count="Count - Counts Less Than &lowest_count. Are Hidden"
				warn_at="Warning Issued if Unlinked Percent is"
				fail_at="Fail Issued if Unlinked Percent is"
				percent="Percent"
				status="Status"
				;
	run;
	%CESR_AppendDS (indataset=dco_add);

	title5 "Check: Percent of &infile. Where &linkingvar. Can Be Linked to &targetvar. in &targetfile..";
	title6 	"Missing values were not included in the analysis";
	title7 "&title_7";
	%if "&unlinkeddataset." ne "" and &unlinked. %then %do;
	title9 "Unlinked records of &infile. are saved in &unlinkeddataset..";
	%end;
	footnote4 "Hidden indicates a count less than &lowest_count..";
	footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
	footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
	ods proclabel="Linkage to &targetvar. in &targetfile.";
	data linkds_out;
		length statistic $16;
		set &outdataset end=eof;
		statistic = substr(status,index(status,' ')+1);
		status=scan(status,1);
	data linkds_out;
		set linkds_out;
		by statistic notsorted;
		if not first.statistic then call missing(statistic);
		label statistic='Statistic';
	run;
	proc print data=linkds_out label noobs;
		id statistic;
		format count percent hide.;
	run;
	title5;
	footnote4;

	*clean up;
	proc datasets library=work nolist;
		delete dco_add linkds:; run;
	quit;

%mend CESR_VLC_Linkage_SV;

****************************** CESR_VLC_Linkage_SV **********************************
****************************** CESR_VLC_Linkage_SV **********************************;

****************************** CESR_VLC_Linkage_MV **********************************
****************************** CESR_VLC_Linkage_MV **********************************

CESR_VLC_Linkage_MV:

This Macro produces counts of records and, optionally, distinct values of combinations of specified linking variables that can be 
linked to a values of a set of variables (in the same or a different dataset).
Percentages are calculated and compared to the fail and warn cutoff points that the user
supplies.  Then values less than &lowest_count are set to 0 and percentages are recalculated.

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for linked and one row for unlinked counts and percentages, unless the count in the
			dataset is 0. 
       Columns in Report are: data set name, variable name, frequency and percent with counts
       less than &lowest_count hidden and percents adjusted accordingly.

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset that is either named by the user with the optional parameter &outdataset or called 
       &QAoutlib..&content_area._&linkname._link where &content_area._&linkname._link is truncated at 32 characters.
       &linkname is either named by the user or called to_&targetfile, where &targetfile is the name of the dataset to which the
	   linking variable (&linkingvars) is linked without the libname in front.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &indataset and &outdataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site memname varnmae status count percent warn_at fail_at result

4. Can create 1 dataset that is named &unlinkeddataset, if the parameter unlinkeddataset is set during the macro call. If no name is supplied,
	   the dataset will not be created.

Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:
	a) supply the name of a SAS table to check.  The table can be permanent with two level name or temporary with single
       level name.
	b) supply the names of the linking variables (aka foreign key) whose presence in the target data set is to be 
	  checked
	c) supply the name of the dataset to which the linking variable is to be linked
	d) if different from the linking variables, supply the name of the variables to which the linking variables are to be linked
	e) indicate whether to also compute results for distinct values of the linking variable (i.e. regardless how often a value occurs), default is N
	   The default is Y (distinct values).
	f) optionally, supply the fail cutoff point (% of unlinked values).  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
	g) optionally, supply the warn cutoff point (% of unlinked values).  For example, enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.
	h) supply the name of the dataset to contain the check results
	i) optionally, supply the name of the dataset that will contain all unlinked values of the linking variable
	j) optionally, supply a phrase to be inserted into the check name (and the output dataset name if &OutDataSet is not specified)

Note that if neither fail nor warn cutoff points are set, the macro will produce a descriptive report without pass/warn/fail message.
Results will be written to the DCO file with result="N/A"

Macro Call:
%CESR_VLC_Linkage_MV 	(InDataSet =, LinkingVars =, TargetDataSet =, TargetVars =, Distinct = N, 
						FailPercent =, WarnPercent =, OutDataSet =, UnlinkedDataSet =, LinkName =)

Example Calls:
%CESR_VLC_Linkage_MV (	InDataSet = &_cesr_infusion_tx , LinkingVars = mrn tx_plan_id tx_day_id, 
					TargetDataSet = &_cesr_infusion_adminstrd., TargetVars = , 
					Distinct = Y,
					FailPercent = 5, WarnPercent = 0, 
					OutDataSet = inftx_infadm_link, 
					UnlinkedDataSet = outlocal.inftx_infadm_unlinked,
					LinkName = to_infadm
					)

Contact Information: CESR Research Network Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny.Staab@kpchr.org		503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     
Authors:    CESR Research Network Consultants and CESR Analysts
Published:  04/2019
Modified:	
;


****************************** CESR_VLC_Linkage_MV **********************************
****************************** CESR_VLC_Linkage_MV **********************************;
%macro CESR_VLC_Linkage_MV (
						InDataSet = ,			/*Dataset with Linking Variable*/
						LinkingVars = ,			/*Variables whose linkage to another dataset/variable is to be checked*/
						TargetDataSet = ,		/*Dataset in which linking variable is looked up*/
						TargetVars = ,			/*optional, will be set to Linkingvars if not assigned*/
						Distinct = N,			/*Y/N:, indicate whether to also produce statistics for distinct combinations of &linkingvars.*/
						WarnPercent = ,			/* Enter 1 if the warn point is >1%.  Enter =1 if the warn point is >=1%.*/
						FailPercent = ,			/* Enter 3 if the fail point is >3%.  Enter =3 if the fail point is >=3%.*/
						OutDataSet = ,			/*Name of dataset with check results*/
						UnlinkedDataSet = ,		/*If desired, name of dataset containing unlinked values of the linking variable*/
						LinkName = 			  	/*optional, part of check name expressing what the linking variable is linked to, e.g. to_demog*/
						);



	%CESR_SymbolCheck;

	%let linkingvars = %upcase (&linkingvars.);
	%if "&targetvars" = "" %then %let targetvars=&linkingvars ; *set targetvar to linkingvar if no targetvar given;
	%let targetvars = %upcase (&targetvars.);

	*number of variables;
	%let numvar = %sysfunc(countw(&linkingvars.));
	*capture variables into separate ones;
	%do i=1 %to &numvar.;
		%let lvar&i = %scan(&linkingvars., &i);
		%let tvar&i = %scan(&targetvars., &i);
	%end;


	%let targetdataset=%upcase(&targetdataset);
	%let indataset=%upcase(&indataset);
	%let targetfile = %substr(&targetdataset , %eval(%index(&targetdataset., . )+1) ); *make short name for display purposes;
	data _NULL_;
		set sashelp.vmacro  ;
		where scope="GLOBAL" and (upcase(name) like '_VDW_%' or upcase(name) like '_CESR_%');
		if upcase(value) = "&targetdataset." then call symput('targetfile',substr(name,2));
	run;
	%let infile = %substr(&indataset , %eval(%index(&indataset., . )+1) ); *make short name for display purposes;
	
	%if &linkname = %then %let linkname = TO_&TARGETFILE ; *if no linkname given, create default;
	%if &outdataset= %then %let outdataset=&QAoutlib..%substr(&content_area._&linkname._link                        x,1,32); *if no outdataset name given, craete default;

	%let title_7 = ;

	*assess which limits were set and set parameters accordingly;
	%let nlimits = 0;
	%if &failpercent ne %then %do;
		%let fail_at = >&failpercent.;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&failpercent;
	%end;
	%else %let fail_at = No Fail Limit Set.;
	%if &warnpercent ne %then %do;
		%let warn_at = >&warnpercent.;
		%let nlimits=%eval(&nlimits.+1);
		%let highpercent=&warnpercent;
	%end;
	%else %let warn_at = No Warn Limit Set.;


	*check whether everything needed exists;
	%let missingpiece = ;
	proc contents data=&indataset. out=invars (keep=name) noprint;
	run;
	data _null_;
		set invars end=eof;
		retain matches 0;
		if upcase(name) in (
			"&lvar1."
			%do i=2 %to &numvar.;
			, "&&lvar&i."
			%end;
		) then matches + 1;
		if eof and  matches < &numvar then call symput('missingpiece',"At least one of the linking variables does not exist in &indataset.");
	run;
	proc delete data=invars; run;
	%if "&missingpiece." = "" %then %do;
		%if %sysfunc(exist(&targetdataset., data)) or %sysfunc(exist(&targetdataset., view)) %then %do;
			proc contents data=&targetdataset. out=targetvars (keep=name) noprint;
			run;
			data _null_;
				set targetvars end=eof;
				retain matches 0;
				if upcase(name) in (
					"&tvar1."
					%do i=2 %to &numvar.;
					, "&&tvar&i."
					%end;
				) then matches + 1;
				if eof and matches < &numvar. then call symput('missingpiece',"At least one of the target variables does not exist in &targetdataset.");
			run;
			proc delete data=targetvars; run;
		%end;
		%else %let missingpiece = &targetdataset. does not exist.;
	%end;
	
*if a piece is missing;
%if "&missingpiece." ne "" %then %do;
	data linkds_ (drop= count percent)
		 linkds_clean (drop= raw_percent)
			;
		length method $20 linkage $10 count 8 percent 8 raw_percent 8;
		call missing(of _all_);
		output;
	run;
	%let unlinked = 0;
%end;
%else %do;
  *if all tables and variables exist;
	proc format;
		value hide 0='Hidden';
	run;

	
proc sort data= &indataset. %if "&unlinkeddataset." =  "" %then %do;(keep = &linkingvars.) %end; out=lset;
	by &linkingvars.;
run;
proc sort data= &targetdataset. (keep = &targetvars.) out=tset 
	%if %sysfunc(compress(&linkingvars.)) ne %sysfunc(compress(&targetvars.)) %then %do;
	(rename=(
		%do i = 1 %to &numvar. ;
			%if &&tvar&i. ne &&lvar&i. %then %do;
			&&tvar&i. = &&lvar&i.
			%end;
		%end;
		))
	%end;
	nodupkey;
	by &targetvars.;
run;
data 
	linkds (keep = recs linked_recs vals linked_vals)
	%if "&unlinkeddataset." ne "" %then %do;
	&unlinkeddataset (drop=recs linked_recs vals linked_vals)
	%end;
	;
	merge lset (in=inset) tset (in=target) end=eof;
	by &linkingvars.;
	retain recs linked_recs vals linked_vals 0 ;
	
	if inset and not (
		missing(&lvar1.)
	%do i=2 %to &numvar.;
		and missing(&&lvar&i.) 
	%end;
		) then do;
			recs+1;
			if target then linked_recs+1;
				%if "&unlinkeddataset." ne "" %then %do;
				else output &unlinkeddataset.;
				%end;

			if last.&&lvar&numvar. then do;
				vals+1;
				if target then linked_vals+1;
			end;
	end;
	if eof then output linkds;
run;

	*one record per count;
	data linkds (keep = method linkage freq count);
	length method $20 linkage $10;
		set linkds;
		Method = 'Records';
			if linked_recs then do;
				Linkage = 'Linked';
				freq = linked_recs;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
			unlinked_recs = recs - linked_recs;
			if unlinked_recs then do;
				Linkage = 'Unlinked';
				freq = unlinked_recs;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
	%if &distinct. = Y %then %do;
/*		if vals then do;*/
		Method = 'Distinct Values';
			if linked_vals then do;
				Linkage = 'Linked';
				freq = linked_vals;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
			unlinked_vals = vals - linked_vals;
			if unlinked_vals then do;
				Linkage = 'Unlinked';
				freq = unlinked_vals;
				if freq < &lowest_count then count = 0;
				else count = freq;
				output;
			end;
/*		end;*/
	%end;

		call symput('unlinked',put(min(1,unlinked_recs),1.0));
	run;
	*compute percentages;
	proc freq data=linkds noprint;
		where method='Records';
		by method notsorted;
		tables linkage / out = linkds_ (drop=count rename=(percent = raw_percent));
		weight freq / zero;
	run;	
	proc freq data=linkds noprint;
		by method notsorted;
		tables linkage / out = linkds_clean ;
		weight count / zero;
	run;
	proc sort data=linkds_;	
		by descending method descending linkage;
	proc sort data=linkds_clean;
		by descending method descending linkage;
	run;


%end;


	data 
		&outdataset 
			(keep= site  memname  varname  status count  percent  warn_at fail_at result reason
			label="Linkage of &linkingvars. combinations to &targetfile.")
		dco_add 	
			(keep = Site  MemName  VarName Check_description  Result  Reason  DateRan  Version  Content_Area  Check  OutDataSet )
		;

		length Site $4. MemName $32 VarName $32 status $24 count 8 percent 8 warn_at $17 fail_at $17 result $8
				Check_description $256 Reason $256 DateRan 8 Version $4 Content_Area $8 Check $120 OutDataSet $ 41;
		
		merge linkds_ linkds_clean end=eof;
			by descending method descending linkage;

		site="&_siteabbr.";
		memname="&infile";
		varname="Composite Key";
		Version="&version";
		content_area="&content_area";
		check="&content_area._&linkname._descriptive";
		Check_description="Percent of records that can be linked to &targetfile. using composite key.";
		outdataset="&outdataset.";
		DateRan=datetime();

		if _n_=1 then do;
			call missing(result); call missing(reason);
			warn_at="&warn_at.";
			fail_at="&fail_at.";
			if missing(linkage) then do;
				result="FAIL";
				reason="&missingpiece.";
			end;
			else if linkage = 'Unlinked' then unlinkedpercent = raw_percent;
			else unlinkedpercent = 0;

			*compute result and reason if warn and/or fail percent set;
			if missing(result) then do;
			%if "&warnpercent." ne "" %then %do;
				if UnlinkedPercent > &warnpercent. then do;
					result="WARN";
					reason="Unlinked values occur at a concerning rate (&warn_at.%).";
				end;
				else  do;
					result="PASS";
					reason="Unlinked values occur at an acceptable rate (not &warn_at.%).";
				end;
			%end;
			%if "&failpercent." ne "" %then %do;
				if UnlinkedPercent > &failpercent. then do;
					result="FAIL";
					reason="Unlinked values occur at too high a rate (&fail_at.%).";
				end;
				else if missing(result) then do;
					result="PASS";
					reason="Unlinked values occur at an acceptable rate (not &fail_at.%).";
				end;
			%end;
			end;
			if missing(result) then do;
				result="N/A";
				reason="Unlinked values occur at rate of "||compress(put(unlinkedpercent,8.4))||"%.";
			end;


			if result="N/A" then call symput ('title_7', trim(reason));
			else call symput ('title_7', trim(result)||': '||trim(reason));

			output dco_add;

		end;

		if missing(linkage) then do;
			call missing(count, percent, raw_percent);
			if index(reason,"linking variables") then status='Linking variable missing';
			else if index(reason,"target variables") then status='Target variable missing';
			else if index(reason,"&targetdataset.") then status='Target dataset missing';
		end;
		else status=catx(' ',linkage,method);
		output &outdataset.;

	         	label site = "Site" memname = "Table Name" varname = "Variable Name"
				check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	            dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed"
	            OutDataSet = 'Data Set Containing Check Specifics'
				Count="Count - Counts Less Than &lowest_count. Are Hidden"
				warn_at="Warning Issued if Unlinked Percent is"
				fail_at="Fail Issued if Unlinked Percent is"
				percent="Percent"
				status="Status"
				;
	run;
	%CESR_AppendDS (indataset=dco_add);

	title5 "Check: Percent of &infile. That Can Be Linked to &targetfile..";
	title6 "&linkingvars. --> &targetvars.";
	title7 "&title_7";
	title8 	"Records where all variables of the composite key are missing are excluded.";
	%if "&unlinkeddataset." ne "" %then %do;
	title9 "Unlinked records of &infile. are saved in &unlinkeddataset..";
	%end;
	footnote4 "Hidden indicates a count less than &lowest_count..";
	footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
	footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
	ods proclabel="Linkage to &targetfile.";
	data linkds_out;
		length statistic $16;
		set &outdataset end=eof;
		statistic = substr(status,index(status,' ')+1);
		status=scan(status,1);
	data linkds_out;
		set linkds_out;
		by statistic notsorted;
		if not first.statistic then call missing(statistic);
		label statistic='Statistic';
	run;
	proc print data=linkds_out label noobs;
		id statistic;
		format count percent hide.;
	run;
	title5;
	footnote4;

	*clean up;
	proc datasets library=work nolist;
		delete tset lset dco_add linkds:; run ;
	quit;

%mend CESR_VLC_Linkage_MV;

****************************** CESR_VLC_Linkage_MV **********************************
****************************** CESR_VLC_Linkage_MV **********************************;

				

****************************** CESR_EXP_FREQUENCY **********************************
****************************** CESR_EXP_FREQUENCY **********************************

CESR_EXP_FREQUENCY:

This macro prints a frequency of a given variable with counts less than 6 hidden.    

This macro:
1. Prints 1 output report for the user to review.
       Report contains
         -  one row for each distinct value of variable or for each distinct formatted value of 
            variable depending on if the user supplies a value for the VarFormat parameter.
       Columns in Report are: data set name, variable name, frequency and percent with counts
       less than &lowest_count hidden and percents adjusted accordingly.

2. Creates 1 dataset either named by the user or called &QAoutlib..Freq_of_Var_&variable_in_&indataset.
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       &variable and &indataset receive their values from the user as parameter values when this macro is invoked.
       Columns in table are: site, data set name, variable name, frequency and percent

Note that this macro does NOT write to the DCO_file.


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

    a) supply the name of a SAS table to check.  The table can be permanente with two level name or temporary with single
       level name.
    b) supply the variable contained in the SAS table to be checked.
    c) optionally supply a format by which to group the counts.
    d) assign Y to the parameter 'missing' if you want to include records with missing values in the counts.  Otherwise
       leave blank and missing records will be ignored by default.

Macro Call:
%CESR_EXP_FREQUENCY(indataset= , variable= , VarFormat= , missing= , outdataset)

Example Calls:
%CESR_EXP_FREQUENCY(indatasets=VDW.PHARMACY , variable=ndc, outdataset=mylib.exp_freq_ndc_results)

Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     Karen.Riedlinger@kpchr.org 503-335-2464
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  01/2012

****************************** CESR_EXP_FREQUENCY **********************************
****************************** CESR_EXP_FREQUENCY **********************************;


%Macro CESR_EXP_FREQUENCY(indataset =
					     ,variable  =
					     ,VarFormat =	/* The name of the format by which you would like to group the variable.  Include the dot.*/
 	  				     ,missing   =	/*If missings are to be counted type Y otherwise default is to ignore missings */
						 ,order     = internal
                         ,outdataset=  
					     );
%CESR_SymbolCheck;
%local miss inname;

*establish macro variable values.  this macro does not write to the DCO_files so content_area and is not needed;
%let indataset=%upcase(&indataset);
%if %index(&indataset,.)>0 %then %let inname=%substr(&indataset,%eval(%index(&indataset,.)+1));
%else %let inname=&indataset;
%let QAoutlib=%upcase(&QAoutlib);
%let variable=%upcase(&variable);
*trick - leave the blanks and the x in the following %substr so will not get THIRD ARGUMENT OUT OF RANGE message;
%if &outdataset= %then %let dsoutname=&QAoutlib..%substr(Freq_of_var_&variable._in_&inname                   x,1,32);
%else %let dsoutname=&outdataset;
%if %upcase(&missing) = Y %then %let miss = missing;
%else %let miss = ;

title5 "Distribution of Values of Variable &variable in Data Set &indataset";

proc format;
  value hide 0 = "    Hidden";
run;

proc means data=&indataset(keep=&variable) noprint;
  class &variable/&miss;
  format &variable &VarFormat; 
  output out=var_counts;
run;

data var_counts_clean(drop=_type_ );
  length Site $4;
  Site="&_siteabbr.";
  DataSet="&indataset";
  set var_counts (rename=(_freq_=count));
  if _type_=0 then delete;
  if count < &lowest_count then count = 0;
  label site="Site" 
        dataset="Table Name" 
        &variable="Variable &variable";
run;

*This uses proc freq to weight the counts which the format hides < &lowest_count;
proc freq data=var_counts_clean order=&order noprint;
  tables dataset*&variable/&miss out=hide_freq;
  weight count/zero;
  format count hide.;
run;

footnote4 "Hidden indicates a count less than &lowest_count.";
%if &miss=missing %then footnote5 "Missing values are counted in the frequencies.";
%else footnote5 "Missing values are NOT counted in the frequencies.";  ;

*This is the final print with < &lowest_count hidden; 
proc print data=hide_freq noobs label;
run;

data &dsoutname;
  length Site $4 ;
  retain Site "&_SiteAbbr.";
  set hide_freq (rename=(&variable.=oldvariable));
	%if &varformat ne %then %do;
	  &variable.=put(oldvariable,&varformat.);
	%end;
	%else %do;
	  &variable.=oldvariable;
	%end;
  format count;
  format &variable.;
  drop oldvariable;
run;

proc datasets nolist;
  delete var_counts var_counts_clean hide_freq;
run;
quit;

title5;
footnote4;

%Mend CESR_EXP_FREQUENCY;


****************************** CESR_EXP_CROSSTABS **********************************
****************************** CESR_EXP_CROSSTABS **********************************


CESR_EXP_CROSSTABS:

This macro prints the frequency of two variables with counts less than &lowest_count 
hidden and percents adjusted. Values may be grouped using formats (optional). 

This macro:
1. Prints 1 output report, with the layout defined by the user.
		Matrix layout (default)
			- best for small numbers of values in both variables
			- first variable in rows, second variable in columns
			- missing combinations may be hidden, as defined by the user
			- percents are by column
		Page layout
			- best for large numbers of values in one variable
			- first variable in first column, second variable in second column
			- separate table for each value of the first variable
			- missing combinations are not displayed
			- percents are by grand total
		List layout
			- best for large numbers of values in both variables
			- first variable in first column, second variable in second column
			- counts under a minimum amount may be hidden, as defined by the user 
			- missing combinations are not displayed
			- percents are by grand total
			
2. Creates 1 dataset either named by the user.

       Columns in table are: site, count, first variable name, second variable name
	   Percentages are not included in the dataset
	   Missing combinations may be included in the dataset, as defined by the user
	   Counts less &lowest_count are set to 0
	   Note that this macro does NOT write to the DCO_file.

To invoke the macro you must:

    a) supply the name of the input dataset
    b) supply the name of the output dataset
	c) supply the names of the first and second variables
    d) optionally supply formats for the first and second variables to group the counts
    e) optionally supply names for the first and second variables, or a report tile
	f) optionally supply a layout: matrix (default), page, or list
	g) optionally supply a limit for counts to display in the list
	h) optionally supply whether missing combinations are included in the dataset

Macro Call:
%CESR_EXP_CROSSTABS(
		intable=,
		outtable=,
		var1=,
		var2=,
		format1=, 
		format2=, 
		desc1=, 
		desc2=, 
		title4=,
		layout=,
		list_limit=,
		complete=
		
)

Example Calls:
%CESR_EXP_CROSSTABS(
		intable=VDW.UTILIZATION,
		outtable=mylib._chart_src_crstab,
		var1=ELECTRONIC_CHART_REVIEW,
		var2=SOURCE_DATA,
		complete=y
)


%CESR_EXP_CROSSTABS(
		intable=VDW.UTILIZATION,
		outtable=mylib._dept_department_crstab,
		var1=DEPT,
		var2=DEPARTMENT,
		format1=$deptdesc.,
		format2=$departmentdesc.,
		layout="list",
		list_limit=100
)

Authors:    CESR VDW Consultants and CESR Analysts
Published:  08/2016

****************************** CESR_EXP_CROSSTABS **********************************
****************************** CESR_EXP_CROSSTABS **********************************;


%macro CESR_EXP_CROSSTABS(
		intable=,
		outtable=,
		var1=,
		var2=,
		format1=, 
		format2=, 
		desc1=, 
		desc2=, 
		title4=,
		complete=,
		layout=,
		list_limit=
);

%let var1=%upcase(&var1);
%let var2=%upcase(&var2);

%if (&format1. =) or (&format2. =) %then %do;

	proc format;
	  value $dummy;
	  value dummy;
	run;

	data _null_;
	set &intable. (obs=1 keep=&var1. &var2.);
		vartype1= vtype(&var1.);
		vartype2= vtype(&var2.);
		call symput('vartype1',vartype1);
		call symput('vartype2',vartype2);
	run;

	%if &format1. = %then %do;
		%if (&vartype1. = C) %then 	%let format1=$dummy.;
		%else 						%let format1=dummy.;
	%end;

	%if &format2. = %then %do;
		%if (&vartype2. = C) %then 	%let format2=$dummy.;
		%else 						%let format2=dummy.;
	%end;

%end;

%if (&desc1. =) %then %let desc1=&var1.;
%if (&desc2. =) %then %let desc2=&var2.;

%if (&title4. =) %then %let title4="%sysfunc(dequote(&desc1.)) vs. %sysfunc(dequote(&desc2.))";

%let complete=%upcase(&complete);
%if &complete = Y %then %do; 
	%let option1 = completetypes; 
	%let option2 = preloadfmt; 
%end;
%else %do;
	%let option1 =; 
	%let option2 =; 
%end;

proc format;
  value hidecom 0="Hidden" other=[comma32.];
  picture mypct low-high='009%';
run;

proc means data=&intable. (keep = &var1. &var2.) nway noprint &option1.;
	class &var1. &var2. / missing &option2.;
	output out = test1;
	format &var1. &format1.;
	format &var2. &format2.;
run;

data &outtable. (keep=site &var1. &var2. count )
	test1 (keep=site var1 var2 count rename=(var1=&var1. var2=&var2. ));
	length site $ 4;
	set test1 (rename=(&var1.=var1 &var2.=var2 ));
	site =  "&_siteabbr.";
	count = _freq_ ;
	&var1. = put(var1,&format1.);
	&var2. = put(var2,&format2.);
	if count =0 then count = .;
	if count < &lowest_count. and count > 0 then count=0;
run;

title4 &title4.;
footnote3 "Counts less than &lowest_count. are set to 0, shown as 'Hidden', and percents recalculated.  '-' indicates an empty cell.";
footnote4 "Output saved to &outtable";

%if (&layout. =) %then %let layout="MATRIX"; %else %let layout=%sysfunc(upcase(&layout.));

%if (&list_limit. ne) and (&layout. ne "LIST") %then %do;

	%put NOTE: List limit specified for layout other than list. List limit will be ignored.;

%end;

%if (&layout. ="MATRIX") %then %do;

	ods proclabel="Crosstab of %sysfunc(dequote(&desc1.)) vs. %sysfunc(dequote(&desc2.))";
	proc tabulate data=&outtable. order=data;
		class site &var1. &var2. / missing;
		var count;
		table site = "Site", (&var1. =" " all="Total")*count=''*(sum=''*f=hidecom. colpctsum=''*f=mypct.), (&var2. =&desc2. all="Total")
							 / misstext='-' row = float box=&desc1.;
	run;

%end;

%else %if ((&layout. ="LIST") or (&layout.="PAGE")) %then %do;

	%if (&layout. ="LIST") %then %do;

		title5 "Counts less than &list_limit. are not shown.";

		%if ((&list_limit.=) or (&list_limit. <= 0)) %then %do;
			%if (&list_limit.=) 		%then	%put NOTE: List count not specified. All counts will be displayed.;
			%else %if (&list_limit.<0) 	%then	%put NOTE: List count less than zero. All counts will be displayed.;
			%else %if (&list_limit.=0) 	%then	%put NOTE: List count zero. All counts will be displayed.;
			%let list_limit = 0;
			title5 "All counts are shown.";
		%end;

	%end;

	proc format;
	  value hidecomdash 0="Hidden" .="-" other=[comma32.];
	run;

	proc sql noprint;
		create table test2 as 
		select *,sum(count) as groupcount, (count/sum(count))*100 as percent
		from &outtable. group by &var1.
		order by &var1., &var2.;
	quit;

	ods proclabel="Crosstab of %sysfunc(dequote(&desc1.)) vs. %sysfunc(dequote(&desc2.))";

	proc print data = test2 noobs label split='*';

		%if (&layout.="PAGE") %then %do;
		var &var1. &var2. count percent;
		by &var1.;
		label count ='Frequency' Percent = 'Percent*of Group';
		format count hidecomdash. percent mypct.;
		%end;

		%if (&layout. ="LIST") %then %do;
		var &var1. &var2. count;
		where count >= &list_limit.;	
		label count ="Frequency";
		format count hidecomdash.;
		%end;

	run;

	title5;
	proc delete data=test2;
	quit;
%end;

%else %do;

	%put ERROR: Layout &layout. not recognized. Must be MATRIX (default), LIST, or PAGE.;

%end;

proc delete data=test1; quit;
title4;
footnote3;footnote4;

%mend CESR_EXP_CROSSTABS;



****************************** CESR_VLC_MULTICHECK ***************************
****************************** CESR_VLC_MULTICHECK ***************************
CESR_VLC_MULTICHECK:

This macro performs a number of data checks on one or more variables in the same dataset. Three types of checks can be 
performed: Missingness, Expected and Unexpected Values, Exploratory Frequencies.

Note:
Only up to one missingness, one category, and one frequency check can be performed per variable.


This macro:
1. Prints 1 output report per check

	Columns in Report are dependent on the type of check
	Missingness: 	data set name, variable name, frequency and percent with counts
       				less than &lowest_count hidden and percents adjusted accordingly, 
					warn and fail criterion, result
	Expected/Unexpected: data set name, categorized variable values, frequency and 
					percent with counts less than &lowest_count hidden and percents 
					adjusted accordingly, warn and fail criterion, result
	Frequency:
	

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset named by the user 
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       Columns in table are: 	Site, Content Area Being QAed, Table Name, Variable Name, Reference Dataset, 
								Reference Variable, Check Type (Type vs Length), Found, Reference, Result, Reason


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.



Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny Staab				503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  10/2018
****************************** CESR_VLC_MULTICHECK ***************************
****************************** CESR_VLC_MULTICHECK ***************************;

%macro CESR_VLC_MULTICHECK (indataset=, parameters=);

%cesr_symbolcheck;

*preliminaries;
%let inname=%substr(%upcase(&indataset),%eval(%index(&indataset,.)+1));
proc format;
  value hide 
   0 = "    Hidden";
  value $mmiss 	"."," "," .","  .","   .","    .","     .","      .","       .","        .",
				"         .","          .","           ."="Missing"
                 other="Non-Missing";

  value mmiss        .="Missing"
                 other="Non-Missing";
run; 



*get content of indataset;
proc contents data=&indataset. noprint out=dscontents (keep=name type length);
run;
data dscontents;
	set dscontents;
	name=upcase(name);
run;
proc sort data=dscontents;
	by name;
run;

*read in parameters and capture in macro variables;
data 
	cat (rename= (warnpercent=warnpercent_c failpercent=failpercent_c outdataset=outdataset_c checkorder=checkorder_c label=label_c title5=title5_c format=format_c))
	fre (drop = warnpercent failpercent rename= (outdataset=outdataset_f checkorder=checkorder_f label=label_f title5=title5_f format=format_f))
	mis	(drop= missing format ndisplay rename = (warnpercent=warnpercent_m failpercent=failpercent_m outdataset=outdataset_m checkorder=checkorder_m label=label_m title5=title5_m))
	;
	set &parameters end=eof;
	checkorder=_n_;
	name=upcase(variable);
	e=1;
	m=0;
		do until (m=0);
			m=find(name,'&',e);
			if m then do;
				e=find(name,'.',m+1);
				mvar=substr(name,m+1,e-m-1);
				mvar_res=symget(mvar);
				name=tranwrd(name,cats('&',mvar,'.'),compress(mvar_res));
			end;
		end;
	check=left(upcase(check));
	if check='CATEGORY' then output cat;
	else if check='MISSING' then output mis;
	else if check='FREQUENCY' then output fre;
	if eof then call symput ('total_checks',compress(put(checkorder,best12.)));
	drop check variable e m mvar:;
	*rename variable=name;
run;
proc sort data=cat;
	by name;
run;
proc sort data=mis;
	by name;
run;
proc sort data=fre;
	by name;
run;

data _null_;
	merge cat (in=incat) mis (in=inmis) fre (in=infre) dscontents (in=inds) end=eof;
	by name;
	retain total_vars 0;
	
	*all variables to be used in proc summary;
	if (incat or inmis or infre) and inds then do;
		total_vars+1;
		call symput (compress('total_var'||put(total_vars,best12.)),compress(name));
	end;

	*all requested category check variables;
	if incat then do;
			call symput (compress('chk'||put(checkorder_c,best12.)),'cat');
			call symput (compress('var'||put(checkorder_c,best12.)),compress(name));
			call symput (compress('mis'||put(checkorder_c,best12.)),missing);
			call symput (compress('formt'||put(checkorder_c,best12.)),compress(format_c));
			call symput (compress('warn'||put(checkorder_c,best12.)),compress(warnpercent_c));
			call symput (compress('fail'||put(checkorder_c,best12.)),compress(failpercent_c));
			call symput (compress('outds'||put(checkorder_c,best12.)),compress(outdataset_c));
			call symput (compress('label'||put(checkorder_c,best12.)),strip(label_c));
			call symput (compress('titl'||put(checkorder_c,best12.)),strip(title5_c));
		if inds then do; 
			call symput (compress('typ'||put(checkorder_c,best12.)),put(type,1.0));
			call symput (compress('len'||put(checkorder_c,best12.)),compress(put(length,best12.)));
			call symput (compress('ndis'||put(checkorder_c,best12.)),compress(ndisplay));
			call symput (compress('inds'||put(checkorder_c,best12.)),'1');
			call symput (compress('pos'||put(checkorder_c,best12.)),compress(put(total_vars,best12.))); *position in variable list of proc summary;
		end;
		else call symput (compress('inds'||put(checkorder_c,best12.)),'0');
	end;

	if infre then do;
			call symput (compress('chk'||put(checkorder_f,best12.)),'fre');
			call symput (compress('var'||put(checkorder_f,best12.)),compress(name));
			call symput (compress('mis'||put(checkorder_f,best12.)),missing);
			call symput (compress('formt'||put(checkorder_f,best12.)),compress(format_f));
			call symput (compress('outds'||put(checkorder_f,best12.)),compress(outdataset_f));
			if incat then call symput (compress('cat'||put(checkorder_f,best12.)),'1'); *category check for same variable?;
				else call symput (compress('cat'||put(checkorder_f,best12.)),'0');
			call symput (compress('label'||put(checkorder_f,best12.)),strip(label_f));
			call symput (compress('titl'||put(checkorder_f,best12.)),strip(title5_f));
		if inds then do; 
			call symput (compress('typ'||put(checkorder_f,best12.)),put(type,1.0));
			call symput (compress('len'||put(checkorder_f,best12.)),compress(put(length,best12.)));
			call symput (compress('ndis'||put(checkorder_f,best12.)),compress(ndisplay));
			call symput (compress('inds'||put(checkorder_f,best12.)),'1');
			call symput (compress('pos'||put(checkorder_f,best12.)),compress(put(total_vars,best12.))); *position in variable list of proc summary;
		end;
		else call symput (compress('inds'||put(checkorder_f,best12.)),'0');
	end;

	if inmis then do;
			call symput (compress('chk'||put(checkorder_m,best12.)),'mis');
			call symput (compress('var'||put(checkorder_m,best12.)),compress(name));
			call symput (compress('warn'||put(checkorder_m,best12.)),compress(warnpercent_m));
			call symput (compress('fail'||put(checkorder_m,best12.)),compress(failpercent_m));
			call symput (compress('outds'||put(checkorder_m,best12.)),compress(outdataset_m));
			if incat then call symput (compress('cat'||put(checkorder_m,best12.)),'1'); *category check for same variable?;
				else call symput (compress('cat'||put(checkorder_m,best12.)),'0');
			call symput (compress('label'||put(checkorder_m,best12.)),strip(label_m));
			call symput (compress('titl'||put(checkorder_m,best12.)),strip(title5_m));
			if type=1 then call symput (compress('formt'||put(checkorder_m,best12.)),'mmiss.');
				else call symput (compress('formt'||put(checkorder_m,best12.)),'$mmiss.');
		if inds then do; 
			call symput (compress('typ'||put(checkorder_m,best12.)),put(type,1.0));
			call symput (compress('inds'||put(checkorder_m,best12.)),'1');
			call symput (compress('pos'||put(checkorder_m,best12.)),compress(put(total_vars,best12.))); *position in variable list of proc summary;
		end;
		else call symput (compress('inds'||put(checkorder_m,best12.)),'0');
	end;

*capture number of variables to be used in proc summary;
	if eof then call symput ('total_vars',compress(put(total_vars,best12.)));

run;

*run proc summary to get all necessary frequencies;
*miss format for variables that are in dataset only part of missingness check;
%if &total_vars. %then %do;
proc summary data=&indataset.(keep= %do i=1 %to &total_vars.; &&total_var&i. %end; ) chartype;
	class %do i=1 %to &total_vars.; &&total_var&i. %end; /missing;
	ways 1;
	output out=miscat ;
	%do i=1 %to &total_checks; 
		%if (&&chk&i.=mis or &&chk&i.=fre) and &&inds&i. and "&&formt&i." ne "" %then %do; 
			%if not &&cat&i. %then %do; 
			format &&var&i. &&formt&i. ;
			%end;
		%end; 
	%end;	
 run;
 %end;

*missingness checks: variables not in indataset;
%macro missing_notinds (j);
 data 
	dco_feed (keep=site memname varname check_description result reason dateran version content_area check outdataset )
	&&outds&j. (keep= site memname var: status count percent warn_at fail_at result reason 
						rename=(varname=variable)
						label=
						%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Missingness of &&var&j." %end;
						)
	;
    length Site $4. MemName $32. VarName $32. status $14. count 8 percent 8 warn_at $17 fail_at $17 result $8
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41
		  ;

	    memname = "&inname";  
	    varname = "&&var&j.";
	    site="&_siteabbr";
	    check_description="Missing and Non-missing Rates"; 
	    content_area="&content_area"; 
	    dateran=datetime();
	    version="&version";
	    check=compress("&content_area._"||varname||'_'||"missing"||'_'||"Descriptive",' ');
	    outdataset=substr(upcase("&&outds&j."),index("&&outds&j.",'.')+1);
	    Reason = "Requested variable &&var&j. does not exist in data set";
		Result=
		%if "&&fail&j." = "" and "&&warn&j." = "" %then %do;
			"N/A";
		%end;   	
		%else %do; 
			"FAIL";
		%end; 
 
		format dateran datetime.;
		count=.;
		percent=.;
		warn_at=
			%if &&warn&j. ne %then %do;
				compress(">"||"&&warn&j."); 
			%end;
			%else %do;
				"No Warn Limit Set";
			%end;
		fail_at=
			%if &&fail&j. ne %then %do;
				compress(">"||"&&fail&j."); 
			%end;
			%else %do;
				"No Fail Limit Set";
			%end;		

		Status="Not in dataset";

	  label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics' 		  
	  status="Variable Value Status"
      count="Count - Counts Less Than &lowest_count are Hidden"
      percent="Percents are Recalculated if Counts are Hidden"
      warn_at="Warning Issued If Missing Percent Is"
      fail_at="Fail Issued If Missing Percent Is"
	;

	ods proclabel =		%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Missingness of &&var&j." %end;
	;
	  title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		"Check: Rate of Occurrence of Missing Values for Variable &&var&j. in Table %upcase(&indataset.)"
	  %end;
	  ;
	  title7 "Attention: Requested variable, &&var&j., does not exist in the data set %upcase(&indataset.).";
	  proc print data=dco_feed label noobs;
    	var site memname varname result reason;
run;

	%CESR_AppendDS(indataset=dco_feed);
	  proc datasets lib=work nolist;
		delete dco_feed; run;
	  quit;

%mend  missing_notinds ;


*missingness checks, variables actually exist in dataset;
%macro missing_inds (j);
*get data from proc summary output;
	data miss;
		set miscat (rename=(&&var&j. = var));
		where substr(_type_,&&pos&j.,1)='1';
		Status = put (var,&&formt&j.);
		keep Status _type_ _freq_;
	run;

	proc summary data=miss ;
		class Status / missing ;
		var _freq_;
		output out=miss sum(_freq_)=count;
	run;
  
*suppress low counts if necessary;
  %let lowcountsup&j.=0;
  data raw;
    length Site $4;
    retain site "&_SiteAbbr." grandtotal .;
    set miss;
		if _type_=0 then do;
			grandtotal=count; 
			delete;
		end;
		else do;
	   	 	origpercent=(count/grandtotal)*100;
			if count < &lowest_count. then do;
				count=0;
				call symput("lowcountsup&j.",'1');
			end;
		end;
  run;

 *recompute percentages;
  proc freq data=raw noprint;
  	tables status / out=clean (keep=status percent);
	weight count / zero;
  run;

  proc sort data=raw; by status; run;
  proc sort data=clean; by status; run;

  proc sql noprint;
  	select count(*) into: n_obs from raw;
  quit;

*create output datasets: final numbers from recomputed (clean) DS, result from original (raw) DS;
 data 
	dco_feed (keep=site memname varname check_description result reason dateran version content_area check outdataset )
	&&outds&j. (keep= site memname var: status count percent warn_at fail_at result reason 
					rename=(varname=variable)
						label=
						%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Missingness of &&var&j." %end;
					)
	;
    length Site $4. MemName $32. VarName $32. status $11. count 8 percent 8 warn_at $17 fail_at $17 result $8
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41
		   displaypercent $30.;

    memname = "&inname";
    varname = "&&var&i";
    site="&_siteabbr";
    check_description="Missing and Non-missing Rates"; 
    content_area="&content_area"; 
    dateran=datetime();
    version="&version";
    check=compress("&content_area._"||varname||'_'||"missing"||'_'||"Descriptive",' ');
	outdataset=substr(upcase("&&outds&j."),index("&&outds&j.",'.')+1);

	%if &n_obs > 0 %then %do;
	merge raw clean; by status;
	retain lowcount 0 displaypercent '';
	if _n_=1 then do;
		warn_at=
			%if &&warn&j. ne %then %do;
				compress(">"||"&&warn&j."); 
			%end;
			%else %do;
				"No Warn Limit Set";
			%end;
		fail_at=
			%if &&fail&j. ne %then %do;
				compress(">"||"&&fail&j."); 
			%end;
			%else %do;
				"No Fail Limit Set";
			%end;
		%if "&&fail&j." ne  "" or  "&&warn&j." ne  "" %then %do;
			if status="Missing" then comparepercent=origpercent;
			else comparepercent = 0;
			%if &&fail&j. ne %then %do;
				if comparepercent > &&fail&j. then do;
					result="FAIL";
					reason="Missing values of &&var&j. occur at too high a rate (>&&fail&j.%).";
				end;
				%if &&warn&j. ne %then %do;
					else if comparepercent > &&warn&j. then do;
						result="WARN";
						reason="Missing values of &&var&j. occur at a concerning rate (>&&warn&j.%, but not >&&fail&j.%).";
					end;
				%end;
			%end;
			%else %do;
				if comparepercent > &&warn&j. then do;
					result="WARN";
					reason="Missing values of &&var&j. occur at a concerning rate (>&&warn&j.%).";
				end;
			%end;
				else  do;
					result="PASS";
					%if &&warn&j. ne %then %do;
					reason="Missing values of &&var&j. occur at an acceptable rate (not >&&warn&j.%).";
					%end;
					%else %do;
					reason="Missing values of &&var&j. occur at an acceptable rate (not >&&fail&j.%).";
					%end;
				end;
			call symput ('title_7', trim(result)||': '||trim(reason));
		%end;
		%else %do;
			if status="Missing" then do;
				if origpercent=100 then displaypercent=compress(put(100,8.4))||'%';
				else if not &&lowcountsup&j. then displaypercent=compress(put(percent,8.4))||'%';
				else if percent=0 then displaypercent='>0.0000%, but <'||compress(put(100*&lowest_count./max(grandtotal,&lowest_count.),8.4))||'%';
				else displaypercent='>'||compress(put(100*(max(grandtotal,&lowest_count.)-&lowest_count.)/max(grandtotal,&lowest_count.),8.4))||'%, but <100.0000%';
			end;
			else displaypercent='0.0000%';

			result="N/A";
			reason="Missing values of &&var&j. occur at rate of "||trim(displaypercent)||".";
			call symput ('title_7', trim(reason));
		%end;

		output dco_feed;
		output &&outds&j.;
	end;

	else do;
		output &&outds&j.;
	end;
	%end;

	%else %do; *if not observations in dataset;
	warn_at=
			%if &&warn&j. ne %then %do;
				compress(">"||"&&warn&j."); 
			%end;
			%else %do;
				"No Warn Limit Set";
			%end;
	fail_at=
			%if &&fail&j. ne %then %do;
				compress(">"||"&&fail&j."); 
			%end;
			%else %do;
				"No Fail Limit Set";
			%end;
	result=
		%if "&&fail&j." ne  "" or  "&&warn&j." ne  "" %then %do; 'PASS'; %end;
		%else %do; 'N/A'; %end;
	reason="There are not observations in dataset &inname..";
	call symput ('title_7', trim(reason));
	%end;

    format dateran datetime.;
    label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics' 		  
	  status="Variable Value Status"
      count="Count - Counts Less Than &lowest_count are Hidden"
      percent="Percents are Recalculated if Counts are Hidden"
      warn_at="Warning Issued If Missing Percent Is"
      fail_at="Fail Issued If Missing Percent Is"
	;
 run;

 *print to report;
	ods proclabel =		%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Missingness of &&var&j." %end;
	;	 title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		"Check: Rate of Occurrence of Missing Values for Variable &&var&j. in Table %upcase(&indataset.)"
	  %end;
	 ;
    title7 "&title_7.";
    footnote4 "Hidden indicates a count less than &lowest_count..";
    footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
    footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
  proc print data=&&outds&j. noobs label;
    var site memname variable status count percent warn_at fail_at result;
	format count percent hide.;
  run;

%CESR_AppendDS(indataset=dco_feed);

proc datasets lib=work nolist;
	delete miss raw clean dco_feed; run;
quit;

%mend missing_inds ;


*category check, variable not in input dataset;
%macro category_notinds (j);
 data 
	dco_feed (keep=site memname varname check_description result reason dateran version content_area check outdataset )
	&&outds&j. (keep= site memname var: var_desc count percent warn_at fail_at result reason 
						rename=(varname=variable)
						label=
						%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Expected and unexpected values of &&var&j." %end;
						)
	;
    length Site $4. MemName $32. VarName $32. status $14. count 8 percent 8 warn_at $17 fail_at $17 result $8
           Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41
		   displaypercent $30.;

	    memname = "&inname";  
	    varname = "&&var&j.";
	    site="&_siteabbr";
  		check_description="Expected and Unexpected Rates"; 
	    content_area="&content_area"; 
	    dateran=datetime();
	    version="&version";
	    check=compress("&content_area._"||varname||'_'||"category"||'_'||"Descriptive",' ');
	    outdataset=substr(upcase("&&outds&j."),index("&&outds&j.",'.')+1);
	    Reason = "Requested variable &&var&j. does not exist in data set";
		Result=
		%if "&&fail&j." = "" and "&&warn&j." = "" %then %do;
			"N/A";
		%end;   	
		%else %do; 
			"FAIL";
		%end; 
 
		format dateran datetime.;
		count=.;
		percent=.;
		warn_at=
			%if &&warn&j. ne %then %do;
				compress(">"||"&&warn&j."); 
			%end;
			%else %do;
				"No Warn Limit Set";
			%end;
		fail_at=
			%if &&fail&j. ne %then %do;
				compress(">"||"&&fail&j."); 
			%end;
			%else %do;
				"No Fail Limit Set";
			%end;		

		var_desc="Not in dataset";

	  label site = "Site" memname = "Table Name" varname = "Variable Name"
      check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
      dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
      OutDataSet = 'Data Set Containing Check Specifics' 		  
	  var_desc="Value of Variable &&var&j. Is Expected or Unexpected"
      count="Count - Counts Less Than &lowest_count are Hidden"
      percent="Percents are Recalculated if Counts are Hidden"
      warn_at="Warning Issued If Unexpected Percent Is"
      fail_at="Fail Issued If Unexpected Percent Is"
	;
run;	  

	ods proclabel = 	%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Expected and unexpected values of &&var&j." %end;
	;
	title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		  "Check: Rate of Occurrence of Unexpected Values for Variable &&var&j. in Table %upcase(&indataset.)";
	  %end;
	 ;

	  title7 "Attention: Requested variable, &&var&j., does not exist in the data set %upcase(&indataset.).";
	  proc print data=dco_feed label noobs;
    	var site memname varname result reason;
	  run;

	%CESR_AppendDS(indataset=dco_feed);
	  proc datasets lib=work nolist;
		delete dco_feed; run;
	  quit;

%mend category_notinds;

*category checks, variable in dataset to be checked;
%macro category_inds (j);

*get data from inital proc summary output;
*clean up low counts and compute percentages - for outdataset; 
data cat_clean;
	set miscat;
	where substr(_type_,&&pos&j.,1)='1' 
	%if &&mis&j.=N %then %do; and not missing(&&var&j.) %end;
	;
	if _freq_ < &lowest_count. then count=0;
	else count=_freq_;
	keep &&var&j. count;
run;
proc freq data=cat_clean noprint;
	tables &&var&j. / %if &&mis&j.=Y %then %do; missing %end;
	out=cat_clean;
	weight count / zero;
run;

proc sql noprint;
	select count(*) into: n_obs from cat_clean;
quit;

*if there are any data to process;
%if &n_obs > 0 %then %do;
*else if no warn/fail: compute unexpected percentage from sum of low-count-suppressed % of all unexpected values and create reason variable;
%if "&&warn&j." = "" and "&&fail&j."="" %then %do;
	%let result=N/A;
	data _null_;
		set cat_clean end=eof;
		retain percentU 0 suppressed 0;
		if upcase(put(&&var&j.,&&formt&j. ))=:'UNEXPECT' then do;
			percentU+percent;
			if count=0 then suppressed=1;
		end;
		if eof then do;
			if suppressed then call symput('reason',"Unexpected values of &&var&j. occur at rate of >"||compress(put(percentU,8.4))||"%.");
			else call symput('reason',"Unexpected values of &&var&j. occur at rate of "||compress(put(percentU,8.4))||"%.");
		end;
	run;
	%let title6=&reason;
%end;

/*if warn and/or fail limits set, compute unexpected percentage, result and reason;*/
%else %do;
*get true (unsuppressed) frequency and percentage of all unexpected values added up;
proc freq data=miscat noprint;
	where substr(_type_,&&pos&j.,1)='1' 
	%if &&mis&j.=N %then %do; and not missing(&&var&j.) %end;
	;
	tables &&var&j. / %if &&mis&j.=Y %then %do; missing %end;
	out=cat_raw ;
	weight _freq_ ;
    format &&var&j. &&formt&j. ;
run;
*set result and reason as a function of unexpected percentage;
	%let result=PASS;
	%if &&warn&j. ne %then
	%let reason=Unexpected values for the variable &&var&j. occur at an acceptable rate (not >&&warn&j.%).;
	%else
	%let reason=Unexpected values for the variable &&var&j. occur at an acceptable rate (not >&&fail&j.%).;
	data _null_;
		set cat_raw;
		if upcase(put(&&var&j.,&&formt&j.))=:'UNEXPECTED' then do;
			%if &&fail&j. ne %then %do;
				if percent > &&fail&j. then do;
					call symput('result',"FAIL");
					call symput('reason',"Unexpected values of &&var&i occur at too high a rate (>&&fail&j.%).");
				end;
				%if &&warn&j. ne %then %do;
					else if percent > &&warn&j. then do;
						call symput('result',"WARN");
						call symput('reason',"Unexpected values of &&var&i occur at a concerning rate (>&&warn&j.%, but not >&&fail&j.%).");
					end;
				%end;
			%end;
			%else %if &&warn&j. ne %then %do;
				if percent > &&warn&j. then do;
					call symput('result',"WARN");
					call symput('reason',"Unexpected values of &&var&i occur at a concerning rate (>&&warn&j.%).");
				end;
			%end;
		end;
	run;
	%let title6=&result.: &reason.;
%end;
%end;
%else %do; *if no observations in dataset;
	%if "&&warn&j." = "" and "&&fail&j."="" %then %let result=N/A;
	%else %let result=PASS;
	%if &&mis&j.=N %then %let reason = There are no non-missing observations for &&var&j. in dataset &inname..;
	%else %let reason = There are no observations in dataset &inname..;
	%let title6=&reason;
%end;
data dco_feed;
  length Site $4. MemName $32. VarName $32.
  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
        OutDataSet = 'Data Set Containing Check Specifics' ;
  memname = "&inname.";
  varname = "&&var&j.";
  site="&_siteabbr";
  check_description="Expected and Unexpected Rates"; 
  content_area="&content_area"; 
  dateran=datetime();
  version="&version";
  check=compress("&content_area._"||varname||'_'||"category"||'_'||"Descriptive",' ');
  outdataset=substr(upcase("&&outds&j."),index("&&outds&j.",'.')+1);
  format dateran datetime.;
  Reason = "&REASON";
  result = "&result";
run;

*append record to DCO_file; 
%CESR_AppendDS(indataset=dco_feed);

*create outdataset from cleaned up (low count suppressed) data;
data cat_clean;
	set cat_clean ;
    var_desc=trim(left(put(&&var&j.,&&formt&j. ))) || ' (' || trim(left(&&var&j.)) || ')'; 
	if upcase(var_desc)=:'UNEXPECT' then sortorder=1;
	else if upcase(var_desc)=:'EXPECT' then sortorder=3;
	else sortorder=2;
run;
proc sort data=cat_clean out=cat_clean (drop=sortorder &&var&j.);
	by sortorder &&var&j.;
run;

*capture length of analysis variable - to set correct lenght in out dataset;
proc contents data=cat_clean noprint out=c (keep=name length where=(lowcase(name)='var_desc'));
run;
data _null_;
	set c;
	call symput('vdlen',compress(put(length,best12.)));
run;

data  &&outds&j. (	keep= site memname variable var_desc  count percent warn_at fail_at result 
						label=
						%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Expected and unexpected values of &&var&j." %end;
						); 
    length Site $4. MemName $32. Variable $32. Var_Desc $&vdlen. count 8 percent 8 warn_at $17 fail_at $17 result $8  ;
  Site="&_siteabbr.";
  memname="&inname.";
  variable=" &&var&j.";
  %if &n_obs = 0 %then %do; if 0 then %end;
  set cat_clean;
    if _n_=1 then do;
      if "&&warn&j."="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&&warn&j.";
      if "&&fail&j."="" then fail_at="No Fail Limit Set"; else fail_at=">"||"&&fail&j.";
      Result="&Result";
    end;
	output;
  label site = "Site" memname = "Table Name" 
        var_desc="Value of Variable &&var&j. Is Expected or Unexpected"
		variable="Variable Name"
        count="Count - Counts Less Than &lowest_count are Hidden"
        percent="Percents are Recalculated If Counts are Hidden"
        warn_at="Warning Issued If Percent of All Unexpected Values Combined is"
        fail_at="Fail Issued If Percent of All Unexpected Values Combined is"
        Result="Result for the Expected/Unexpected Check Described by This Report";
  format percent 5.1 count best12.;
  run;


*print to report;
	ods proclabel = 	%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Expected and unexpected values of &&var&j." %end;
	;
	title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		  "Check: Rate of Occurrence of Unexpected Values for Variable &&var&j. in Table %upcase(&indataset.)";
	  %end;
	 ;
    title6 "&title6.";
	%if &&mis&j.=N %then %do;
	title7 "Missing values are excluded from analysis.";
	%end;
	%else %do;
	title7 "Missing values are included in analysis.";
	%end;


	proc print data=&&outds&j.
	%if "&&ndis&j" ne  "" %then %do;
	(obs = &&ndis&j.)
	%end;
	noobs label ;
    var site memname var_desc count percent warn_at fail_at result;
	format count hide.;
	%if "&&ndis&j" ne "" %then %do;
	footnote3 "Only the first &&ndis&j. values are displayed. Please refer to &&outds&j. for the full list of values.";
	%end;
    footnote4 "Hidden indicates a count less than &lowest_count..";
    footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
    footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
  run;

*clean up;
proc datasets nolist;
 delete cat_raw cat_clean dco_feed  c; run;
quit;
footnote3;
title5;

%mend category_inds;


%macro frequency_notinds (j);
data &&outds&j. (keep= site &&var&j. count percent);
	length site $4 &&var&j. $16 count percent 8;
		site="&_siteabbr";
		&&var&j. = 'Not in dataset';
		call missing(count,percent);
	label
		site="Site"
		count="Count - Counts Less Than &lowest_count are Hidden"
        percent="Percents are Recalculated If Counts are Hidden"
	;
run;

title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		  "Distribution of Values of Variable &&var&j. in Table %upcase(&indataset.)";
	  %end;
;
title7 "Attention: Requested variable, &&var&j., does not exist in the data set %upcase(&indataset.).";

ods proclabel = 	%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Frequency of values of &&var&j." %end;
;
proc print data=&&outds&j. noobs label;
var &&var&j.;
run;
title5;
%mend frequency_notinds;



%macro frequency_inds (j);
data fre_clean;
	set miscat;
	where substr(_type_,&&pos&j.,1)='1' 
	%if &&mis&j.=N %then %do; and not missing(&&var&j.) %end;
	;
	if _freq_ < &lowest_count. then count=0;
	else count=_freq_;
	keep &&var&j. count;
run;
proc freq data=fre_clean noprint;
	tables &&var&j. / %if &&mis&j.=Y %then %do; missing %end;
	out=fre_clean;
	format &&var&j. &&formt&j. ;
	weight count / zero;
run;
proc sql noprint;
	select count(*) into: n_obs from fre_clean;
quit;

data &&outds&j. (keep= site &&var&j. count percent);
	length site $4;
	*read in dataset if there are observations, otherwise only copy data vector;
	%if &n_obs = 0 %then %do; if 0 then %end;
	set fre_clean (rename=(&&var&j.=oldvar));
	site = "&_siteabbr.";
	%if &&formt&j. ne %then %do;
		&&var&j. = put(oldvar,&&formt&j.);
	%end;
	%else %do;
		&&var&j. = oldvar;
	%end;
	*if no observations, make sure there are no values in the analysis variable;
	%if &n_obs = 0 %then %do; call missing(&&var&j.); %end;
	label
		site="Site"
		count="Count - Counts Less Than &lowest_count are Hidden"
        percent="Percents are Recalculated If Counts are Hidden"
	;
run;

title5 
	  %if "&&titl&j." ne "" %then %do;
		"&&titl&j."
	  %end;
	  %else %do;
		  "Distribution of Values of Variable &&var&j. in Table %upcase(&indataset.)";
	  %end;
;
%if &n_obs = 0 %then %do;
title6 
	%if &&mis&j.=Y %then %do;
		"There are no observations in dataset &inname..";
	%end;
	%else %do;
		"There are no non-missing observations for &&var&j. in dataset &inname..";
	%end;
%end;

%if "&&ndis&j" ne "" %then %do;
footnote3 "Only the first &&ndis&j. values are displayed. Please refer to &&outds&j. for the full list of values.";
%end;
footnote4 "Hidden indicates a count less than &lowest_count.";
footnote5 
%if &&mis&j.=Y %then %do;"Missing values are counted in the frequencies." %end;
%else  %do; "Missing values are NOT counted in the frequencies." %end;  
;

%if "&&ndis&j" ne  "" %then %do;
	proc sort data=&&outds&j. out=__d;
		by descending count; 
	run;
%end;
%else %do;
	data __d;
		set &&outds&j.;
	run;
%end;

ods proclabel = 	%if "&&label&j." ne "" %then %do; "&&label&j." %end;
						%else %do; "Frequency of values of &&var&j." %end;
;
proc print data=__d
	%if "&&ndis&j" ne  "" %then %do;
	(obs = &&ndis&j.)
	%end;
	noobs label ;
var &&var&j. count percent;
format count hide. percent 6.2;
run;
footnote3;
title5;

proc datasets lib=work nolist;
	delete fre_clean; run;
quit;

%mend frequency_inds;

*perform each check in order found in parameters input dataset;
%if &total_checks %then %do i=1 %to &total_checks.;
	%if &&chk&i.=mis %then %do;
		%if &&inds&i.=1 %then %missing_inds(&i);
		%else %missing_notinds(&i);
	%end;
	%else %if &&chk&i.=cat  %then %do;
		%if &&inds&i.=1 %then %category_inds(&i);
		%else %category_notinds(&i);
	%end;
	%else %if &&chk&i.=fre  %then %do;
		%if &&inds&i.=1 %then %frequency_inds(&i);
		%else %frequency_notinds(&i);
	%end;
%end;


*clean up;
proc datasets lib=work nolist;
	delete dscontents mis cat miscat; run;
quit;
title5;
footnote4;

%mend CESR_VLC_MULTICHECK;

****************************** CESR_VLC_MULTICHECK ***************************
****************************** CESR_VLC_MULTICHECK ***************************;






****************************** CESR_VLC_XREF ***************************
****************************** CESR_VLC_XREF ***************************
CESR_VLC_XREF:

This macro performs a data check comparing the specified variables actual type and/or length against a reference variable's
type and/or length.


This macro:
1. Prints 1 output report per type and length check
       Columns in Report are: 	Site, Content Area Being QAed, Table Name, Variable Name, Reference Dataset, 
								Reference Variable, Check Type (Type vs Length), Found, Reference, Result

2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
       Columns in DCO_file are: site, data set name, variable name, check performed, result, reason, 
            date/time program ran, VDW version, content area being QAedtype, name of the check, 
            output data set containing check specifics. 

3. Creates 1 dataset named by the user 
       The value of &QAoutlib is established by the user in the edit section of the calling program.
       Columns in table are: 	Site, Content Area Being QAed, Table Name, Variable Name, Reference Dataset, 
								Reference Variable, Check Type (Type vs Length), Found, Reference, Result, Reason


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.

To invoke the macro you must:

    a) supply the names of table/dataset to check
	b) supply the name of the target variable to check
	c) supply the name of the reference variable to which the target variable will be compared
	d) supply the name of the reference variable (if the name if different from the target variable-
		if not supplied, refvariable will be set to the same values as variable)
	e) indicate whether the variable type is to be checked
	f) indicate whether variable length is to be checked
	g) supply then name of the output dataset

Example Calls

%CESR_VLC_XREF(indataset=&_vdw_px, variable=performing_provider, refdataset=&_vdw_provider_specialty, refvariable=provider, 
				checktype = Y, checklength = Y, outdataset = out.provider_xref)
%CESR_VLC_XREF(indataset=&_vdw_dx, variable=mrn, refdataset=&_vdw_demographic, checktype = N, checklength = Y, outdataset = out.mrn_xref)


Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny Staab				503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     Don.Bachman@kpchr.org      503-335-6731
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  06/2014
****************************** CESR_VLC_XREF ***************************
****************************** CESR_VLC_XREF ***************************;


%macro CESR_VLC_XREF(indataset=, variable=, refdataset=, refvariable=, checktype = Y, checklength = Y, outdataset = );

%CESR_SymbolCheck;

	%local inname refname ;

	*establish macro variable values;
	%let inname=%upcase(%substr(&indataset,%eval(%index(&indataset,.)+1)));
	%let refname=%upcase(%substr(&refdataset,%eval(%index(&refdataset,.)+1)));
	%let variable=%upcase(&variable);
	%if &refvariable = %then %let refvariable=&variable;
	%let refvariable=%upcase(&refvariable);

	PROC FORMAT;
		value typ 1='numeric' 2='character' .='not in dataset';
		value leng .='not in dataset';
	RUN;

	proc contents data=&refdataset. out=ref 
		(keep=name type length where=(upcase(name)="&refvariable.") rename=(type=reftype length=reflength)) noprint
		;
	run;
	data ref; set ref; name='0'; run;
	proc contents data=&indataset. out=check
		(keep=name type length where=(upcase(name)="&variable.")) noprint
		;
	run;
	data check; set check; name='0'; run;

data
	dco_feed (keep=Site  MemName VarName Result Reason Check_description DateRan Version Content_Area Check OutDataSet) 
	&outdataset (keep=Site Content_Area MemName VarName RefDataSet RefVar CheckType Result Reason CheckValue RefValue 
	label = "Type/length of variable &variable compared to type/length of variable &refvariable. in &refname."
)
	;
  Length Site $4. MemName VarName RefDataSet RefVar $32. CheckType $6. CheckValue RefValue 8
  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41;
  label site = "Site" memname = "Table Name" varname = "Variable Name"
        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
        OutDataSet = 'Data Set Containing Check Specifics' 
		RefDataset = "Reference Dataset" RefVar ="Reference Variable"
		RefValue = "Reference"
		CheckValue = "Found";

	merge check ref;
	by name;

	  memname = "&inname";
	  varname = "&variable";
	  refdataset="&refname.";
	  refvar="&refvariable.";
	  site="&_siteabbr";
	  content_area="&content_area"; 
	  dateran=datetime();
	  version="&version";
	  outdataset="&outdataset.";
	  format dateran datetime.;


	%if &checktype. = Y %then %do;
		CHECK=compress("&CONTENT_area._"||varname||'_'||"type"||'_'||"Descriptive",' ');
		CHECK_DESCRIPTION="Compares type of variable to type of reference variable.";
		CHECKTYPE="TYPE";
		CHECKVALUE=TYPE;
		REFVALUE=REFTYPE;
		if type=reftype then do;
			RESULT="PASS";
			IF refTYPE=1 THEN REASON="Reference variable and check variable are numeric.";
			ELSE REASON="Reference variable and check variable are character.";
		end;
		else do;
			RESULT="FAIL";
			if missing(type) or missing(reftype) then reason="Check and/or reference variable is not in the dataset.";
			else IF refTYPE=1 THEN REASON="Reference variable is numeric, but check variable is character.";
			ELSE REASON="Reference variable is character, but check variable is numeric.";
		end;
		OUTPUT;
	%end;
	%if &checklength. = Y %then %do;
		CHECK=compress("&CONTENT_area._"||varname||'_'||"length"||'_'||"Descriptive",' ');
		CHECK_DESCRIPTION="Compares length of variable to length of reference variable.";
		CHECKTYPE="LENGTH";
		CHECKVALUE=LENGTH;
		REFVALUE=REFLENGTH;
		if length=reflength then do;
			RESULT="PASS";
			REASON=compress(put(length,best12.)||"="||put(reflength,best12.))||" is true.";
		end;
		else do;
			RESULT="FAIL";
			if missing(length) or missing(reflength) then reason="Check and/or reference variable is not in the dataset.";
			else REASON=compress(put(length,best12.)||"="||put(reflength,best12.))||" is false.";
		end;		
		OUTPUT;
	%end;
RUN;

%CESR_APPENDDS (indataset=dco_feed);

%if &checktype. = Y %then %do;
ods proclabel="Type of &variable compared to &refname.";
title5 "Check: Comparison of Variable Type Against Reference Variable Type";
title6 "&variable in &inname vs. &refvariable in &refname..";
proc print data=&outdataset.   noobs label;
where checktype="TYPE";
	var Site Content_Area MemName VarName  RefDataSet RefVar  CheckType CheckValue RefValue Result ;
	format CheckValue RefValue typ.;
run;
%end;
%if &checklength. = Y %then %do;
ods proclabel="Length of &variable compared to &refname.";
title5 "Check: Comparison of Variable Length Against Reference Variable Length";
title6 "&variable in &inname vs. &refvariable in &refname..";
proc print data=&outdataset.   noobs label;
where checktype="LENGTH";
	var Site Content_Area MemName VarName  RefDataSet RefVar  CheckType CheckValue RefValue Result ;
	format CheckValue RefValue leng.;
run;
%end;

proc datasets lib=work nolist;
	delete dco_feed check ref; run;
quit;

%mend CESR_VLC_XREF;

****************************** CESR_VLC_XREF ***************************
****************************** CESR_VLC_XREF ***************************;



****************************** CESR_VLC_MULTICHECK2 ***************************
****************************** CESR_VLC_MULTICHECK2 ***************************;
*/
CESR_VLC_MULTICHECK2:

This macro performs a number of data checks on one or more variables in the same dataset and/or creates subsets of the input dataset:
Checks
* Missingness
* Category (Expected/Unexpected values)
* Frequency (Distribution of values)
* XCategory (Expected/Unexpected combinations of values of 2 variables)
* ObsCount (Number of records in input dataset)
* DateTrend (Distribution of records by date)
* TimeTrend (Distribution of records by time of day)
Subsetting
* Subset (Subset of input based on match to IDs in provided dataset)
* Sample (Random sample of requested percentage)

Options:
* By-variable for Missingness, Category, and Frequency, DateTrend and TimeTrend
* For Missingness, Category, and XCategory: output records unexpected/missing values to local dataset
* Restrict analysis/sampling to defined subset (by criterion)
* For sampling/subset: only same a defined group of variables in output dataset
* Custom TOC labels, titles, and footnotes
* Set maximum number of printed lines in report for Category, XCategory, and Frequency

Note:
Multiple checks can be performed for any variables.


For checks:
1. Prints 1 output report per check
2. Appends 1 row explaining the result for the requested variable and data set to the DCO_file.
3. Creates 1 dataset with check results (named by the user) 
4. Optionally, creates an additional dataset with non-conforming records (named by user)

For subsets:
1. Creates 1 dataset with selected records and variables (named by user)


Title lines 1 and 2 along with Footnote line 1 are reserved for global use by the wrapper QA program.
Title lines 3 and 4 as well as Footnote lines 2 and 3 can be used by the programmer.
Title lines 5 and higher and Footnote lines 4 and higher are reserved for use by the macros and will be cleared
    as each macro finishes executing.



Contact Information: CESR VDW Consultants 
                     CESR Data Coordinating Center
                     Center for Health Research
                     Kaiser Permanente Northwest
                     
					 Jenny Staab				503-335-6683
                     Gwyn.Saylor@kpchr.org      503-335-2447
                     
Authors:    CESR VDW Consultants and CESR Analysts
Published:  4/2020

*/;

%macro CESR_VLC_MULTICHECK2 (indataset=, parameters=);

%cesr_symbolcheck;

*preliminaries;
%let inname=%substr(%upcase(&indataset),%eval(%index(&indataset,.)+1));
proc format;
  value hide 
   0 = "    Hidden";
  value miss .='Missing' other='Non-Missing';
  value $miss '',' '='Missing' other='Non-Missing';
  value h 0-3599,86400='00'
			3600-7199='01'
			7200-10799='02'
			10800-14399='03'
			14400-17999='04'
			18000-21599='05'
			21600-25199='06'
			25200-28799='07'
			28800-32399='08'
			32400-35999='09'
			36000-39599='10'
			39600-43199='11'
			43200-46799='12'
			46800-50399='13'
			50400-53999='14'
			54000-57599='15'
			57600-61199='16'
			61200-64799='17'
			64800-68399='18'
			68400-71999='19'
			72000-75599='20'
			75600-79199='21'
			79200-82799='22'
			82800-86399='23';
 run; 



*get content of indataset;
proc contents data=&indataset. noprint out=dscontents (keep=name type length);
run;
data dscontents;
	set dscontents;
	name=upcase(name);
run;

*determine maximum length of format labels for each format/check;
proc format cntlout=f; run;
data f;
	set f;
	by type fmtname notsorted;
	if first.fmtname;
	if type='N' then format=upcase(compress(fmtname||'.'));
	else format=upcase(compress('$'||fmtname||'.'));
	keep format length;
	rename length=fmtlen;
run;
*standard formats;
proc sql;
	create table s as select upcase(compress(fmtname||'.')) as format, defw as fmtlen from dictionary.formats where fmttype='F';
quit;

*read in parameters and capture in macro variables;
data _null_;
length name $32 type bytype length varlength bylength vfmtlen bfmtlen cfmtlen 8; 

	if _n_=1 then do;
	*for checking whether variables exist;
		declare hash contents (dataset: "dscontents");
		contents.definekey('name');
		contents.definedata('type','length');
		contents.definedone();
	*for getting required lengths of variables in outputdatasets;
		*user defined formats;
		declare hash fmtln (dataset: "f");
		fmtln.definekey('format');
		fmtln.definedata('fmtlen');
		fmtln.definedone();
		*standard formats;
		declare hash sfmtlen (dataset: "s");
		sfmtlen.definekey('format');
		sfmtlen.definedata('fmtlen');
		sfmtlen.definedone();
	end;

	set &parameters. end=eof;
	retain total_checks 0;
	call missing(name,type,bytype,length,varlength,bylength,fmtlen,vfmtlen,bfmtlen,cfmtlen);
	
	total_checks+1;

	check=lowcase(check);
	variable=upcase(variable);
	byvariable=upcase(byvariable);
	format=upcase(format);
	byformat=upcase(byformat);
	comboformat=upcase(comboformat);

	*check whether variables exist and get length if they do exist;
	if missing(byvariable) then bymiss=0;
	else do;
		bymiss=ifn(contents.find(key:byvariable)=0,0,1);
		if bymiss then do; *if by-variable does not actually exist, make by-variable string with length 13;
			bylength=13;
			bytype=2;
		end;
		else do; *if it exists, get give it the actual existing specs from proc contents;
			bylength=length;
			bytype=type;
		end;
	end;
	varmiss=ifn(contents.find(key:variable)=0,0,1); *check if variable exists;
		varlength=length;
		
	*assign inds (in dataset) parameter that will decide whether check gets performed;
	if check in ('sample','subset','obscount') then inds = 1; *no matter what;
	else if (not varmiss and not bymiss) and check='xcategory' then inds = 1; *for xcategory, both vars must exist;
	else if not varmiss and check ne 'xcategory' then inds = 1; *for others, main var must exist;
	else inds = 0;

	*get lengths of formats;
	%macro getfmtlen(f);
		if not missing(&f.) then do;
		call missing(fmtlen);
			rc = fmtln.find(key:&f.);
			if rc ne 0 then rc = sfmtlen.find(key:&f.);
			if rc ne 0 then do;
				nodigit=0;
				i=1;
				do until (nodigit);
					i+1;
					if anydigit(&f.,-(index(&f.,'.')-i)) ne index(&f.,'.')-i then nodigit=1;
				end;
				fmtlen=input(substr(&f.,index(&f.,'.')-i+1,i-1),best12.);
			end;
		end;
	%mend getfmtlen;

	%getfmtlen(format)
	vfmtlen = fmtlen;
	%getfmtlen(byformat)
	bfmtlen = fmtlen;
	%getfmtlen(comboformat)
	cfmtlen = fmtlen;

	*get parameters for all requested checks ;
		call symput (compress('inds'||put(_n_,best12.)),put(inds,1.0));
		call symput (compress('varmiss'||put(_n_,best12.)),put(varmiss,1.0));
		call symput (compress('bymiss'||put(_n_,best12.)),put(bymiss,1.0));

			call symput (compress('if'||put(_n_,best12.)),strip(where));
			call symput (compress('var'||put(_n_,best12.)),compress(variable));
			call symput (compress('byvar'||put(_n_,best12.)),compress(byvariable));
			call symput (compress('mis'||put(_n_,best12.)),missing);
			call symput (compress('fmt'||put(_n_,best12.)),compress(format));
			call symput (compress('byfmt'||put(_n_,best12.)),compress(byformat));
			call symput (compress('cofmt'||put(_n_,best12.)),compress(comboformat));
			call symput (compress('warn'||put(_n_,best12.)),compress(warnpercent));
			call symput (compress('fail'||put(_n_,best12.)),compress(failpercent));
			call symput (compress('outds'||put(_n_,best12.)),compress(outdataset));
			call symput (compress('label'||put(_n_,best12.)),strip(label));
			call symput (compress('titl'||put(_n_,best12.)),strip(title5));
			call symput (compress('foot'||put(_n_,best12.)),strip(footnote3));
			call symput (compress('ndis'||put(_n_,best12.)),compress(ndisplay));
			call symput (compress('nloc'||put(_n_,best12.)),compress(nlocalrecords));
			call symput (compress('locds'||put(_n_,best12.)),compress(localdataset));
			call symput (compress('typ'||put(_n_,best12.)),put(type,1.0));

		select(check);
			when('category') do;
				call symput (compress('chk'||put(_n_,best12.)),'cat');
				if varmiss then call symput (compress('vlen'||put(_n_,best12.)),'$13');
				else if type=1 then call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(12+vfmtlen+3,best12.)));
				else call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(varlength+vfmtlen+3,best12.)));

				if not missing (byvariable) then do;
					if bymiss then do;
						call symput (compress('blen'||put(_n_,best12.)),'$13');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
					else if missing(byformat) then do;
						if bytype=1 then do;
							call symput (compress('blen'||put(_n_,best12.)),'8');
							call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
						end;
						else do;
							call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
							call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
						end;
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else call symput (compress('blen'||put(_n_,best12.)),'');

				call symput (compress('clen'||put(_n_,best12.)),'');
				if missing (byvariable) then call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"'"));
				else call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"','_b_",put(_n_,best12.),"'"));
				call symput(compress('hashvar'||put(_n_,best12.)),'str');
			end;
			when('missing') do;
				call symput (compress('chk'||put(_n_,best12.)),'mis');
				if varmiss then call symput (compress('vlen'||put(_n_,best12.)),'$13');
				else call symput (compress('vlen'||put(_n_,best12.)),'$12');

				if not missing (byvariable) then do;
					if bymiss then do;
						call symput (compress('blen'||put(_n_,best12.)),'$13');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
					else if missing(byformat) then do;
						if bytype=1 then do;
							call symput (compress('blen'||put(_n_,best12.)),'8');
							call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
						end;
						else do;
							call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
							call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
						end;
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else call symput (compress('blen'||put(_n_,best12.)),'');

				call symput (compress('clen'||put(_n_,best12.)),'');
				if missing (byvariable) then call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"'"));
				else call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"','_b_",put(_n_,best12.),"'"));
				call symput(compress('hashvar'||put(_n_,best12.)),'str');
			end;
			when('frequency') do;
				call symput (compress('chk'||put(_n_,best12.)),'fre');
				if varmiss then call symput (compress('vlen'||put(_n_,best12.)),'$13');
				else if missing(format) then do;
					if type=1 then do;
						call symput (compress('vlen'||put(_n_,best12.)),'8');
						call symput(compress('hashvar'||put(_n_,best12.)),'num');
					end;
					else do;
						call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(varlength,best12.)));
						call symput(compress('hashvar'||put(_n_,best12.)),'str');
					end;
				end;
				else do;
					call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(vfmtlen,best12.)));
					call symput(compress('hashvar'||put(_n_,best12.)),'str');
				end;

				if not missing (byvariable) then do;
					if bymiss then do;
						call symput (compress('blen'||put(_n_,best12.)),'$13');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
					else if missing(byformat) then do;
						if bytype=1 then do;
							call symput (compress('blen'||put(_n_,best12.)),'8');
							call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
						end;
						else do;
							call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
							call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
						end;
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else call symput (compress('blen'||put(_n_,best12.)),'');

				call symput (compress('clen'||put(_n_,best12.)),'');
				if missing (byvariable) then call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"'"));
				else call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"','_b_",put(_n_,best12.),"'"));
			end;
			when('xcategory') do;
				call symput (compress('chk'||put(_n_,best12.)),'cax');
				if varmiss then call symput (compress('vlen'||put(_n_,best12.)),'$13');
				else if missing(format) then do;
					if type=1 then do;
						call symput (compress('vlen'||put(_n_,best12.)),'8');
						call symput(compress('hashvar1_'||put(_n_,best12.)),'num1');
					end;
					else do;
						call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(varlength,best12.)));
						call symput(compress('hashvar1_'||put(_n_,best12.)),'str1');
					end;
				end;
				else do;
					call symput (compress('vlen'||put(_n_,best12.)),compress('$'||put(vfmtlen,best12.)));
					call symput(compress('hashvar1_'||put(_n_,best12.)),'str1');
				end;

				if bymiss then call symput (compress('blen'||put(_n_,best12.)),'$13');
				else if missing(byformat) then do;
					if bytype=1 then do;
						call symput (compress('blen'||put(_n_,best12.)),'8');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else do;
					call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
					call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
				end;

				call symput (compress('clen'||put(_n_,best12.)),compress('$'||put(cfmtlen,best12.)));
				call symput(compress('hashvar'||put(_n_,best12.)),'str');

				call symput (compress('varlist'||put(_n_,best12.)),cats("'_c_",put(_n_,best12.),"','_v_",put(_n_,best12.),"', '_b_",put(_n_,best12.),"'"));
			end;
			when('datetrend') do;
				call symput (compress('chk'||put(_n_,best12.)),'dat');
				call symput (compress('vlen'||put(_n_,best12.)),'8');
				if not missing (byvariable) then do;
					if bymiss then do;
						call symput (compress('blen'||put(_n_,best12.)),'$13');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
					else if missing(byformat) then do;
						if bytype=1 then do;
							call symput (compress('blen'||put(_n_,best12.)),'8');
							call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
						end;
						else do;
							call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
							call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
						end;
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else call symput (compress('blen'||put(_n_,best12.)),'');
				call symput (compress('clen'||put(_n_,best12.)),'');
				if missing (byvariable) then call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"'"));
				else call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"','_b_",put(_n_,best12.),"'"));
				call symput(compress('hashvar'||put(_n_,best12.)),'num');
			end;
			when('timetrend') do;
				call symput (compress('chk'||put(_n_,best12.)),'tim');
				call symput (compress('vlen'||put(_n_,best12.)),'8');
				if not missing (byvariable) then do;
					if bymiss then do;
						call symput (compress('blen'||put(_n_,best12.)),'$13');
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
					else if missing(byformat) then do;
						if bytype=1 then do;
							call symput (compress('blen'||put(_n_,best12.)),'8');
							call symput(compress('hashvar2_'||put(_n_,best12.)),'num2');
						end;
						else do;
							call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bylength,best12.)));
							call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
						end;
					end;
					else do;
						call symput (compress('blen'||put(_n_,best12.)),compress('$'||put(bfmtlen,best12.)));
						call symput(compress('hashvar2_'||put(_n_,best12.)),'str2');
					end;
				end;
				else call symput (compress('blen'||put(_n_,best12.)),'');
				call symput (compress('clen'||put(_n_,best12.)),'');
				if missing (byvariable) then call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"'"));
				else call symput (compress('varlist'||put(_n_,best12.)),cats("'_v_",put(_n_,best12.),"','_b_",put(_n_,best12.),"'"));
				call symput(compress('hashvar'||put(_n_,best12.)),'num');
			end;
			when ('sample','subset','obscount') do;
				select (check);
					when ('sample') call symput (compress('chk'||put(_n_,best12.)),'smp');
					when ('subset') call symput (compress('chk'||put(_n_,best12.)),'sub');
					when ('obscount') call symput (compress('chk'||put(_n_,best12.)),'obs');
					otherwise;
				end;
				call symput (compress('vlen'||put(_n_,best12.)),'');
				call symput (compress('blen'||put(_n_,best12.)),'');
				call symput (compress('blen'||put(_n_,best12.)),'');
				call symput (compress('clen'||put(_n_,best12.)),'');
				call symput (compress('varlist'||put(_n_,best12.)),'');
				call symput(compress('hashvar'||put(_n_,best12.)),'');
			end;
			otherwise;
		end;


*capture number of checks for looping;
	if eof then call symput ('total_checks',compress(put(total_checks,best12.))); 
run;

***do the counting in the input dataset;
data
	ds 
	%do i=1 %to &total_checks;
	%if &&inds&i.. and (&&chk&i.. = smp or &&chk&i.. = sub) %then %do;
		&&outds&i.. 
		%if "&&titl&i.." ne "" %then %do;
		(keep = &&titl&i..)
		%end;
		%else %do;
		(drop = obs)
		%end;
	%end;
	%else %if &&inds&i.. and "&&locds&i.." ne "" %then %do;
		&&locds&i..	(drop=obs)
	%end;
	%else %if &&chk&i.. = obs %then %do;
		obscountds (keep=obs)
	%end;
	%end;
	;

	*get hash table variables into PDV;
	length 
	freq 8 
	%do i=1 %to &total_checks;
	%if &&inds&i.. %then %do;
			%if &&clen&i.. ne  %then %do;
		_c_&i. &&clen&i..
			%end;
			%if &&vlen&i.. ne  %then %do;
		_v_&i. &&vlen&i..
			%end;
			%if &&blen&i.. ne  %then %do;
		_b_&i. 
			%if &&bymiss&i.. %then %do; &&byvar&i.. %end;
				&&blen&i..
			%end;
	%end;
	%end;
	str str2 str1 $256 
	num num2 num1 nloc rc obs  8 
	;

	if _n_=1 then do;
		*set up hashtables for counting;
		%do i=1 %to &total_checks;
		%if &&inds&i.. %then %do;
		%if &&chk&i.. ne smp and &&chk&i.. ne sub and &&chk&i.. ne obs %then %do;
			declare hash h&i. (ordered:'a');
			h&i..definekey (&&varlist&i..);
			h&i..definedata (&&varlist&i.., 'freq');
			h&i..definedone();
		%end;
		%else %if &&chk&i.. = sub %then %do;
			declare hash h&i. (dataset:"&&nloc&i..");
			h&i..definekey ("&&var&i.");
			h&i..definedone();
		%end;
		%end;
		%end;

	end;

	set &indataset end=eof;
	retain
		%do i=1 %to &total_checks; %if &&inds&i. and "&&nloc&i.." ne "" %then %do;
		nloc&i. 0
		%end; %end;
		obs 0;
	;
	

	call missing(freq, rc, nloc, str, str1, str2, num, num1, num2
		%do i=1 %to &total_checks;
		%if &&inds&i.. %then %do;
			%if &&clen&i.. ne  %then %do;
		,_c_&i. 
			%end;
		,_v_&i. 
			%if &&blen&i.. ne  %then %do;
		,_b_&i.
			%if &&bymiss&i.. %then %do;
		,&&byvar&i.. 
			%end;
			%end;
		%end;
		%end;
	);

	%do i=1 %to &total_checks;
	%if &&inds&i. %then %do;

	%if "&&if&i.." ne "" %then %do;
	if &&if&i.. then do;
	%end; 

	%if &&chk&i.. = obs %then %do;
	obs+1;
	%end; 

	%else %if &&chk&i.. = sub %then %do;
	if h&i..check()=0 then output &&outds&i..;
	%end; 

	%else %if &&chk&i.. = smp %then %do;
	if ranuni(0) <= &&nloc&i../100 then output &&outds&i..;
	%end; 

	%else %do; /*regular checks*/
	call missing (str, str1, str2, num);

		%if &&chk&i.. = cat %then %do;
			&&hashvar&i.. = trim(put(&&var&i.., &&fmt&i..))||' ('||trim(&&var&i..)||')';
			%if &&byvar&i.. ne %then %do;
				%if &&bymiss&i..=0 and &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
				%end;
				%else %do;
			&&hashvar2_&i..=&&byvar&i.;
				%end;
			%end;
			%if "&&locds&i.." ne "" %then %do;
			if &&hashvar&i.. =: 'Unexpect' then do;
					%if &&nloc&i.. ne %then %do;
				nloc&i. + 1;
				if nloc&i. <= &&nloc&i.. then
					%end;
				output &&locds&i..;
			end;
			%end;
		%end;
		%else %if &&chk&i.. = mis %then %do; 
			%if &&typ&i.. = 1 %then %do;
			&&hashvar&i.. = put(&&var&i.., miss.);
			%end;
			%else %do;
			&&hashvar&i.. = put(&&var&i.., $miss.);
			%end;
			%if &&byvar&i.. ne %then %do;
				%if  &&bymiss&i..=0 and &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
				%end;
				%else %do;
			&&hashvar2_&i..=&&byvar&i.;
				%end;
			%end;
			%if "&&locds&i.." ne "" %then %do;
			if &&hashvar&i.. =: 'Missing' then do;
					%if &&nloc&i.. ne %then %do;
				nloc&i. + 1;
				if nloc&i. <= &&nloc&i.. then
					%end;
				output &&locds&i..;
			end;
			%end;
		%end;
		%else %if &&chk&i. = fre %then %do;
			%if &&fmt&i. ne %then %do;
			&&hashvar&i.. = put(&&var&i.., &&fmt&i..);
			%end;
			%else %do;
			&&hashvar&i.. = &&var&i..;
			%end;
			%if &&byvar&i.. ne %then %do;
				%if  &&bymiss&i..=0 and &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
				%end;
				%else %do;
			&&hashvar2_&i..=&&byvar&i.;
				%end;
			%end;
		%end;
		%else %if &&chk&i. = cax %then %do;
			%if &&fmt&i. ne %then %do;
			&&hashvar1_&i.. = put(&&var&i.., &&fmt&i..);
			%end;
			%else %do;
			&&hashvar1_&i.. = &&var&i..;
			%end;
			%if &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
			%end;
			%else %do;
			&&hashvar2_&i..=&&byvar&i.;
			%end;
			&&hashvar&i.. = put(trim(&&hashvar2_&i..)||'***'||trim(&&hashvar1_&i..), &&cofmt&i..);
			%if "&&locds&i.." ne "" %then %do;
			if &&hashvar&i.. =: 'Unexpect' then do;
					%if &&nloc&i.. ne %then %do;
				nloc&i. + 1;
				if nloc&i. <= &&nloc&i.. then
					%end;
				output &&locds&i..;
			end;
			%end;
		%end;
		%else %if &&chk&i. = dat %then %do;
			&&hashvar&i.. = &&var&i..;
			%if &&byvar&i.. ne %then %do;
				%if  &&bymiss&i..=0 and &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
				%end;
				%else %do;
			&&hashvar2_&i..=&&byvar&i.;
				%end;
			%end;
		%end;
		%else %if &&chk&i. = tim %then %do;
			&&hashvar&i. = &&var&i.. - mod(&&var&i..,60);
			%if &&byvar&i.. ne %then %do;
				%if  &&bymiss&i..=0 and &&byfmt&i.. ne  %then %do;
			&&hashvar2_&i..=put(&&byvar&i.,&&byfmt&i..);
				%end;
				%else %do;
			&&hashvar2_&i..=&&byvar&i.;
				%end;
			%end;
		%end;

		/*if missing=N then only count if variable is not missing*/
		%if "&&mis&i.." ne "Y" and "&&chk&i.." ne "mis" %then %do;
		if not missing(&&var&i..) then do;
		%end;

		freq=0;
		rc = h&i..find(	
							key:&&hashvar&i..
								%if &&chk&i.. = cax %then %do;
							,key:&&hashvar1_&i..
								%end;
								%if &&byvar&i.. ne %then %do;
							,key:&&hashvar2_&i..
								%end;
						);
		freq = freq + 1;
		rc = h&i..replace(
							key:&&hashvar&i..
								%if &&chk&i.. = cax %then %do;
							,key:&&hashvar1_&i..
								%end;
								%if &&byvar&i.. ne %then %do;
							,key:&&hashvar2_&i..
								%end;
							,data:&&hashvar&i..
								%if &&chk&i.. = cax %then %do;
							,data:&&hashvar1_&i..
								%end;
								%if &&byvar&i. ne %then %do;
							,data:&&hashvar2_&i..
								%end;
							,data:freq
						);
		%if "&&mis&i.." ne "Y" and "&&chk&i.." ne "mis" %then %do;
		end;
		%end;

	%end; /*regular check, not sample*/
	%if "&&if&i.." ne "" %then %do; end; %end; /*subset retriction end*/
	%end; /*inds*/
	%end; /*cycle through checks*/

	if eof then do;
	%do i=1 %to &total_checks;
		%if &&inds&i. and &&chk&i.. ne smp and &&chk&i.. ne sub and &&chk&i.. ne obs %then %do;
		rc = h&i..output(dataset:"ds&i.");
		%end;
		%else %if &&chk&i.. = obs %then %do;
		output obscountds;
		%end;
	%end;
	end;
	
	drop 
		freq str str1 str2 num num1 num2 rc nloc:
		%do i=1 %to &total_checks;
		%if &&inds&i.. %then %do;
			%if &&clen&i.. ne  %then %do;
		_c_&i. 
			%end;
		_v_&i. 
			%if &&blen&i.. ne  %then %do;
		_b_&i.
			%end;
		%end;
		%end;
	;

run;

%do i=1 %to &total_checks.;

	*for titles (only used for cat/mis/cax);
	%if &&chk&i.. = mis %then %let badstr = Missing;
	%else %let badstr = Unexpected;

	%if &&chk&i.. = cax %then %let values = combinations of &&var&i.. and &&byvar&i..;
	%else %let values = values of &&var&i..;

	%if &&chk&i.. = cat %then %let badvalues = All Unexpected Values Combined;
	%else %if &&chk&i.. = cax %then %let badvalues = All Unexpected Combinations;
	%else %if &&chk&i.. = mis %then %let badvalues = Missing Values;
	%else %let badvalues = ;

	*end titles;


%if &&inds&i.. %then %do;

	%if &&chk&i.. = smp or &&chk&i.. = sub %then %do; *sample;
	*nothing to be done, sample already created;
	%end; /*sample end;*/



	%else %if &&chk&i.. = obs %then %do; *obscount;
	data &&outds&i.. ;
		length site $4 obscount 8;
		set obscountds (rename=(obs=obscount));
		site="&_siteabbr.";
	run;
	ods proclabel="Total observation count of &content_area.";
	title4 "Total number of observations in &content_area dataset";
	proc print data=&&outds&i.. noobs label;
	label obscount ="Number of observations in the &content_area dataset" site="Site";
	format obscount comma16.;
	run;
	title4;	
	%end; /*obscount end;*/



	%else %if &&chk&i..=cat or &&chk&i..=cax or &&chk&i..=fre or &&chk&i..=mis %then %do; *cat/xcat/freq/miss;
	*check whether there are any records to process;
	proc sql noprint;
		select count(*) into: nobs from ds&i.;
	quit;


	%if &nobs. %then %do; *if there are records;
	%if &&chk&i.. = cat or &&chk&i.. = mis or &&chk&i.. = cax %then %do; *checks with PASS/WARNING/FAIL percentages: compute result and reason;

		data ds;
		length v $20;
			set ds&i.;
			%if &&chk&i.. = cat %then %do;
			v = substr(_v_&i., 1, index(_v_&i., '(')-2 );
			%end;
			%else %if &&chk&i.. = cax %then %do;
			v = _c_&i.;
			%end;
			%else %if &&chk&i.. = mis %then %do;
			v = _v_&i.;
			%end;
		run;
		proc freq data = ds noprint;
			tables v / out=summary;
			weight freq;
		run;
		data _null_;
			set summary end=eof;
			retain n p .;
			if v =: "&badstr." then do;
				p=percent;
				n=count;
			end;
			if eof then do;
				p = coalesce(p,0);
				call symput("badpct",put(p,8.4));
				if 0<n<&lowest_count. then call symput('suppressed','1');
				else call symput('suppressed','0');
			end;
		run;

		%if &&warn&i.. =  and &&fail&i..=  %then %do;
			%if &suppressed. %then %let badpct = >0;
			%let result=N/A;
			%let reason = &badstr. &values occur at rate of &badpct.%.;
			%let title6=&reason;
		%end;
		%else %do;
			%let result=PASS;
			%if &&warn&i. ne %then %let reason=&badstr. &values occur at an acceptable rate (not >&&warn&i.%).;
			%else %let reason=&badstr. &values occur at an acceptable rate (not >&&fail&i.%).;

			%if &&fail&i.. ne %then %do;
				%if %sysevalf(&badpct. > &&fail&i..) %then %do;
					%let result = FAIL;
					%let reason = &badstr. &values occur at too high a rate (>&&fail&i..%).;
				%end;
				%else %if &&warn&i.. ne %then %do;
					%if %sysevalf(&badpct. > &&warn&i..) %then %do;
						%let result = WARN;
						%let reason = &badstr. &values occur at a concerning rate (>&&warn&i..%, but not >&&fail&i..%).;
					%end;
				%end;
			%end;
			%else %if %sysevalf(&badpct. > &&warn&i..) %then %do;
				%let result = WARN;
				%let reason = &badstr. &values occur at a concerning rate (>&&warn&i..%).;
			%end;
			%let title6=&result.: &reason.;
		%end;
	%end; /*P/W/F checks end;*/
	%else %do;
		%let title6=;
		%let result=;
	%end;

	*all cat/xcat/freq/miss:;
	proc sort data=ds&i.;
		by 
		%if &&chk&i.. = cax %then %do; _c_&i.  %end;
		%if &&blen&i.. ne %then %do; _b_&i. %end; 
		_v_&i.;
	run;
	data ds;
		set ds&i. end=eof;
		if freq<&lowest_count then delete;
	run;
	proc freq data=ds noprint;
		%if &&chk&i.. ne cax and &&blen&i.. ne %then %do;
		by _b_&i.;
		%end;
		tables 
			%if &&chk&i..=cax %then %do;
			_c_&i. * _b_&i. *
			%end;
			_v_&i.
			/ missing out=ds;
		weight freq;
	run;
	data ds_&i.;
		merge ds&i. ds (in=i);
		by 
		%if &&chk&i.. = cax %then %do; _c_&i.  %end;
		%if &&blen&i.. ne %then %do; _b_&i. %end;
		_v_&i.;
		;
		if not i then do ;
			count=0;
			percent=0;
		end;
	run;
	data ds_&i.;
		set ds_&i.;
		bad = 0;
		%if&&chk&i.. = cat or &&chk&i.. = mis %then %do;
		if _v_&i. =: "&badstr." then bad=1;
		%end;
		%if &&chk&i.. = cax %then %do;
		if _c_&i. =: "&badstr." then bad=1;
		%end;
	run;
	proc sort data=ds_&i.;
		by 
			%if &&chk&i.. = cax %then %do;
			descending bad _c_&i. _b_&i. _v_&i.
			%end;
			%else %do;
			%if &&blen&i.. ne %then %do; _b_&i. %end; 
			descending bad _v_&i.
			%end;
		;
	run;
	%end; /*has obs*/
	%else %do; *no obs;
		%let result=N/A;
		%let reason=There are no records meeting the inclusion criteria in the dataset.;
		%let title6=&reason.;
	%end; /*end no obs*/




	data &&outds&i. (keep = 
					%if &&chk&i.. = mis %then %do;
					site memname variable &&byvar&i.. var_desc count percent warn_at fail_at result  %end;
					%else %if &&chk&i.. = cat %then %do;
					site memname variable &&byvar&i.. var_desc count percent warn_at fail_at result  %end;
					%else %if &&chk&i.. = fre %then %do;
					site memname &&byvar&i.. &&var&i.. count percent %end;
					%else %if &&chk&i.. = cax %then %do;
					site memname &&byvar&i.. &&var&i.. var_desc count percent warn_at fail_at result  %end;
					);
	length 
		site $4 memname $32 variable $32 
		&&byvar&i.. &&blen&i..
		&&var&i.. &&vlen&i.. 
		var_desc 	%if &nobs. %then %do; %if &&clen&i.. ne %then %do; &&clen&i.. %end; %else %do; &&vlen&i.. %end; %end;
				%else %do; $10 %end;
		count 8 percent 8 warn_at $17 fail_at $17 result $8
	;
	%if &nobs. %then %do; *if there were observations available for the check;
		set ds_&i.;


		var_desc =
			%if &&clen&i.. ne  %then %do;
			_c_&i.;
			%end;
			%else %do;
			_v_&i.;
			%end;
			
		&&var&i.. = _v_&i.;
			%if &&blen&i.. ne  %then %do;
		&&byvar&i.. = _b_&i.;
			%end;

	%end; /*end obs*/
	%else %do; *no observations;
		var_desc = 'No records';
		call missing(count,percent);
		call missing(&&var&i..);
			%if &&blen&i.. ne  %then %do;
		call missing(&&byvar&i..);
			%end;
	%end; /*end no obs*/

		site="&_siteabbr";
		memname = "&inname";  
		variable = "&&var&i.";
		if _n_=1 then do;
	    	if "&&warn&i."="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&&warn&i.";
	    	if "&&fail&i."="" then fail_at="No Fail Limit Set"; else fail_at=">"||"&&fail&i.";
			result="&result.";
		end;

		output;

		label
			site = "Site" 
			memname = "Table Name" 
			variable = "Variable Name"
	        Result = "Result"
			count="Count - Counts Less Than &lowest_count are Hidden"
        	percent="Percents are Recalculated If Counts are Hidden"
        	warn_at="Warning Issued If Percent of &badvalues. is"
        	fail_at="Fail Issued If Percent of &badvalues. is"
			var_desc = 
				%if &&chk&i.. = cax %then %do;   		"Combination" %end;  
				%else %if &&chk&i.. = mis %then %do; 	"Missingness of &&var&i.." %end;
				%else %do; "Value of &&var&i." %end;
			&&var&i.. = "&&var&i.."
			%if &&blen&i.. ne  %then %do;
			&&byvar&i.. = "&&byvar&i.."
			%end;
		;
	run;

	%if &&chk&i.. = cat or &&chk&i.. = cax or &&chk&i.. = mis %then %do; *P/W/F checks: DCO;
	data dco_feed;
	  length Site $4. MemName $32. VarName $32.
	  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41
				chk $8;
	  label site = "Site" memname = "Table Name" varname = "Variable Name"
	        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
	        OutDataSet = 'Data Set Containing Check Specifics' ;
	  memname = "&inname.";
	  varname = 
		  %if &&chk&i.. ne cax %then %do;
		  "&&var&i.";
		  %end;
		  %else %do;
		  subpad("&&var&i.._&&byvar&i..",1,32);
		  %end;
	  site="&_siteabbr";
	  check_description = 
		  %if &&chk&i.. = mis %then %do;
		  "Missing and Non-missing Rates"; %end;
		  %else %do;
		  "Expected and Unexpected Rates"; %end;
	  content_area="&content_area"; 
	  dateran=datetime();
	  version="&version";
	  chk = 
	  	  %if &&chk&i.. = mis %then %do;
		  "missing"; %end;
		  %else %do;
		  "category"; %end;
	  check=compress("&content_area._"||varname||'_'||chk||'_'||"Descriptive",' ');
	  outdataset=substr(upcase("&&outds&i."),index("&&outds&i.",'.')+1);
	  format dateran datetime.;
	  Reason = "&REASON";
	  result = "&result";
	  drop chk;
	run;
	%CESR_AppendDS(indataset=dco_feed);
	%end; /*P/W/F checks: DCO end;*/


	*all mis/freq/cat/xcat again:;
	*print report;
		*for titles;
		%if &&byvar&i.. ne and &&chk&i.. ne cax %then %let by = %str( by &&byvar&i..);
		%else %let by=;

	title5
		%if "&&titl&i.." ne "" %then %do;
		"&&titl&i.."
		%end;
		%else %if &&chk&i.. = fre %then %do;
		"Distribution of Values of &&var&i..&by. in table %upcase(&indataset.)";
		%end;
		%else %do;
		"Check: Rate of occurrence of &badstr. &values&by. in table %upcase(&indataset.)";
		%end;
		;

		%if "&title6." ne "" %then %do;
	title6 "&title6.";
		%end;

		%if &&mis&i.=N %then %do;
	title7 "Records with missing values of &&var&i.. are excluded from analysis.";
		%end;
		%else %if &&mis&i.=Y %then %do;
	title7 "Missing values are included in analysis.";
		%end;
		%if "&&if&i.." ne "" %then %do;
	title8 "Inclusion Criteria: &&if&i..";
		%end;
		%if &&bymiss&i.. %then %do;
	title9 "Variable &&byvar&i.. is not in the dataset and was imputed as missing.";
		%end;



	*footnote;
		%if "&&foot&i.." ne "" %then %do; 
	footnote3 "&&foot&i.."; 
		%end;
	footnote4 "Hidden indicates a count less than &lowest_count..";
	footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
	footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
		%if "&&ndis&i.." ne "" %then %do;
	footnote7 "Only the first &&ndis&i.. values are displayed. Please refer to &&outds&i.. for the full list of values.";
		%end;
		%if "&&locds&i.." ne "" %then %do;
			%if &&nloc&i.. ne %then %let upto=%str(Up to &&nloc&i.. );
			%else %let upto=&&nloc&i..;
	footnote8 "&upto.Records with &badstr. &values. are stored in &&locds&i...";
		%end;

	ods proclabel = 
		%if "&&label&i.." ne "" %then %do; "&&label&i.." %end;
		%else %if &&chk&i.. = fre %then %do;
		"Frequency of values of &&var&i..&by." 
		%end;
		%else %if &&chk&i.. = mis %then %do;
		"Missingness of &&var&i..&by."
		%end;
		%else %do;
		"Expected and unexpected &values.&by";
		%end;
	;

	%if "&&ndis&i.." ne "" and if &&chk&i.. = fre %then %do; *var freq with limited display number: sort by descending frequency;
	proc sort data=&&outds&i.. out=ds;
		by descending count;
	run;
	%end;
	%else %do;
	data ds;
		set &&outds&i..;
		%if &&chk&i.. ne cax and &&blen&i.. ne %then %do;
		by &&byvar&i.. ;
		if not first.&&byvar&i.. then call missing(&&byvar&i..);
		%end;
	run;
	%end;

	proc print data=ds 
		%if "&&ndis&i.." ne "" %then %do; (obs=&&ndis&i..) %end; 
		noobs label;
		var
		site memname
		&&byvar&i..
		%if &&chk&i.. = fre or &&chk&i.. = cax %then %do; &&var&i.. %end;
		%if &&chk&i.. = mis  or &&chk&i.. = cax or &&chk&i.. = cat %then %do; var_desc %end;
		count percent
		%if &&chk&i.. ne fre %then %do; warn_at fail_at result %end;
		;
		%if &&chk&i.. ne cax and &&blen&i.. ne %then %do;
		label percent="Percent within &&byvar&i..";
		%end;
		format count hide.;
	run;

	%end; /*cat/mis/cax/fre end*/

	%else %if &&chk&i.. = dat or &&chk&i.. = tim %then %do; /*trends*/
	*assess whether there are records to process;
	proc sql noprint;
		select count(*) into: nobs from ds&i.;
		select count(_v_&i.) into: nobs_nonmiss from ds&i.;
	quit;
	%if &&chk&i.. = dat %then %do;
		%if %upcase(&&fmt&i..) = YEAR. %then %do;
			%let __f1 = year. ; 
			%let _scale1 = %str(interval = YEAR) minor; 
			%let _t1 = year. ;
		%end;
		%else %do;
			%let __f1 = monyy7. ;
			%let _scale1 = %str(interval = QUARTER) minor;
			%let _t1 = monyy5. ;
		%end;

		%let 	__f2 = year. ;
		%let	_scale2 = %str(interval = YEAR) minor;
		%let 	_t2 = year. ;
	%end;
	%else %do;
		%if %upcase(&&fmt&i..) = H. %then %do;
			%let 	__f1 = h. ;
			%let 	_t1 = h. ;
		%end;
		%else %do;
			%let 	__f1 = timeampm. ;
			%let 	_t1 = hhmm. ;
		%end;
		%let	_scale1 = %str(values= %( 0 to 86399 by 3600 %) );
		%let 	__f2 = h. ;
		%let	_scale2 = %str(values= %( 0 to 86399 by 3600 %) );
		%let 	_t2 = h. ;
	%end;

	*Summarize data;
	%if &nobs. %then %do; /*if there are observations*/ 
		data ds&i.;
			set ds&i. ;
			%if &&chk&i.. = tim %then %do; *round to 5 minute intervals for time variables;
			if not missing(_v_&i.) then do;
			_v_&i. = _v_&i. - mod(_v_&i., 5*60);
			end;
			%end;
		run;
	  *overall;
		proc summary data=ds&i. nway;
			class _v_&i. / missing;
			var freq;
			output out=ds&i._all sum(freq)=count;
			format _v_&i. &__f1. ;
		run;
	 *by;
		%if &&byvar&i.. ne  %then %do;
		proc summary data=ds&i. nway;
			class _b_&i. _v_&i. / missing;
			var freq;
			output out=ds&i._by sum(freq)=count;
			format _v_&i. &__f2. ;
		run;
		%end;
	%end; /*end obs*/

	*apply suppression and create output file;
	  *overall;
		data &&outds&i.. ;
			length site $4 type $8 &&byvar&i.. &&blen&i.. &&var&i.. &&vlen&i.. count 8;

		%if &nobs. %then %do; /*if there are observations*/
			set 
				ds&i._all (in = inall)
			%if &&byvar&i.. ne  %then %do;
				ds&i._by (in = inby)
			%end;
			;

			retain site "&_siteabbr.";

			if count < &lowest_count then count=0;

			if inall then do;
				%if &&fmt&i.. ne .. %then %do; /* if overall output is not suppressed by . as format in parameter file*/
					type = "OVERALL";
					if not missing(_v_&i.) then &&var&i.. = mdy(month(_v_&i.),1,year(_v_&i.));
					else call missing(&&var&i..);
				%end;
				%else %do;
					delete;
				%end;
			end;
			%if &&byvar&i.. ne  %then %do; /*if byvariable is present*/
			if inby then do;
				type = "BY";
				if not missing(_v_&i.) then &&var&i.. = mdy(1,1,year(_v_&i.));
				else call missing(&&var&i..);
				&&byvar&i.. = _b_&i.;
			end;
			%end;
		%end;
		%else %do; /*if there are none*/
			call missing (of _all_);
			%if &&fmt&i.. ne .. %then %do; /* if overall output is not suppressed by . as format in parameter file*/
			type="OVERALL"; output;
			%end;
			%if &&byvar&i.. ne  %then %do; /*if byvariable is present*/
			type = "BY"; output;
			%end;
		%end;

			format &&var&i.. yymmdd10.;
			keep site type &&byvar&i.. &&var&i..  count ;
		run;


	*graph;
		title5 
		%if "&&titl&i.." ne "" %then %do; "&&titl&i.."; %end;
		%else %do;
		"Distribution of &&var&i..";
		%end;
/*		%if &&chk&i.. = tim %then %do; */
/*		title6 "Rounded down to 5 minute intervals";*/
/*		%end;		*/
		%if &nobs. = 0 %then %do;
		title6 "There were no records meeting the inclusion criteria.";
		%end;
		%if "&&if&i.." ne "" %then %do;
		title8 "Inclusion Criteria: &&if&i..";
		%end;
		%if "&&foot&i.." ne "" %then %do; 
			footnote3 "&&foot&i.."; 
		%end;		
		ods proclabel = 
		%if "&&label&i.." ne "" %then %do; "&&label&i.."; %end;
		%else %do; "Distribution of &&var&i.."; %end;

	*overall;
		%if &nobs_nonmiss. and &&fmt&i.. ne .. %then %do;
		proc sgplot data=&&outds&i..;
			where &&var&i.. ne . and type='OVERALL';
			xaxis &_scale1. tickvalueformat = &_t1.;
			series x = &&var&i.. y = count 
					;
			label 	&&var&i.. = "&&var&i.." 
					count='Count' 
			;
		quit;
		%end;
		%else %do;
		proc print data=&&outds&i.. label noobs;
		where type='OVERALL';
		var site  &&var&i..  count ;
			label 	&&var&i.. = "&&var&i.." 
					count='Count' 
					site = 'Site'
					type = ''
					;
				format count hide.;
		run;
		%end;

	  *by-variable;
		%if &&byvar&i.. ne %then %do;

		title5 
			%if "&&titl&i.." ne "" %then %do; "&&titl&i.. - by &&byvar&i.."; %end;
			%else %do; "Distribution of &&var&i.. - by &&byvar&i.."; %end;
		%if &nobs. = 0 %then %do;
		title6 "There were no records meeting the inclusion criteria.";
		%end;
		%if "&&if&i.." ne "" %then %do;
		title8 "Inclusion Criteria: &&if&i..";
		%end;
		%if &&bymiss&i.. %then %do;
		title9 "Variable &&byvar&i.. is not in the dataset and was imputed as missing.";
		%end;

		%if "&&foot&i.." ne "" %then %do; 
			footnote3 "&&foot&i.."; 
		%end;		
		ods proclabel = 
		%if "&&label&i.." ne "" %then %do; "&&label&i.. - by &&byvar&i.."; %end;
		%else %do; "Distribution of &&var&i.. - by &&byvar&i.."; %end;

		%if &nobs. %then %do;
		proc sgplot data=&&outds&i..;
			where &&var&i.. ne . and type='BY';
			xaxis &_scale2. tickvalueformat = &_t2.;
			series x = &&var&i.. y = count 
				/ group = &&byvar&i..
					;
			label 	&&var&i.. = "&&var&i.." 
					count='Count' 
					&&byvar&i.. = "&&byvar&i.." 
			;
		quit;
		%end;
		%else %do;
		proc print data=&&outds&i.. label noobs;
		where type='BY';
		var site &&byvar&i..  &&var&i..  count ;
			label 	&&var&i.. = "&&var&i.." 
					count='Count' 
					&&byvar&i.. = "&&byvar&i.." 
					site='Site'
			;
			format count hide.;
		run;
		%end;


		%end; /*end byvariable*/

	%end; /*trends end*/

	*clean up helper datasets;
	%if &&chk&i.. ne smp and &&chk&i.. ne sub and &&chk&i.. ne obs %then %do;
	proc datasets nolist;
	*delete ds&i. ds_&i. ds&i._: summary;
	run;
	quit;
	%end;

%end; /*if inds end;*/
%else %do; /*not in dataset;*/

		%let nobs=0;

		%if &&byvar&i.. ne  %then %do;
			%let by = %str( by &&byvar&i..);
		%end;
		%if &&bymiss&i.. or &&chk&i.. = cax %then %do;
			%let orby = %str( or &&byvar&i..);
		%end;
		%else %do;
			%let by=;
			%let orby=;
		%end;

	%if &&chk&i..=cat or &&chk&i..=cax or &&chk&i..=fre or &&chk&i..=mis %then %do; *cat/xcat/freq/miss, notinds;
	
	data &&outds&i.. (keep = 
					%if &&chk&i.. = mis %then %do;
					site memname variable &&byvar&i.. var_desc count percent warn_at fail_at result  %end;
					%else %if &&chk&i.. = cat %then %do;
					site memname variable &&byvar&i.. var_desc count percent warn_at fail_at result  %end;
					%else %if &&chk&i.. = fre %then %do;
					site memname &&byvar&i.. &&var&i.. count percent %end;
					%else %if &&chk&i.. = cax %then %do;
					site memname &&byvar&i.. &&var&i.. var_desc count percent warn_at fail_at result  %end;
					);
	length 
		site $4 memname $32 variable $32 
		&&byvar&i.. &&blen&i..
		&&var&i.. &&vlen&i.. 
		var_desc 	$13
		count 8 percent 8 warn_at $17 fail_at $17 result $8
	;
		var_desc = "Doesn't Exist";
		call missing(&&var&i..,count,percent);
			%if &&blen&i.. ne  %then %do;
		call missing(&&byvar&i..);
			%end;

		result="N/A";
		reason="Variable &&var&i..&orby. does not exist in &indataset..";
		site="&_siteabbr";
		memname = "&inname";  
		variable = "&&var&i.";
	    if "&&warn&i."="" then warn_at="No Warn Limit Set"; else warn_at=">"||"&&warn&i.";
	    if "&&fail&i."="" then fail_at="No Fail Limit Set"; else fail_at=">"||"&&fail&i.";

		output;

		label
			site = "Site" 
			memname = "Table Name" 
			variable = "Variable Name"
	        Result = "Result"
			count="Count - Counts Less Than &lowest_count are Hidden"
        	percent="Percents are Recalculated If Counts are Hidden"
        	warn_at="Warning Issued If Percent of &badvalues. is"
        	fail_at="Fail Issued If Percent of &badvalues. is"
			var_desc = 
				%if &&chk&i.. = cax %then %do;   		"Combination" %end;  
				%else %if &&chk&i.. = mis %then %do; 	"Missingness of &&var&i.." %end;
				%else %do; "Value of &&var&i." %end;
			&&var&i.. = "&&var&i.."
			%if &&blen&i.. ne  %then %do;
			&&byvar&i.. = "&&byvar&i.."
			%end;
		;
	run;


	%if &&chk&i.. = cat or &&chk&i.. = cax or &&chk&i.. = mis %then %do; *P/W/F checks: DCO;
	data dco_feed;
	  length Site $4. MemName $32. VarName $32.
	  		 Check_description $256. Result $8. Reason $256. DateRan 8. Version $4. Content_Area $8. Check $120. OutDataSet $ 41.
				chk $8;
	  label site = "Site" memname = "Table Name" varname = "Variable Name"
	        check = "Check Name" Result = "Result" Reason = "Reason" content_area = "Content Area Being QAed" 
	        dateran = "Date/Time Program Ran" version = "VDW Version" Check_Description = "Check Performed" 
	        OutDataSet = 'Data Set Containing Check Specifics' ;
	  memname = "&inname.";
	  varname = 
		  %if &&chk&i.. ne cax %then %do;
		  "&&var&i.";
		  %end;
		  %else %do;
		  subpad("&&var&i.._&&byvar&i..",1,32);
		  %end;
	  site="&_siteabbr";
	  check_description = 
		  %if &&chk&i.. = mis %then %do;
		  "Missing and Non-missing Rates"; %end;
		  %else %do;
		  "Expected and Unexpected Rates"; %end;
	  content_area="&content_area"; 
	  dateran=datetime();
	  version="&version";
	  chk = 
	  	  %if &&chk&i.. = mis %then %do;
		  "missing"; %end;
		  %else %do;
		  "category"; %end;
	  check=compress("&content_area._"||varname||'_'||chk||'_'||"Descriptive",' ');
	  outdataset=substr(upcase("&&outds&i."),index("&&outds&i.",'.')+1);
	  format dateran datetime.;
	  Reason = "Variable &&var&i..&orby. does not exist in &indataset..";
	  result = "N/A";
	  drop chk;
	run;
	%CESR_AppendDS(indataset=dco_feed);
	%end; /*P/W/F checks: DCO end;*/
	
	*report;
	title5
		%if "&&titl&i.." ne "" %then %do;
		"&&titl&i.."
		%end;
		%else %if &&chk&i.. = fre %then %do;
		"Distribution of Values of &&var&i..&by. in table %upcase(&indataset.)";
		%end;
		%else %do;
		"Check: Rate of occurrence of &badstr. &values&by. in table %upcase(&indataset.)";
		%end;
		;

	title6 
		"Variable &&var&i..&orby. does not exist in &indataset.."
	;

		%if &&mis&i.=N %then %do;
	title7 "Records with missing values of &&var&i.. are excluded from analysis.";
		%end;
		%else %if &&mis&i.=Y %then %do;
	title7 "Missing values are included in analysis.";
		%end;

	*footnote;
		%if "&&foot&i.." ne "" %then %do; 
	footnote3 "&&foot&i.."; 
		%end;
	footnote4 "Hidden indicates a count less than &lowest_count..";
	footnote5 "FIRST comparisons are made to the fail and warn percentage cutoff values."; 
	footnote6 "THEN counts less than &lowest_count are hidden and percentages are recalculated.";
		%if "&&ndis&i.." ne "" %then %do;
	footnote7 "Only the first &&ndis&i.. values are displayed. Please refer to &&outds&i.. for the full list of values.";
		%end;
		%if "&&locds&i.." ne "" %then %do;
			%if &&nloc&i.. ne %then %let upto=%str(Up to &&nloc&i.. );
			%else %let upto=&&nloc&i..;
	footnote8 "&upto.Records with &badstr. &values. are stored in &&locds&i...";
		%end;

	ods proclabel = 
		%if "&&label&i.." ne "" %then %do; "&&label&i.." %end;
		%else %if &&chk&i.. = fre %then %do;
		"Frequency of values of &&var&i..&by." 
		%end;
		%else %if &&chk&i.. = mis %then %do;
		"Missingness of &&var&i..&by."
		%end;
		%else %do;
		"Expected and unexpected &values.&by";
		%end;
	;

	proc print data = &&outds&i..  noobs label;
		var
		site memname
		%if &&chk&i.. = fre or &&chk&i.. = cax %then %do; &&var&i.. %end;
		%if &&chk&i.. = cat or &&chk&i.. = mis  %then %do; var_desc %end;
		&&byvar&i..
		%if &&chk&i.. = cax %then %do; var_desc %end;
		count percent
		%if &&chk&i.. ne fre %then %do; warn_at fail_at result %end;
		;
	run;

	%end;
	%else %if &&chk&i..=dat or &&chk&i..=tim %then %do; *trend, notinds;
		data &&outds&i.. ;
			length site $4 type $8 &&byvar&i.. &&blen&i.. &&var&i.. &&vlen&i.. count 8;
			;

			call missing(of _all_);
			site = "&_siteabbr.";

			%if &&fmt&i.. ne .. %then %do; /*if overall requested*/
			type = "OVERALL";
			output;
			%end;

			%if &&byvar&i.. ne  %then %do;
			type = "BY";
			output;
			%end;

			format &&var&i.. yymmdd10.;
			keep site type &&byvar&i.. &&var&i..  count ;
		run;


	*report;
	  *overall;
		%if "&&titl&i.." ne "" %then %do; 
		title4 "&&titl&i.."; 
		%end;
		%else %do;
		title4 "Distribution of &&var&i..";
		%end;
		title5 "The variable &&var&i..&orby. does not exist in &indataset..";

		%if "&&foot&i.." ne "" %then %do; 
			footnote3 "&&foot&i.."; 
		%end;		

		%if "&&label&i.." ne "" %then %do; 
		ods proclabel ="&&label&i.."; 
		%end;
		%else %do; 
		ods proclabel = "Distribution of &&var&i.."; 
		%end;

		%if &&fmt&i.. ne .. %then %do; /*if overall requested*/
		proc print data=&&outds&i.. noobs label;
			where type='OVERALL';
		run;
		%end;

	  *by-variable;
		%if &&byvar&i.. ne %then %do;

		%if "&&titl&i.." ne "" %then %do; 
			title4 "&&titl&i.. - by &&byvar&i.."; 
		%end;
		%else %do;
		title4 "Distribution of &&var&i.. - by &&byvar&i..";
		%end;
		%if "&&foot&i.." ne "" %then %do; 
			footnote3 "&&foot&i.."; 
		%end;		
		title5 "The variable &&var&i.. does not exist in &indataset..";

		%if "&&label&i.." ne "" %then %do; 
		ods proclabel ="&&label&i.. - by &&byvar&i.."; 
		%end;
		%else %do; 
		ods proclabel = "Distribution of &&var&i.. - by &&byvar&i.."; 
		%end;
		proc print data=&&outds&i.. noobs label;
			where type='BY';
		run;
		%end;
	%end;
%end; /*no inds end;*/

footnote3;
title5;

%end; /*cycle through checks end;*/

proc datasets nolist;
	delete f s dscontents;
run;
quit;

%mend CESR_VLC_MULTICHECK2;


****************************** CESR_VLC_MULTICHECK2 ***************************
****************************** CESR_VLC_MULTICHECK2 ***************************;







