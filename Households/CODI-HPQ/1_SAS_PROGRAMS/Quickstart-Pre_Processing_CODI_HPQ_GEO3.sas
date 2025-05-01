/**************************************************************************************************/
/***PROGRAM: Quickstart-Pre_Processing_CODI_HPQ_GEO3.SAS					 					***/
/***VERSION: 1.0 															 					***/
/***AUTHOR: SHALIMA ZALSHA (NORC at the University of Chicago)									***/
/***For more information visit https://github.com/NORC-UChicago/CODI-PQ							***/
/***DATE CREATED: 11/30/2021, 												 					***/
/***LAST UPDATED: 12/22/2021																	***/
/***INPUT: American Community Survey - Person Level by County (CSV) 							***/
/***INPUT: American Community Survey - Household Level by County (CSV) 							***/
/***INPUT: EHR data file (CSV)														    		***/
/***OUTPUT: Pre-Processed American Community Survey - Person Level by County (SAS)	    		***/
/***OUTPUT: Pre-Processed American Community Survey - Household Level by County (SAS)   		***/
/***OUTPUT: Pre-Processed EHR SAS file (SAS)							   			   			***/
/***OBJECTIVE: PREPROCESSES HOUSEHOLD LEVEL CHILDHOOD and TEEN OBESITY EHR DATA 	   			***/
/***OBJECTIVE: PREPROCESSES ACS PERSON AND HOUSEHOLD LEVEL BY COUNTY DATA						***/
/***OBJECTIVE: IMPORT ACS 5-YEAR FILE - PERSON AND HOUSEHOLD LEVEL. APPLY FORMATS, EDITS AND 	***/
/***OBJECTIVE: CHECK FOR INCONSISTENCIES/MISSINGNESS. OUTPUT FILE INTO A SAS DATAFILE. 			***/
/***OBJECTIVE: REPEATS WITH EHR DATA												   			***/
/**************************************************************************************************/

/*************************************************************************************************************************************/
/***************************************** -- USER INPUT FOLDER -- *******************************************************************/
/******************* -- PLEASE UPDATE THE BLACK TEXT AFTER THE EQUAL SIGN (ACCEPTED VALUES LISTED IN SAS NOTE) -- ********************/

/*SECTION 1: Folder and file names									  													   		   ***/
/***/ %LET ROOT_HPQ		= C:\Example;	/*@Note: base directory (ACCEPTABLE VALUES: computer directory name)		   		   ***/
/***/ %LET PRE_HDEST	= CODI_HPQ_PRE; /*@Note: Suffix name of pre-processing output folder (ACCEPTABLE VALUES: folder name (no punctuations)) ***/
/***/ %LET EHR_H_PRE_OUT = CODI_HPQ_Preprocessed_Filename; /*@Note: Suffix name of pre-processing output file (ACCEPTABLE VALUES: file name (no punctuations)) ***/

/***/ %LET EHR_FILENAME = EHR_Synthetic_Household;	   /*@Note: EHR file name (ACCEPTABLE VALUES: file name, do not include ".csv") ***/
/***/ %LET ACS_FILENAME = ACS_County; 	   /*@Note: ACS person-level file name (ACCEPTABLE VALUES: file name, do not include ".csv") ***/

/***/ %LET LOG_NAME_PRE	= HPQ_LOG_Pre_processing; /*@Note: SAS log file name prefix ACCEPTABLE VALUES: SAS file name (no punctuation) 	

/*Note: subsection of the full program. Be sure to only edit this section but submit the full program. */
  
/***Note: ROOT_PRE directory includes subfolders: 
								"..\0_Raw_Data" 
								"..\1_SAS_Programs"
								"..\02_Output" and 
								"..\02_Output\SAS LOGS"***/
/***NOTE: SAS programs must be stored in the PROGS_PRE directory including: 
								Module1-Pre_Processing_CODI_HPQ.sas***/
/************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*********/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    *********/
/************************************************************************************************************************************/
/************************************************************************************************************************************/
/************************************************************************************************************************************/


/* @Action: SAS options */
OPTIONS VALIDVARNAME=ANY  dlcreatedir;

/***/ %LET PROGS_HPQ	= &ROOT_HPQ\1_SAS_Programs\Pre-Processing\; 	/*@Note: Location of SAS programs, same as in pre-processing SAS programs (ACCEPTABLE VALUES: computer directory name)***/
libname SASlog "&ROOT_HPQ\2_Output\SAS LOG";

