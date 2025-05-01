/*******************************************************************************************/
/***PROGRAM: Quickstart-CODI_APQ_ZCTA3.SAS						 ***/
/***VERSION: 2.0 									 ***/
/***AUTHOR: SCOTT CAMPBELL (NORC)							 ***/
/***MODIFIED BY: DEVI CHELLURI (NORC) and ERIN TANENBAUM (NORC)				 ***/
/***DATE CREATED: 10/15/2019, DATE LAST MOD: 12/8/2021					 ***/
/***INPUT: PREPROCESSED ADULT OBESITY EHR DATA 						 ***/
/***INPUT: AMERICAN COMMUNITY SURVEY (ACS) DATA 					 ***/
/***INPUT: USER SELECTION CRITERIA (SECTIONS 1 THROUGH 5 BELOW), 	  	         ***/
/***OUTPUT: PREVALENCE ESTIMATES BASED ON SELECTION CRITERIA.				 ***/
/***OBJECTIVE: DATA AND USER SELECTIONS WILL BE USED TO QUERY THE OBESITY DATA. 	 ***/
/***OBJECTIVE: PROGRAM COMPUTES STATISTICAL WEIGHTS, AND GENERATES 			 ***/
/***OBJECTIVE: WEIGHTED AND UNWEIGHTED OBESITY PREVALENCE ESTIMATES  			 ***/
/***PREVALENCE ESTIMATES STORE: IN A COMMA SEPERATED VALUE (CSV) FILE OR EXCEL (XLS) FILE***/
/*******************************************************************************************/

/*************************************************************************************************************************************/
/***************************************** -- USER SELECTION CRITERA SECTIONS 1 through 5 -- *****************************************/
/******************* -- PLEASE UPDATE THE BLACK TEXT AFTER THE EQUAL SIGN (ACCEPTED VALUES LISTED IN SAS NOTE) -- ********************/
/*SECTION 1: Folder and file names									  													   		   ***/
/***/ %LET ROOT_PQ		= P:\Example;	  /*@Note: base directory (ACCEPTABLE VALUES: computer directory name)		   		   ***/
/***/ %LET PRE_DEST		= CODI_APQ; 	  /*@Note: Suffix name of pre-processing output folder (ACCEPTABLE VALUES: folder name (no punctuations)) ***/
/***/ %LET EHR_PRE_OUT	= CODI_APQ_ZCTA3; 	  /*@Note: Suffix name of pre-processing output file (ACCEPTABLE VALUES: file name (no punctuations)) ***/
/***/ %LET LOG_NAME		= CODI_APQ_ZCTA3; /*@Note: Name for SAS log storage location            				***/
/***/ %LET FileOUT_Name    = FILENAME; 		  /*@Note: Output file name; MUST BE FEWER THAN 28 CHARACTERS				 ***/

/*SECTION 2: Subset data based on specifications INCLUDING YEAR, GEOGRAPHY, STATE OR STATE/COUNTY CODE		***/
/***/ %LET BEG_YEAR		 = 2017;  /*@Note: Beginning year of analysis	(ACCEPTED VALUES: 4-Digit year from EHR) ***/
/***/ %LET END_YEAR		 = 2017;  /*@Note: End year of analysis 	(ACCEPTED VALUES: 4-Digit year from EHR) ***/
/***/ %LET ALL_STATES	 = N;  	  /*@Note: Include all geographical locations in file?	 (ACCEPTED VALUES: Y/N) ***/
/***/ %LET ALL_AGES		 = Y;	  /*@Note: Include all age ranges? 		 (ACCEPTED VALUES: Y/N) ***/
/***/ %LET ALL_SEXES	 = Y;	  /*@Note: Include all sex values? 		 	 (ACCEPTED VALUES: Y/N) ***/
/***/ %LET ALL_RACES	 = Y; 	  /*@Note: Include all race categories? 		 (ACCEPTED VALUES: Y/N)	***/

