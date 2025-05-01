/**************************************************************************************************/
/***PROGRAM: Quickstart-Pre_Processing_CODI_HPQ_GEO3.SAS					 			 		***/
/***VERSION: 1.0 															 			 		***/
/***AUTHOR: SHALIMA ZALSHA (NORC)														 		***/
/***DATE CREATED: 10/30/2021 															 		***/
/***LAST UPDATED: 12/22/2021																	***/
/***For more information visit https://github.com/NORC-UChicago/CODI-PQ							***/
/***INPUT: Pre-Processed American Community Survey - Person and Household Level by County (SAS) ***/
/***INPUT: Pre-Processed EHR SAS file (SAS)							   			   	 	 		***/
/***INPUT: USER SELECTION CRITERIA (SECTIONS 1 THROUGH 4 BELOW), 					     		***/
/***OUTPUT: PREVALENCE ESTIMATES BASED ON SELECTION CRITERIA.							 		***/
/***OBJECTIVE: DATA AND USER SELECTIONS WILL BE USED TO QUERY THE HOUSEHOLD OBESITY DATA.		***/
/***OBJECTIVE: PROGRAM COMPUTES STATISTICAL WEIGHTS, AND GENERATES 					 	 		***/
/***OBJECTIVE: WEIGHTED AND UNWEIGHTED HOUSEHOLD OBESITY PREVALENCE ESTIMATES  			 		***/
/***PREVALENCE ESTIMATES STORE: IN A COMMA SEPERATED VALUE (CSV) FILE					 		***/
/**************************************************************************************************/

/*************************************************************************************************************************************/
/***************************************** -- USER SELECTION CRITERA SECTIONS 1 through 5 -- *****************************************/
/******************* -- PLEASE UPDATE THE BLACK TEXT AFTER THE EQUAL SIGN (ACCEPTED VALUES LISTED IN SAS NOTE) -- ********************/
/*************************************************************************************************************************************/

/*SECTION 1: Folder and file names									  													   		   	***/
/***/ %LET ROOT_HPQ		= C:\Example;	/*@Note: base directory (ACCEPTABLE VALUES: computer directory name)		   		   ***/
/***/ %LET PRE_HDEST	= CODI_HPQ_PRE; /*@Note: Suffix name of pre-processing output folder (ACCEPTABLE VALUES: folder name (no punctuations)) ***/
/***/ %LET EHR_H_PRE_OUT= CODI_HPQ_Preprocessed_Filename; /*@Note: Suffix name of pre-processing output file (ACCEPTABLE VALUES: file name (no punctuations)) ***/
/***/ %LET LOG_NAME		= HPQ_EXAMPLE_LOG; /*@Note: Name for SAS log storage location            								   ***/
/***/ %LET FileOUT_Name = HPQ_EXAMPLE_OUTPUT_WIMPUTE; 	  	 /*@Note: Output file name				   			   					  ***/
 
/*SECTION 2: Subset data based on specifications INCLUDING YEAR, GEOGRAPHY, AGE, AND RACE		 ***/
/***/ %LET ALL_H_STATES	 = N;  	  /*@Note: EHRs file includes all of the US?	 (ACCEPTED VALUES: Y/N)		 ***/
/***/ %LET H_YEAR	 =  2019;  /*@Note: year of analysis											 ***/
/***/ %LET ALL_H_AGES	 = Y;	  /*@Note: Include all youth age ranges? (ACCEPTED VALUES: Y/N)				 ***/
/***/ %LET ALL_RACES	 = Y;	  /*@Note: Include all householder race categories? (ACCEPTED VALUES: Y/N)	 ***/

/*SECTION 3: Only complete section 3 for any "N" values listed in section 2														   ***/
/*IF ALL_H_STATES= N THEN SELECT STATE CODES OR STATE AND COUNTY CODES BELOW: ***/
/***/ %LET GEO_H_GROUP  = STATE; /*@Note: Level of geography (ACCEPTED VALUES: STATE or COUNTY)***/
/***/ %LET GEO_H_LIST	= %STR('08','37'); /*@Note: IF GEO_GROUP="STATE" then populate with State FIPS code(s), If GEO_GROUP="COUNTY" then populate with FIPS State+FIPS County code(s) (ACCEPTED VALUES: 2-digit state FIPS for STATE or 5-digit state FIPS+county FIPS for COUNTY (Must be surrounded by single quotation and comma delimited))***/