/* @Action: Suppress console output */
ods exclude all;

/*@Action: Additional information needed by pre-processing algorithm loaded into SAS macro variables ***/
%LET DateTime = %SYSFUNC(Translate(%Quote(%SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Today(),Weekdate.) %SYSFUNC(Time(), timeampm.))))),%Str(_),%Str( ,:))); /*@Note: Date time of SAS run, DO NOT CHANGE ***/
SYSTASK COMMAND "MKDIR ""&ROOT_HPQ\2_Output\SAS LOG""" WAIT;
Proc Printto Log="&ROOT_HPQ\2_Output\SAS LOG\&LOG_NAME_PRE._&DateTime..log" New; Run;

libname SASout "&ROOT_HPQ\2_Output\&PRE_HDEST";


/*@ Action: Read ACS file ***/
Filename ACS "&ROOT_HPQ\0_Raw_Data\&ACS_FILENAME..csv";

Data SASOut.ACS_COUNTY;
Infile ACS dsd dlm="," lrecl=500 firstobs=2 MISSOVER;

Attrib 
	State_Code length=3  format=3.
	County_Code length=3  format=3.
	female_rel_child_6_17 length=8  format=8.
	female_rel_child_l18 length=8  format=8.
	female_rel_child_l6 length=8  format=8.
	hh_fam length=8  format=8.
	hh_fam_asian length=8  format=8.
	hh_fam_black length=8  format=8.
	hh_fam_ppl_l18 length=8  format=8.
	hh_fam_white length=8  format=8.
	hh_income_25_44 length=8  format=8.
	hh_income_45_64 length=8  format=8.
	hh_income_65pl length=8  format=8.
	hh_income_l25 length=8  format=8.
	hh_owner_bachelors_plus length=8  format=8.
	hh_renter_bachelors_plus length=8  format=8.
	hh_tenure_educ_total length=8  format=8.
	male_rel_child_6_17 length=8  format=8.
	male_rel_child_l18 length=8  format=8.
	male_rel_child_l6 length=8  format=8.
	married_rel_child_6_17 length=8  format=8.
	married_rel_child_l18 length=8  format=8.
	married_rel_child_l6 length=8  format=8.
	LAT_AIAN length=8  format=8.
	LAT_ASIAN length=8  format=8.
	LAT_BLACK length=8  format=8.
	LAT_GE2R length=8  format=8.
	LAT_NHPI length=8  format=8.
	LAT_OTHER length=8  format=8.
	LAT_WHITE length=8  format=8.
	NON_LATX_AIAN length=8  format=8.
	NON_LATX_ASIAN length=8  format=8.
	NON_LATX_BLACK length=8  format=8.
	NON_LATX_GE2R length=8  format=8.
	NON_LATX_NHPI length=8  format=8.
	NON_LATX_OTHER length=8  format=8.
	NON_LATX_WHITE length=8  format=8.
	TOTAL_LAT length=8  format=8.
	TOTAL_NON_LATX length=8  format=8.;
Input   
	State_Code
	County_Code
	female_rel_child_6_17
	female_rel_child_l18
	female_rel_child_l6
	hh_fam
	hh_fam_asian
	hh_fam_black
	hh_fam_ppl_l18
	hh_fam_white
	hh_income_25_44
	hh_income_45_64
	hh_income_65pl
	hh_income_l25
	hh_owner_bachelors_plus
	hh_renter_bachelors_plus
	hh_tenure_educ_total
	male_rel_child_6_17
	male_rel_child_l18
	male_rel_child_l6
	married_rel_child_6_17
	married_rel_child_l18
	married_rel_child_l6
	LAT_AIAN
	LAT_ASIAN
	LAT_BLACK
	LAT_GE2R
	LAT_NHPI
	LAT_OTHER
	LAT_WHITE
	NON_LATX_AIAN
	NON_LATX_ASIAN
	NON_LATX_BLACK
	NON_LATX_GE2R
	NON_LATX_NHPI
	NON_LATX_OTHER
	NON_LATX_WHITE
	TOTAL_LAT
	TOTAL_NON_LATX;
Run;

Data SASOut.ACS_COUNTY;
set SASOut.ACS_COUNTY;
County=compress("00"||county_code);
County=substr(County,length(County)-2,3);
State=compress("0"||state_code);
State=substr(state,length(state)-1,2);
Geography=compress(State||County);