/*SECTION 3: Additional flags									  													   		   ***/
/***/ %LET ACSCOUNTY   = N; 		/*@Note: Is the ACS data at the county (Y) or ZCTA3 (N) level? (ACCEPTABLE VALUES: Y for County level data, N for ZCTA3 level data) ***/ 
/***/ %LET INCLUDE_PREGNANCY = Y; 	/*@Note: Include non-pregnant and pregnant individuals? (Y) or non-pregnant individuals only? (N)   (ACCEPTED VALUES: Y/N)		   				   ***/
/***/ %LET SAMPLE_CHECK = Y; 		/*@Note: Run check for sufficient sample size of query  (ACCEPTED VALUES: Y/N)		 ***/
/***/ %LET CO_OCCURRING = N; 	  	/*@Note: Include co-occurring conditions 		(ACCEPTED VALUES: Y/N)	***/
/***/ %LET CO_OCCURRING_COND_VAR =DIABETES_SPECTRUM; /*@Note: Include co-occurring condition variable/field/column name***/

/*SECTION 4: Only complete section 4 for any "N" values listed in section 2														   ***/
/*IF ALLGEOGRAPHIES= N THEN SELECT STATE CODES OR STATE AND COUNTY CODES BELOW:													   ***/
	/***  (ACCEPTED VALUES: SINGLE QUOTES SURROUNDING 2 OR 5-Digit CODES w/ "," BETWEEN MULTIPLE SELECTIONS, ) 				  	   ***/
/*IF ALLSTATES = N THEN SELECT ONE OR MORE AGE CATEGORIES BELOW:															   ***/
	/***/ %LET GEO_GROUP  	 = ZCTA3; 	  /*@Note: Level of geography	(ACCEPTED VALUES: STATE, ZCTA3, or COUNTY)***/
	/***/ %LET GEO_LIST	 = %STR('12322'); /*@Note: IF GEO_GROUP="STATE" then populate with State FIPS code(s), If GEO_GROUP="ZCTA3" then populate with FIPS State+ZCTA3 code(s), ***/
							/*If Geo_Group="COUNTY" then populate with FIPS State+FIPS County code(s) (ACCEPTED VALUES: 2-digit state FIPS or 5-digit state FIPS+ZCTA3 ***/
							/*or 5-digit state FIPS+county FIPS (Must be surrounded by single quotation and comma delimited))***/
/*IF ALL_AGES = N THEN SELECT ONE OR MORE AGE CATEGORIES BELOW:																   ***/
	/***/ %LET AGE_20_24 = Y;	 /*@Note: Age Range: 20 to 24	(ACCEPTED VALUES: Y/N) 			 	   	   ***/
	/***/ %LET AGE_25_29 = Y;	 /*@Note: Age Range: 25 to 29	(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET AGE_30_34 = Y;	 /*@Note: Age Range: 30 to 34	(ACCEPTED VALUES: Y/N) 			 	   	   ***/
	/***/ %LET AGE_35_44 = Y;	 /*@Note: Age Range: 35 to 44	(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET AGE_45_54 = Y;	 /*@Note: Age Range: 45 to 54	(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET AGE_55_64 = Y;	 /*@Note: Age Range: 55 to 64	(ACCEPTED VALUES: Y/N) 			 	       ***/
/*IF ALL_RACES = N THEN SELECT ONE OR MORE RACE BELOW:																		   ***/
	/***/ %LET RACE_WHITE = Y;	 /*@Note: White 		(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET RACE_BLACK = Y;	 /*@Note: Black/African American (ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET RACE_ASIAN = Y;	 /*@Note: Asian 		(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET RACE_OTHER = Y;	 /*@Note: Other			(ACCEPTED VALUES: Y/N)				       ***/
/*IF ALL_SEXES = N THEN SELECT MALE OR FEMALE BELOW:																		   ***/
	/***/ %LET SEX_MALE   = Y;	 /*@Note: Sex: Male 		(ACCEPTED VALUES: Y/N) 			 	       ***/
	/***/ %LET SEX_FEMALE = Y;	 /*@Note: Sex: Female 		(ACCEPTED VALUES: Y/N) 			 	       ***/