/*IF ALL_AGES = N THEN SELECT ONE OR MORE AGE CATEGORIES BELOW:																   ***/
	/***/ %LET AGE_UNDER_6 = Y;	 /*@Note: Children’s Age Range: include households that have kids under the age of 6, but do not have kids 6 to 17 years of age (ACCEPTED VALUES: Y/N) 			 	   	   ***/
	/***/ %LET AGE_6_17 = Y;	 /*@Note: Children’s Age Range: include households that have kids of age 6 or older, but do not have kids under the age of 6 (ACCEPTED VALUES: Y/N) ***/
	/***/ %LET AGE_BOTH = N;	 /*@Note: Children’s Age Range: include households that have 1) kids of age 6 or older, and also have 2) kids under the age of 6 (ACCEPTED VALUES: Y/N) ***/	
	     
/*IF ALL_RACES = N THEN SELECT ONE OR MORE RACE BELOW			   ***/
	/***/ %LET RACE_WHITE  = N;	 /*@Note: White (ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET RACE_BLACK  = Y;	 /*@Note: Black/African American ACCEPTED VALUES: Y/N) 	   ***/
	/***/ %LET RACE_ASIAN  = Y;	 /*@Note: Asian 		 (ACCEPTED VALUES: Y/N) 		   ***/
	/***/ %LET RACE_OTHER  = N;	 /*@Note: Other		 (ACCEPTED VALUES: Y/N)				   ***/

/*SECTION 4: Methodological option selections						  														   ***/
	/***/ %LET IMP_RACES = Y; 	 /*@Note: Include imputed race values? 				(ACCEPTED VALUES: Y/N)			 		   ***/

/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    */
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/

/*Note: subsection of the full program. Be sure to only edit this section but submit the full program. */


/***/ %LET PROGS_HPQ	= &ROOT_HPQ\1_SAS_Programs\CODI_HPQ_GEO3; 	/*@Note: Location of SAS programs, same as in pre-processing SAS programs (ACCEPTABLE VALUES: computer directory name)***/

/*@Action: Set SAS options ***/
OPTIONS FULLSTIMER NOFMTERR MLOGIC MPRINT MINOPERATOR SYMBOLGEN COMPRESS=YES VALIDVARNAME=ANY dlcreatedir;

/*@Action: Create SAS LOG Directory ***/
libname SASlog "&ROOT_HPQ\2_Output\SAS LOG";

/*@Action: Additional information needed by pre-processing algorithm loaded into SAS macro variables ***/
%LET DateTime  = %SYSFUNC(Translate(%Quote(%SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Today(),Weekdate.) %SYSFUNC(Time(), timeampm.))))),%Str(_),%Str( ,:))); /*@Note: Date time of SAS run, DO NOT CHANGE ***/
%LET DateTime2 = %SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Today(),Weekdate.) %SYSFUNC(Time(), timeampm.)))); /*@Note: Date and time of run (Report Output) ***/

SYSTASK COMMAND "MKDIR ""&ROOT_HPQ\2_Output\SAS LOG""" WAIT;
Proc Printto Log="&ROOT_HPQ\2_Output\SAS LOG\&LOG_NAME._&DateTime..log" New; Run;

libname SASin "&ROOT_HPQ\2_Output\&PRE_HDEST";
libname SASout "&ROOT_HPQ\2_Output";

/*@Action: Create and initiate messages and macro variables used in the messages*/
%let MSG_QUERY="CODI-HPQ GEO3 2021";
%let race_foot=;
%let RaceSupress_Foot=;
%let RaceImpute_Foot=;
%let HHAdultsSupress_Foot=;
%let age_foot=;
%let ChildageSupress_Foot=;
%let Geography_Foot=;
%let Year_Foot=;
%let Collapse_Foot=;
%let FailureCode=;
%let MSG_IG=;
%let MSG_QUERYDATE="&DateTime2.";
%let MSG_CITATION="Tanenbaum, E.,  Zalsha, S. (2021). Clinical and Community Data Initiative Household Prevalence Query (CODI-HPQ) SAS programs.";
%let MSG_NOTE1="The standard error calculations are documented in the Implementation Guide.";
%let MSG_NOTE2="The household estimates are based on American Community Survey Five-year Estimates.";


/*@Action: Create macro variables used in the messages*/
%let PCT_MISSINGRACE="EMPTY";

/* @Action: Suppress console output */
ods exclude all;

/*** Data Steps ****/