p_ba=( hh_owner_bachelors_plus + hh_renter_bachelors_plus) / hh_tenure_educ_total;

if P_ba>0.2 then ba_g20=1;
	else ba_g20=0;
drop County State;
run;

/*@Action: Read EHR files ***/
Filename EHR "&ROOT_HPQ\0_Raw_Data\&EHR_FILENAME..csv";

Data EHR_SYNTHETIC;
		Infile EHR dsd dlm="," lrecl=500 firstobs=2 MISSOVER;

		Attrib PATID							  length=$50   format=$50.
			   HOUSEHOLD_ID						  length=$50 format=$50.
			   SEX_NUM							  length=3  format=3.
			   AGEYEARS							  length=8   format=8.
			   RACE_ETH    						  length=$16 format=$16.
			   WEIGHT_CATEGORY					  length=$34 format=$34.
			   YEAR								  length=4   format=4.
			   COUNTY_FIPS_CODE					  length=3  format=3.
			   STATE_FIPS_CODE					  length=3  format=3.
			   ;

	Input   PATID
			HOUSEHOLD_ID
			SEX_NUM
			AGEYEARS
			RACE_ETH
			WEIGHT_CATEGORY
			YEAR
			COUNTY_FIPS_CODE
			STATE_FIPS_CODE
			  ;  
Run;

/*@Action: Deduplicate Patient's records ***/
Proc sort data=EHR_SYNTHETIC nodupkey out=EHR_SYNTHETIC; 
by PATID HOUSEHOLD_ID;
run; 

/*@Action: Process EHR and ACS files ***/
%include "&PROGS_HPQ\Module1-Pre_Processing_CODI_HPQ_GEO3.sas";

/************************** Input for IMPUTATION *************************/
%let EHR_PRE_Out=EHR_raceimputed;
%let M=1;
/**********************************************************/

/*@Action: Read in EHR file*/
Data &EHR_PRE_Out._hh;
set &EHR_H_PRE_OUT;
Race=Race_eth;
run;

/**** INCLUDE STATEMENTS HERE TO IMPUTE HOUSEHOLDER RACE *****/

%include "&PROGS_HPQ\Module2-Pre_Processing_CODI_HPQ_GEO3.sas"; /* Imputation according to race of other household members */
%include "&PROGS_HPQ\Module3-Pre_Processing_CODI_HPQ_GEO3.sas"; /* Imputation for Hispanic with unknown race*/
%include "&PROGS_HPQ\Module4-Pre_Processing_CODI_HPQ_GEO3.sas"; /* Imputation for non-Hispanic with unknown race*/


Proc SQL;
create table &EHR_PRE_Out._temp1(drop= geography2 geography3 household_id2 household_id3) as select
a.*,b.*,c.*
from &EHR_PRE_Out._hh2 as a 
left join Hispanic_unknownrace(rename= (geography=geography2 household_id=household_id2)) as b on a.geography=b.geography2 and a.household_id=b.household_id2 
left join Nonhispanic_unknownrace(rename= (geography=geography3 household_id=household_id3)) as c on a.geography=c.geography3 and a.household_id=c.household_id3;

 
data SASout.&EHR_H_PRE_OUT;
set &EHR_PRE_Out._temp1;
	array Impute_Race_(&M) $ ;
	array IR1(*) Impute_Race1_1-Impute_Race1_&M;
	array IR2(*) Impute_Race2_1-Impute_Race2_&M;
 
	do i = 1 to &M;
	 Impute_Race_(i)=compress(coalescec(IR1(i),IR2(i),Race));
	end;
	 
/*	Assign Impute Race 1 as Impute Race*/
	Impute_Race=Impute_Race_1;

	drop Impute_Race1_: Impute_Race2_: i Race Race0;
	%IF &M=1 %then %do;
		drop Impute_Race_1;
	%END; 
	where householder=1; /* keeping householder only */
drop householder Race_eth_missing county_CODE state_code age_cat age_weight;
run;


/*@Action Clear temporary work library and macro variables***/
Proc Datasets Library=WORK Kill;
Quit;

/*@Action: Halt SAS log output ***/
proc printto;
Run;

/* @Action: Cancel console output suprression */ 
ods exclude none;

/*** PROGRAM END ***/