/*SECTION 5: Methodological option selections						  														***/
	/***/ %LET IMP_RACES     = N; 	 /*@Note: Include patients with imputed race values? Y = imputed and EHR provided race, N = EHR race only  (ACCEPTED VALUES: Y/N)***/
	/***/ %LET AGE_ADJ	 = Y;	 /*@Note: Produce age-adjusted estimates? (ACCEPTED VALUES: Y/N)***/
/*************************************************************************************************************************************/
/***Note: Root directory includes subfolders: 
								"..\0_Raw_Data" 
								"..\1_SAS_Programs"
								"..\2_Output" and 
								"..\2_Output\SAS LOGS"										   									   ***/
/***NOTE: SAS programs must be stored in the PROGS directory including: 
								Macro1-CODI_APQ.sas, 
								Macro2-CODI_APQ.sas, 
								Macro3-CODI_APQ.sas, 
								Macro4-CODI_APQ.sas, 
								Module1-CODI_APQ.sas,
								Module2-CODI_APQ.sas,
								Macro1-CODI_APQ-Co_occurring.sas, 
								Macro2-CODI_APQ-Co_occurring.sas, 
								Macro3-CODI_APQ-Co_occurring.sas, 
								Macro4-CODI_APQ-Co_occurring.sas, 
								Module1-CODI_APQ-Co_occurring.sas,
								Module2-CODI_APQ-Co_occurring.sas,																		   ***/
/***NOTE: query output is stored as a csv file in "..\2_Output" named after a time/date stamp and CODI_Prevalence_Query_Report     ***/
/*************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    */
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/














/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    */
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/











/*@Action: Set SAS options ***/
OPTIONS FULLSTIMER NOFMTERR MLOGIC MPRINT MINOPERATOR SYMBOLGEN COMPRESS=YES;
/***/ %LET PROGS_PQ		= &Root_PQ.\1_SAS_Programs\CODI_APQ_GEO3; /*@Note: Location of SAS programs (ACCEPTABLE VALUES: computer directory name)	***/

/*************************************************************************************************************************/
/******************************* -- ADDITIONAL INFORMATION REQUIRED BY PQ MODULE PROGRAMS -- *****************************/
/************************************** -- THIS INFORMATION IS TO REMAIN UNCHANGED -- ************************************/
/*************************************************************************************************************************/
/***/ %LET DateTime		   = %SYSFUNC(Translate(%Quote(%SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Datetime(),DateAMPM.))))),%Str(___),%Str( ,:))); /*@Note: Date time of SAS run, DO NOT CHANGE ***/
/***/ %LET DateTime2	   = %SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Today(),Weekdate.) %SYSFUNC(Time(), timeampm.)))); /*@Note: Date and time of run (Report Output) ***/
/***/ %LET FileIN_Name1	   = Pre_Processed_&EHR_PRE_OUT.;  		 		  	  /*@Note: EHR Data file name			   					   			  ***/

%Macro Filename();
	%Global FileIN_Name2;
	%If &ACSCOUNTY.=N %Then %Do;
		/***/ %LET FileIN_Name2	   = ACS_State_ZCTA3;			   /*@Note: ACS file name					   				   ***/
	%End;
	%Else %Do;
		/***/ %LET FileIN_Name2	   = ACS_State_County;			   /*@Note: ACS file name					   				   ***/
	%End;		
%Mend;

%Filename();