/*@Action: Estimation and Generate Report ***/
Data Prevalence_Begin_shell;
	length Order 3. 'Youth and Teens Weight Category'n $60. 'Adults Weight Category'n $60. Sample Population 'Sample %'n	'Sample % Standard Error'n	'Population %'n	'Population % Standard Error'n 8.;
	infile datalines dlm="," dsd;
	input Order 'Youth and Teens Weight Category'n $ 'Adults Weight Category'n $ Sample Population 'Sample %'n	'Sample % Standard Error'n	'Population %'n	'Population % Standard Error'n;
	datalines;
	1, No youth or teens with obesity, No adults with obesity, .,	.,	.,	.,	.,	.
	2, No youth or teens with obesity, One or more adults with obesity, .,	.,	.,	.,	.,	.
	3, One or more youth or teens with obesity,	No adults with obesity, .,	.,	.,	.,	.,	.
	4, One or more youth or teens with obesity,	One or more adults with obesity, .,	.,	.,	.,	.,	.
	;
run;
 

data Messages;
   length 'Youth and Teens Weight Category'n $ 300;
   input  Order 'Youth and Teens Weight Category'n $ &;
   datalines;
5 Query Version: 
6 Race: 
7 Race Suppressed: 
8 Imputed race: 
9 Number of Adults in Household Suppressed: 
10 Age of Children: 
11 Age of Children Suppressed: 
12 Geography: 
13 Year: 
14 Weighting cells were collapsed for: 
15 Error codes:
16 Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on calculations.
17 Query Date:
18 Suggested Citation: 
19 The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ after December 31, 2021
20 Patients with either missing or invalid age, sex, height, weight, or geography are not included in results
21 CODI-HPQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-HPQ methodology is appropriate for your use case when used outside of these date ranges.
;
run;

/*@Note: Literal text will be printed in report***/
Data FIPS_Codes;
	Input Start $ 1-2 Label $ 4-5 Full_Label $ 7-32;
	Datalines;
AL 01 (01) Alabama
AK 02 (02) Alaska
AZ 04 (04) Arizona
AR 05 (05) Arkansas
CA 06 (06) California
CO 08 (08) Colorado
CT 09 (09) Connecticut
DE 10 (10) Delware
DC 11 (11) District of Columbia
FL 12 (12) Florida
GA 13 (13) Georgia
HI 15 (15) Hawaii
ID 16 (16) Idaho
IL 17 (17) Illinois
IN 18 (18) Indiana
IA 19 (19) Iowa
KS 20 (20) Kansas
KY 21 (21) Kentucky
LA 22 (22) Louisiana
ME 23 (23) Maine
MD 24 (24) Maryland
MA 25 (25) Massachusetts
MI 26 (26) Michigan
MN 27 (27) Minnesota
MS 28 (28) Mississippi
MO 29 (29) Missouri
MT 30 (30) Montana
NE 31 (31) Nebraska
NV 32 (32) Nevada
NH 33 (33) New Hampshire
NJ 34 (34) New Jersey
NM 35 (35) New Mexico
NY 36 (36) New York
NC 37 (37) North Carolina
ND 38 (38) North Dakota
OH 39 (39) Ohio
OK 40 (40) Oklahoma
OR 41 (41) Oregon
PA 42 (42) Pennsylvania
RI 44 (44) Rhode Island
SC 45 (45) South Carolina
SD 46 (46) South Dakota
TN 47 (47) Tennessee
TX 48 (48) Texas
UT 49 (49) Utah
VT 50 (50) Vermont
VA 51 (51) Virginia
WA 53 (53) Washington
WV 54 (54) West Virginia
WI 55 (55) Wisconsin
WY 56 (56) Wyoming
;
Run;


/*** Begin data processing ***/

/*@Action: Read in ACS files */
Data ACS;
set SASin.acs_county;
run;

/*@Action: Read in Pre-processed EHR */
Data EHR0;
set SASin.&EHR_H_PRE_OUT;
run;


/*@Action: Call Macros ***/
%include "&PROGS_HPQ\Macro1-CODI_HPQ_GEO3.sas"; /*Raking Macro*/
%include "&PROGS_HPQ\Macro2-CODI_HPQ_GEO3.sas"; /*Suppression Macro*/

/** Input for Suppresion/Collapsing **/
%let WGTCELL_MIN=25; *leave this here;

/*@Action: Subsetting based on suppression, sample checks  ***/
%include "&PROGS_HPQ\Module1-CODI_HPQ_GEO3.sas";

/*@Action: Define convergence flag  ***/
%global	Convergence_pass;
%let Convergence_pass=0;

%Macro Generate_Report;

/*@Action: ACS Control Totals and Raking if no error ***/
%if &failureCode=None %then %do;
	%include "&PROGS_HPQ\Module2-CODI_HPQ_GEO3.sas";
%end;