/***/ %LET ACS_Module      = Macro1-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of ACS Controls SAS Macro	   				   			  ***/
/***/ %LET Weight_Module   = Macro2-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of Weighting SAS Macro		   				   			  ***/
/***/ %LET Suppress_Module = Macro3-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of Output Supression SAS Macro 			   				  ***/
/***/ %LET Report_Module   = Macro4-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of Report Generation SAS Macro 			   				  ***/
/***/ %LET Query_Module	   = Module1-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of Query SAS Module		   				   				  ***/
/***/ %LET Estimate_Module = Module2-CODI_APQ_GEO3;		   		 		  	  /*@Note: Name of Estimate SAS Module		   				   			  ***/
/***/ %LET ACS_Module_Cooccur      = Macro1-CODI_APQ_GEO3-Co_occurring;  /*@Note: Name of ACS Controls SAS Macro for co-occurring conditions	  ***/
/***/ %LET Weight_Module_Cooccur   = Macro2-CODI_APQ_GEO3-Co_occurring;  /*@Note: Name of Weighting SAS Macro for co-occurring conditions		  ***/
/***/ %LET Suppress_Module_Cooccur = Macro3-CODI_APQ_GEO3-Co_occurring;  /*@Note: Name of Output Supression SAS Macro for co-occurring conditions ***/
/***/ %LET Report_Module_Cooccur   = Macro4-CODI_APQ_GEO3-Co_occurring;  /*@Note: Name of Report Generation SAS Macro for co-occurring conditions ***/
/***/ %LET Query_Module_Cooccur	= Module1-CODI_APQ_GEO3-Co_occurring; /*@Note: Name of Query SAS Module for co-occurring conditions		   	  ***/
/***/ %LET Estimate_Module_Cooccur = Module2-CODI_APQ_GEO3-Co_occurring; /*@Note: Name of Estimate SAS Module for co-occurring conditions		  ***/
/***/ %Let WGTCELL_MIN	   = 20; 						       /*@Note: Minimum allowed weighting cell count for collapsing weighting characteristics ***/
/*************************************************************************************************************************/

/*@Action: Begin SAS Log output ***/
SYSTASK COMMAND "MKDIR ""&Root_PQ.\2_Output\SAS LOG""" WAIT;
Proc Printto Log="&Root_PQ.\2_Output\SAS LOG\&Log_Name._&DateTime..log" New; Run;

/*@Action: Initialize SAS Libraries ***/
SYSTASK COMMAND "MKDIR ""&Root_PQ.\2_Output""" WAIT;
Libname SASIN "&Root_PQ.\2_Output\Pre_processed_&PRE_DEST." Access=Readonly;

/*@Action: Load SAS macro routines needed by module programs depending on which version if co-occurring conditions should be used***/
%Macro Cooccurring();
	%If &CO_OCCURRING.=N %Then %Do;
		%Include "&PROGS_PQ.\&ACS_Module..sas" / LRECL = 500; 	   /*@Note: Compute ACS control totals for requested domain ***/
		%Include "&PROGS_PQ.\&Weight_Module..sas" / LRECL = 500;   /*@Note: Weighting: Iterative Proportional Weighting (Raking) & Age Adjustment ***/
		%Include "&PROGS_PQ.\&Suppress_Module..sas" / LRECL = 500; /*@Note: Supression: Output suppression, following NCHS guidelines ***/
		%Include "&PROGS_PQ.\&Report_Module..sas" / LRECL = 500;   /*@Note: Report Generation: Report creation and output module ***/
		%Include "&PROGS_PQ.\&Query_Module..sas" / LRECL = 500;    /*@Note: Load Query Module ***/
	%End;
	%Else %Do;
		%Include "&PROGS_PQ.\&ACS_Module_Cooccur..sas" / LRECL = 500; 	   /*@Note: Compute ACS control totals for requested domain ***/
		%Include "&PROGS_PQ.\&Weight_Module_Cooccur..sas" / LRECL = 500;   /*@Note: Weighting: Iterative Proportional Weighting (Raking) & Age Adjustment ***/
		%Include "&PROGS_PQ.\&Suppress_Module_Cooccur..sas" / LRECL = 500; /*@Note: Supression: Output suppression, following NCHS guidelines ***/
		%Include "&PROGS_PQ.\&Report_Module_Cooccur..sas" / LRECL = 500;   /*@Note: Report Generation: Report creation and output module ***/
		%Include "&PROGS_PQ.\&Query_Module_Cooccur..sas" / LRECL = 500;    /*@Note: Load Query Module ***/
	%End;
%mend;

%Cooccurring();		

/*@Action: Load Census 2000 Age Distribution for Age Adjustment ***/
Data Census_2000;
	length Age_Group $7;
	infile datalines delimiter=",";
	input Age_Group $ Pct2000;
datalines;
20 - 24, 0.113298995
25 - 29, 0.1099789
30 - 34, 0.121081048
35 - 44, 0.277144098
45 - 54, 0.229800174
55 - 64, 0.148696785
;
Run;

/*@Action: Create formats for collapsing of groups ***/
Proc Format;
	Value $Age_1_C "20 - 24" = "1"
				   "25 - 29" = "1"
				   other = " "
				   ;
	Value $Age_2_C "25 - 29" = "2"
				   "30 - 34" = "2"
				   other   = " "
				   ;
	Value $Age_3_C "30 - 34" = "3"
				   "35 - 44" = "3"
				   other   = " "
				   ;
	Value $Age_4_C "35 - 44" = "4"
				   "45 - 54" = "4"
				   other   = " "
				   ;
	Value $Collapse_Age "1"   = "20 - 29"
					    "2"   = "25 - 34"
					    "3"   = "30 - 55"
					    "4"   = "35 - 54"
						other = " "
					    ;
Run;

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

data Prevalence_Begin_shell;
		length wgt_cat $50. co_occurring Sample_Cnt Est_Pop_Cnt Est_Prev 8.;
		infile datalines dlm="|" dsd;
		input Wgt_Cat $ co_occurring Sample_Cnt Est_Pop_Cnt Est_Prev;
		datalines;
(1) Underweight (BMI<18.5)|1|.|.|.
(2) Healthy Weight (18.5<=BMI<25)|1|.|.|.
(3) Overweight (25<=BMI<30)|1|.|.|.
(4) Obesity (Classes 1, 2, and 3) (BMI 30+)|1|.|.|.
(4a) Obesity (Class 1) (30<=BMI<35)|1|.|.|.
(4b) Obesity (Class 2) (35<=BMI<40)|1|.|.|.
(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)|1|.|.|.
(1) Underweight (BMI<18.5)|2|.|.|.
(2) Healthy Weight (18.5<=BMI<25)|2|.|.|.
(3) Overweight (25<=BMI<30)|2|.|.|.
(4) Obesity (Classes 1, 2, and 3) (BMI 30+)|2|.|.|.
(4a) Obesity (Class 1) (30<=BMI<35)|2|.|.|.
(4b) Obesity (Class 2) (35<=BMI<40)|2|.|.|.
(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)|2|.|.|.
(1) Underweight (BMI<18.5)|3|.|.|.
(2) Healthy Weight (18.5<=BMI<25)|3|.|.|.
(3) Overweight (25<=BMI<30)|3|.|.|.
(4) Obesity (Classes 1, 2, and 3) (BMI 30+)|3|.|.|.
(4a) Obesity (Class 1) (30<=BMI<35)|3|.|.|.
(4b) Obesity (Class 2) (35<=BMI<40)|3|.|.|.
(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)|3|.|.|.
;
run;

/*@Action: Begin algorithm process by progressing to -- Load Query Module ***/
%Macro Cooccurring2();
	%If &CO_OCCURRING.=N %Then %Do;
		%CODI_APQ;
	%End;
	%Else %Do;
		%CODI_APQ_COOCCUR;
	%End;
%mend;

%Cooccurring2();		

/****************************************************************************/

/*@Action: save weighted file to output folder***/
/*libname out "&Root_PQ.\2_Output";*/
/*data out.&FileOUT_Name._WGTS;*/
/*	set Weighted_USER_File;*/
/*run;*/

/*@Action Clear temporary work library ***/
Proc Datasets Library=WORK Kill;
Quit;

/*@Action: Halt SAS log output ***/
proc printto;
Run;
/*@Program End ***/