/*@Action: Estimation if no error and raking converges***/
%if "&CONVERGENCE_PASS"="1" and %Eval(not((&FailureCode in(1 2 3 4 5)))) %Then %do;
	%include "&PROGS_HPQ\Module3-CODI_HPQ_GEO3.sas";
	/*@Action: Apply suppression criteria***/
	%Suppress(fileinest=USER_Prevalence_Estimates, fileinwgt=Weighted_USER_File, fileout=USER_Prevalence_Suppress);
%end;

/*@Action: Record failure code if raking does not converge***/
%else %if %Eval(&FailureCode=None and not(&CONVERGENCE_PASS=1)) %Then %let FailureCode=6;

/*@Action: Translate Error Message*/

%global Fail_Desc;
%If  &FailureCode.=1 %Then %Let Fail_Desc=One or more demographic or geographic category has no groups selected. One or more groups must be selected in each category. Please ensure each demographic and geographic category has one or more groups selected (e.g. children’s age, race).;
		%Else %If &FailureCode.=2 %Then %Let Fail_Desc=Year is out of scope or no year selected. CODI-HPQ was developed between 2019 and 2021, see Implementation Guide for more details.;
		%Else %If &FailureCode.=3 %Then %Let Fail_Desc=Geographic level (GEO_H_GROUP) has been left blank or has been set to an unacceptable value. To remedy issue, please update the GEO_H_GROUP variable to either STATE or COUNTY.;
		%Else %If &FailureCode.=4 %Then %Let Fail_Desc=%str(STATE and/or COUNTY is incorrectly specified. Review the lists and ensure each value is: Surrounded by quotations, Comma delimited, and/or The correct length (e.g., '08001', '08002', '08003', etc. for COUNTY  and '08', '37', etc. for STATE).);
		%Else %If &FailureCode.=5 %Then %Let Fail_Desc=Current selections return an insufficient number of patients and do not meet minimum threshold to estimate sample weights. Consider including additional demographic categories (e.g., races, age groups) or geographies.;
		%Else %If &FailureCode.=6 %Then %Let Fail_Desc=Iterative proportional fitting weighting routine has failed to converge. Please revise selections and rerun algorithm.;
		%Else %If &FailureCode.=None %Then %Let Fail_Desc=(&Suppress_Error.);
%Else %Let Fail_Desc=A SAS error has occurred within the algorithm. Review the SAS log or contact a system administrator for further assistance.;

/*@Action: Generate prevalence report*/
data messages;
length 'Youth and Teens Weight Category'n $ 420 argument $420 ;
set messages;
	if 	Order=5 then argument=&MSG_QUERY;
		else if order=6 then argument="&race_foot";
		else if order=7 then argument="&RaceSupress_Foot";
		else if order=8 then argument="&RaceImpute_Foot";
		else if order=9 then argument="&HHAdultsSupress_Foot";
		else if order=10 then argument="&age_foot" ;
		else if order=11 then argument="&ChildageSupress_Foot" ;
		else if order=12 then argument="&GEOGRAPHY_FOOT.";
		else if order=13 then argument="&YEAR_FOOT";
		else if order=14 then argument="&Collapse_Foot";
		else if order=15 then argument="&Fail_Desc.";
		else if order=17 then argument=&MSG_QUERYDATE;
		else if order=18 then argument=&MSG_CITATION;
		else if order=19 then argument=&MSG_NOTE1;
		else if order=20 then argument=&MSG_NOTE2;
		else argument="";
	'Youth and Teens Weight Category'n=strip(strip('Youth and Teens Weight Category'n)||" "||strip(argument));
	drop argument;
	format 'Youth and Teens Weight Category'n $420.; 
	run;

Data Prevalence_report;
	retain Order 'Youth and Teens Weight Category'n;
	length 'Youth and Teens Weight Category'n $420; 
/*@Action: Compile reports when fail*/
	%if &CONVERGENCE_PASS=1 and %Eval(not((&FailureCode in(0 1 2 3 4 5 6)))) %Then %do;
		set USER_Prevalence_Suppress messages;
	%end;
/*@Action: Compile reports when fail*/
	%else %do;
		set Prevalence_Begin_shell messages;
	%end;
		format 'Youth and Teens Weight Category'n $420.; 
run;
%Mend;
 
%Generate_Report;
 
proc export 
  data=Prevalence_report
  dbms=csv
  outfile="&ROOT_HPQ\2_Output\&FileOUT_Name..csv" 
  replace;
run;

/*@Action Clear temporary work library and all macro variables ***/
Proc Datasets Library=WORK Kill;
Quit;
%deleteAllMacroVars();
 
/*@Action: Halt SAS log output ***/
proc printto;
Run;

/* @Action: Cancel console output suprression */
ods exclude none;

/*** PROGRAM END ***/
