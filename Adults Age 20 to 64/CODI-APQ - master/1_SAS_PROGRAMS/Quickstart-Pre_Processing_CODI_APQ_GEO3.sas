/*****************************************************************************************/
/***PROGRAM: Quickstart-Pre_Processing_CODI_APQ_ZCTA3.SAS						  	   ***/
/***VERSION: 2.0																	   ***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)						   ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)					  ***/
/***DATE CREATED: 7/20/2020, DATE LAST MOD: 10/27/2021								   ***/
/***INPUT: American Community Survey - GEO3-level (CSV)		   					   ***/
/***INPUT: EHR data file (CSV)														   ***/
/***INPUT: EHR data file with condition information (CSV) 							   ***/
/***OUTPUT: Pre-Processed American Community Survey -GEO3-Level (SAS)				   ***/
/***OUTPUT: Pre-Processed EHR SAS file (SAS)							   			   ***/
/***OBJECTIVE: PREPROCESSES ADULT OBESITY EHR DATA and ACS GEO3 DATA     ***/
/***OBJECTIVE: IMPORT ACS 5-YEAR FILE. APPLY FORMATS, EDITS AND  					   ***/
/***OBJECTIVE: CHECK FOR INCONSISTENCIES/MISSINGNESS. OUTPUT FILE INTO A SAS DATAFILE. ***/
/***OBJECTIVE: REPEATS WITH EHR DATA												   ***/
/*****************************************************************************************/

/*************************************************************************************************************************************/
/*********************** -- PREPROCESSING ALGORITHM USER INPUT SECTION (PLEASE COMPLETE SECTIONS 1-3 BELOW)	-- ***********************/
/******************* -- PLEASE UPDATE THE BLACK TEXT AFTER THE EQUAL SIGN  (ACCEPTED VALUES LISTED IN SAS NOTE) -- *******************/
/*************************************************************************************************************************************/
/*SECTION 1: Input Folder and file names																								    ***/
/***/ %LET ROOT_PRE		= P:\8952\Common\FINAL DELIVERABLES\3 FINAL TESTING\CODI-APQ;								 /*@Note: base directory (ACCEPTABLE VALUES: computer directory name) ***/
/***/ %LET PRE_DEST		= CODI_APQ_GEO3;					 	   /*@Note: Suffix name for EHR Output folder (ACCEPTABLE VALUES: folder name (no puctuation) 		      ***/
/***/ %LET ACS_FILENAME	= ACS_State_ZCTA3;	  	   				   /*@Note: ACS file name (ACCEPTABLE VALUES: file name, do not include ".csv") ***/
/***/ %LET EHR_FILENAME = NORC_IQVIA_Adult_Data;			   		 	   /*@Note: EHR file name (ACCEPTABLE VALUES: file name, do not include ".csv") ***/
/***/ %LET LOG_NAME_PRE	= APQ_Pre_Processing; /*@Note: SAS log file name prefix ACCEPTABLE VALUES: SAS file name (no punctuation) 	   ***/

/*SECTION 2: Beginning and End Year of longitudinal EHR data																			   ***/
/***/ %LET BEGIN_YEAR = 2015; /*@Note: LONGITUDINAL Start year (ACCEPTABLE VALUES: 4-digit numeric year) ***/
/***/ %LET END_YEAR	  = 2019; /*@Note: LONGITUDINAL End year (ACCEPTABLE VALUES: 4-digit numeric year)   ***/

/*SECTION 3: OPTIONAL Output File Name Suffix																							   ***/
/***/ %LET EHR_PRE_Out  = CODI_APQ_ZCTA3; /*@Note: EHR output file name (ACCEPTABLE VALUES: SAS file name (no punctuation)		   		   ***/

/*SECTION 4: County or ZCTA3 data (REQUIRED)																							   ***/
/***/ %LET COUNTY=N; /*@Note: County/ZCTA3 indicator (ACCEPTABLE VALUES: Y for County level data, N for ZCTA3 level data	 ***/ 

/***Note: ROOT_PRE directory includes subfolders: 
								"..\0_Raw_Data" 
								"..\1_SAS_Programs"
								"..\02_Output" and 
								"..\02_Output\SAS LOGS"										   									 	***/
/***NOTE: SAS programs must be stored in the PROGS_PRE directory including: 
								Module0-Pre_Processing_CODI_APQ.sas
								Module1-Pre_Processing_CODI_APQ.sas
								Module2-Pre_Processing_CODI_APQ.sas
								Module3-Pre_Processing_CODI_APQ.sas		   															***/
/*********************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*********/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    *********/
/*********************************************************************************************************************************************/
/*********************************************************************************************************************************************/
/*********************************************************************************************************************************************/















/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/***STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP*/
/*** DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT 	DO NOT EDIT BEYOND THIS POINT    */
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/
/*************************************************************************************************************************************/















/*@Action: Set SAS options ***/
Options Fullstimer Nofmterr Mlogic Mprint Minoperator SymbolGen Compress=Yes;
/***/ %LET PROGS_PRE	= &Root_PRE.\1_SAS_Programs\Pre_Processing_CODI_APQ_GEO3;/*@Note: where SAS programs are stored (ACCEPTABLE VALUES: computer directory name) ***/

/*@Action: Additional information needed by pre-processing algorithm loaded into SAS macro variables ***/
%LET DateTime = %SYSFUNC(Translate(%Quote(%SYSFUNC(COMPBL(%QUOTE(%SYSFUNC(Today(),Weekdate.) %SYSFUNC(Time(), timeampm.))))),%Str(___),%Str( ,:))); /*@Note: Date time of SAS run, DO NOT CHANGE ***/

/*@Action: fill ACS file macro with county or ZCTA3 file. ***/
%macro filenames();
	%Global ACS_PRE_Out;
	%if &County.=N %then %do;
		%LET ACS_PRE_Out  = ACS_State_ZCTA3;	  	  /*@Note: Census ACS output file name for ZCTA3 (ACCEPTABLE VALUES: SAS file name (no punctuation) ***/
	%end;
	%else %do;
		%LET ACS_PRE_Out  = ACS_State_County;	  	  /*@Note: Census ACS output file name for County (ACCEPTABLE VALUES: SAS file name (no punctuation) ***/
	%end;
%mend;

%filenames();

%LET REG_EST_NAME = Pre_PQ_Reg_Est;			  /*@Note: Regression estimates SAS filename (ACCEPTABLE VALUES: file name, do not include ".sas7bdat") ***/
%LET MODULE0 =Module0-Pre_Processing_CODI_APQ_GEO3; /*@Note: Module 1 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE1 =Module1-Pre_Processing_CODI_APQ_GEO3; /*@Note: Module 1 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE2 =Module2-Pre_Processing_CODI_APQ_GEO3; /*@Note: Module 2 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE3 =Module3-Pre_Processing_CODI_APQ_GEO3; /*@Note: Module 3 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/

/*@Action: Check if optional input value was entered missing, if missing set default ***/
%Macro Check_Optional;
	%If "&EHR_PRE_Out." = "" %Then %Let EHR_PRE_Out = CODI_APQ_GEO3;
%Mend;
%Check_Optional;

/*@Action: Create LOG/PDF output folder and begin SAS log and PDF output ***/
SYSTASK COMMAND "MKDIR ""&ROOT_Pre.\2_Output\SAS LOG""" WAIT;
Proc Printto Log="&ROOT_Pre.\2_Output\SAS LOG\&LOG_NAME_PRE._&DateTime..log" New; Run;

/*@Action: Create and initialize SAS output Destination library ***/
SYSTASK COMMAND "MKDIR ""&ROOT_Pre.\2_Output\Pre_Processed_&Pre_Dest.""" WAIT;
Libname RegEst "&ROOT_Pre.\0_Raw_Data" Access=Readonly;
Libname SASOut "&ROOT_Pre.\2_Output\Pre_Processed_&Pre_Dest.";

/*@Action: Create formats for literal text translation ***/
Proc Format;
		/*@Note: Weight Categories ***/
		Value $WgtCat "Underweight"						   = "(1) Underweight (BMI<18.5)"
					  "Normal or Healthy Weight"		     = "(2) Healthy Weight (18.5<=BMI<25)"
					  "Overweight"										  = "(3) Overweight (25<=BMI<30)"
					  "Obesity (Class 1)"								= "(4) Obesity (Class 1) (30<=BMI<35)"
					  "Obesity (Class 2)"								= "(5) Obesity (Class 2) (35<=BMI<40)"
					  "Obesity (Class 3) - Severe Obesity" = "(6) Obesity (Class 3) - Severe Obesity (BMI>=40)"
					  Other 		   = " "
					  ;

	/*@Note: Age Categories ***/
	Value Age 20 - 24 = "20 - 24"
			  25 - 29 = "25 - 29"
			  30 - 34 = "30 - 34"
			  35 - 44 = "35 - 44"
			  45 - 54 = "45 - 54"
			  55 - 64 = "55 - 64"
			  Other   = "  "
			  ;

	/*@Note: State FIPS code to ALPHA State Code conversion ***/
	Value $FIPS_to_Alpha "01"="AL" "02"="AK" "04"="AZ" "05"="AR" "06"="CA" "08"="CO" "09"="CT" "10"="DE" "11"="DC" "12"="FL"
				  "13"="GA" "15"="HI" "16"="ID" "17"="IL" "18"="IN" "19"="IA" "20"="KS" "21"="KY" "22"="LA" "23"="ME"
				  "24"="MD" "25"="MA" "26"="MI" "27"="MN" "28"="MS" "29"="MO" "30"="MT" "31"="NE" "32"="NV" "33"="NH"
				  "34"="NJ" "35"="NM" "36"="NY" "37"="NC" "38"="ND" "39"="OH" "40"="OK" "41"="OR" "42"="PA" "44"="RI"
				  "45"="SC" "46"="SD" "47"="TN" "48"="TX" "49"="UT" "50"="VT" "51"="VA" "53"="WA" "54"="WV" "55"="WI"
				  "56"="WY" Other="  "
				  ;

	/*@Note: ALPHA State Code to State FIPS code conversion ***/
	Value $ALPHA_to_FIPS "AL"="01" "AK"="02" "AZ"="04" "AR"="05" "CA"="06" "CO"="08" "CT"="09" "DE"="10" "DC"="11" "FL"="12"
				   "GA"="13" "HI"="15" "ID"="16" "IL"="17" "IN"="18" "IA"="19" "KS"="20" "KY"="21" "LA"="22" "ME"="23"
				   "MD"="24" "MA"="25" "MI"="26" "MN"="27" "MS"="28" "MO"="29" "MT"="30" "NE"="31" "NV"="32" "NH"="33"
				   "NJ"="34" "NM"="35" "NY"="36" "NC"="37" "ND"="38" "OH"="39" "OK"="40" "OR"="41" "PA"="42" "RI"="44"
				   "SC"="45" "SD"="46" "TN"="47" "TX"="48" "UT"="49" "VT"="50" "VA"="51" "WA"="53" "WV"="54" "WI"="55"
				   "WY"="56" Other="  "
				   ;
		Run;

/*******************************************************************************************************************************************/
/************************************************* -- Import ACS CSV Data File into SAS -- *************************************************/
/************************************************* -- Apply Rename and Collapsing Logic -- *************************************************/
/*******************************************************************************************************************************************/
/*@Action: Load list of ACS variables needed to compute control totals and impute race ***/
%Let ACSOriginal=B01001A_008 B01001A_009 B01001A_010 B01001A_011 B01001A_012 B01001A_013 B01001A_023
B01001A_024 B01001A_025 B01001A_026 B01001A_027 B01001A_028 B01001B_008 B01001B_009 B01001B_010
B01001B_011 B01001B_012 B01001B_013 B01001B_023 B01001B_024 B01001B_025 B01001B_026 B01001B_027
B01001B_028 B01001C_008 B01001C_009 B01001C_010 B01001C_011 B01001C_012 B01001C_013 B01001C_023
B01001C_024 B01001C_025 B01001C_026 B01001C_027 B01001C_028 B01001D_008 B01001D_009 B01001D_010
B01001D_011 B01001D_012 B01001D_013 B01001D_023 B01001D_024 B01001D_025 B01001D_026 B01001D_027
B01001D_028 B01001E_008 B01001E_009 B01001E_010 B01001E_011 B01001E_012 B01001E_013 B01001E_023
B01001E_024 B01001E_025 B01001E_026 B01001E_027 B01001E_028 B01001F_008 B01001F_009 B01001F_010
B01001F_011 B01001F_012 B01001F_013 B01001F_023 B01001F_024 B01001F_025 B01001F_026 B01001F_027
B01001F_028 B01001G_008 B01001G_009 B01001G_010 B01001G_011 B01001G_012 B01001G_013 B01001G_023
B01001G_024 B01001G_025 B01001G_026 B01001G_027 B01001G_028 B15001_011 B15001_017 B15001_018 
B15001_019 B15001_025 B15001_026 B15001_027 B15001_033 B15001_034 B15001_052 B15001_058 B15001_059 
B15001_060 B15001_066 B15001_067 B15001_068 B15001_074 B15001_075 B03002_012 B03002_013 B03002_014 
B03002_015 B03002_016 B03002_017 B03002_018 B03002_019 B01001A_001 B01001B_001 B01001C_001 B01001D_001 
B01001E_001 B01001F_001 B01001G_001;

/*@Action: Final list of ACS variables ***/
%Let ACSNew=TOTAL_ACS_POPULATION AGE_20_24_MALE_WHITE AGE_25_29_MALE_WHITE AGE_30_34_MALE_WHITE
AGE_35_44_MALE_WHITE AGE_45_54_MALE_WHITE AGE_55_64_MALE_WHITE AGE_20_24_FEMALE_WHITE
AGE_25_29_FEMALE_WHITE AGE_30_34_FEMALE_WHITE AGE_35_44_FEMALE_WHITE AGE_45_54_FEMALE_WHITE
AGE_55_64_FEMALE_WHITE AGE_20_24_MALE_BLACK AGE_25_29_MALE_BLACK AGE_30_34_MALE_BLACK
AGE_35_44_MALE_BLACK AGE_45_54_MALE_BLACK AGE_55_64_MALE_BLACK AGE_20_24_FEMALE_BLACK
AGE_25_29_FEMALE_BLACK AGE_30_34_FEMALE_BLACK AGE_35_44_FEMALE_BLACK AGE_45_54_FEMALE_BLACK 
AGE_55_64_FEMALE_BLACK AGE_20_24_MALE_ASIAN AGE_25_29_MALE_ASIAN AGE_30_34_MALE_ASIAN
AGE_35_44_MALE_ASIAN AGE_45_54_MALE_ASIAN AGE_55_64_MALE_ASIAN AGE_20_24_FEMALE_ASIAN
AGE_25_29_FEMALE_ASIAN AGE_30_34_FEMALE_ASIAN AGE_35_44_FEMALE_ASIAN AGE_45_54_FEMALE_ASIAN
AGE_55_64_FEMALE_ASIAN AGE_20_24_MALE_OTHER AGE_25_29_MALE_OTHER AGE_30_34_MALE_OTHER 
AGE_35_44_MALE_OTHER AGE_45_54_MALE_OTHER AGE_55_64_MALE_OTHER AGE_20_24_FEMALE_OTHER
AGE_25_29_FEMALE_OTHER AGE_30_34_FEMALE_OTHER AGE_35_44_FEMALE_OTHER AGE_45_54_FEMALE_OTHER
AGE_55_64_FEMALE_OTHER AGE_25_64_BACH_GRAD AGE_25_64_BACH_GRAD_GTR10PERC TOTAL_LATIN 
LATIN_WHITE LATIN_BLACK LATIN_ASIAN LATIN_OTHER;

/*@Action: Rename statements to rename original ACS variables into standardized names ***/
%Let ACSRename=%Str(B01001A_008=AGE_20_24_MALE_WHITE B01001A_009=AGE_25_29_MALE_WHITE
B01001A_010=AGE_30_34_MALE_WHITE B01001A_011=AGE_35_44_MALE_WHITE B01001A_012=AGE_45_54_MALE_WHITE
B01001A_013=AGE_55_64_MALE_WHITE B01001A_023=AGE_20_24_FEMALE_WHITE B01001A_024=AGE_25_29_FEMALE_WHITE
B01001A_025=AGE_30_34_FEMALE_WHITE B01001A_026=AGE_35_44_FEMALE_WHITE B01001A_027=AGE_45_54_FEMALE_WHITE
B01001A_028=AGE_55_64_FEMALE_WHITE B01001B_008=AGE_20_24_MALE_BLACK B01001B_009=AGE_25_29_MALE_BLACK
B01001B_010=AGE_30_34_MALE_BLACK B01001B_011=AGE_35_44_MALE_BLACK B01001B_012=AGE_45_54_MALE_BLACK
B01001B_013=AGE_55_64_MALE_BLACK B01001B_023=AGE_20_24_FEMALE_BLACK B01001B_024=AGE_25_29_FEMALE_BLACK
B01001B_025=AGE_30_34_FEMALE_BLACK B01001B_026=AGE_35_44_FEMALE_BLACK B01001B_027=AGE_45_54_FEMALE_BLACK
B01001B_028=AGE_55_64_FEMALE_BLACK B01001C_008=AGE_20_24_MALE_AIAN B01001C_009=AGE_25_29_MALE_AIAN
B01001C_010=AGE_30_34_MALE_AIAN B01001C_011=AGE_35_44_MALE_AIAN B01001C_012=AGE_45_54_MALE_AIAN
B01001C_013=AGE_55_64_MALE_AIAN B01001C_023=AGE_20_24_FEMALE_AIAN B01001C_024=AGE_25_29_FEMALE_AIAN
B01001C_025=AGE_30_34_FEMALE_AIAN B01001C_026=AGE_35_44_FEMALE_AIAN B01001C_027=AGE_45_54_FEMALE_AIAN
B01001C_028=AGE_55_64_FEMALE_AIAN B01001D_008=AGE_20_24_MALE_ASIAN B01001D_009=AGE_25_29_MALE_ASIAN
B01001D_010=AGE_30_34_MALE_ASIAN B01001D_011=AGE_35_44_MALE_ASIAN B01001D_012=AGE_45_54_MALE_ASIAN
B01001D_013=AGE_55_64_MALE_ASIAN B01001D_023=AGE_20_24_FEMALE_ASIAN B01001D_024=AGE_25_29_FEMALE_ASIAN
B01001D_025=AGE_30_34_FEMALE_ASIAN B01001D_026=AGE_35_44_FEMALE_ASIAN B01001D_027=AGE_45_54_FEMALE_ASIAN
B01001D_028=AGE_55_64_FEMALE_ASIAN B01001E_008=AGE_20_24_MALE_NHPI B01001E_009=AGE_25_29_MALE_NHPI
B01001E_010=AGE_30_34_MALE_NHPI B01001E_011=AGE_35_44_MALE_NHPI B01001E_012=AGE_45_54_MALE_NHPI
B01001E_013=AGE_55_64_MALE_NHPI B01001E_023=AGE_20_24_FEMALE_NHPI B01001E_024=AGE_25_29_FEMALE_NHPI
B01001E_025=AGE_30_34_FEMALE_NHPI B01001E_026=AGE_35_44_FEMALE_NHPI B01001E_027=AGE_45_54_FEMALE_NHPI
B01001E_028=AGE_55_64_FEMALE_NHPI B01001F_008=AGE_20_24_MALE_OTHER B01001F_009=AGE_25_29_MALE_OTHER
B01001F_010=AGE_30_34_MALE_OTHER B01001F_011=AGE_35_44_MALE_OTHER B01001F_012=AGE_45_54_MALE_OTHER
B01001F_013=AGE_55_64_MALE_OTHER B01001F_023=AGE_20_24_FEMALE_OTHER B01001F_024=AGE_25_29_FEMALE_OTHER 
B01001F_025=AGE_30_34_FEMALE_OTHER B01001F_026=AGE_35_44_FEMALE_OTHER B01001F_027=AGE_45_54_FEMALE_OTHER
B01001F_028=AGE_55_64_FEMALE_OTHER B01001G_008=AGE_20_24_MALE_GE2R B01001G_009=AGE_25_29_MALE_GE2R
B01001G_010=AGE_30_34_MALE_GE2R B01001G_011=AGE_35_44_MALE_GE2R B01001G_012=AGE_45_54_MALE_GE2R
B01001G_013=AGE_55_64_MALE_GE2R B01001G_023=AGE_20_24_FEMALE_GE2R B01001G_024=AGE_25_29_FEMALE_GE2R
B01001G_025=AGE_30_34_FEMALE_GE2R B01001G_026=AGE_35_44_FEMALE_GE2R B01001G_027=AGE_45_54_FEMALE_GE2R
B01001G_028=AGE_55_64_FEMALE_GE2R B15001_011=AGE_25_34_MALE_EDUC B15001_017=AGE_25_34_MALE_BACHELOR
B15001_018=AGE_25_34_MALE_GRAD_PROF B15001_019=AGE_35_44_MALE_EDUC B15001_025=AGE_35_44_MALE_BACHELOR
B15001_026=AGE_35_44_MALE_GRAD_PROF B15001_027=AGE_45_64_MALE_EDUC B15001_033=AGE_45_64_MALE_BACHELOR
B15001_034=AGE_45_64_MALE_GRAD_PROF B15001_052=AGE_25_34_FEMALE_EDUC B15001_058=AGE_25_34_FEMALE_BACHELOR
B15001_059=AGE_25_34_FEMALE_GRAD_PROF B15001_060=AGE_35_44_FEMALE_EDUC B15001_066=AGE_35_44_FEMALE_BACHELOR
B15001_067=AGE_35_44_FEMALE_GRAD_PROF B15001_068=AGE_45_64_FEMALE_EDUC B15001_074=AGE_45_64_FEMALE_BACHELOR
B15001_075=AGE_45_64_FEMALE_GRAD_PROF B03002_012=TOTAL_LATIN B03002_013=LATIN_WHITE B03002_014=LATIN_BLACK
B03002_015=LAT_AIAN B03002_016=LAT_ASIAN B03002_017=LAT_NHPI B03002_018=LAT_OTHER B03002_019=LAT_GE2R);

/*@Action: Import ACS CSV file ***/
Proc Import Datafile="&ROOT_PRE.\0_Raw_Data\&ACS_FILENAME..csv" DBMS=CSV Out=&ACS_PRE_Out. Replace; Getnames=YES;
Run;

/*@Action: Exclude ACS variables that are not needed to compute controls and apply rename logic ***/
%Macro ACSprocess();
	%If &County.=N %Then %do;
		Data SASOut.&ACS_PRE_Out.(Keep=Geography State_Alpha State_FIPS ZCTA3 &ACSNew. Rename=(ZCTA3=GEO3));
			Retain Geography State_Alpha State_FIPS ZCTA3 &ACSNew.;
			Set &ACS_PRE_Out.(Keep=ZCTA3 &ACSOriginal. Rename=(ZCTA3=ST_ZCTA3 &ACSRename.));
				/*@Action: Extract location information from GEOID, State_Alpha and ZCTA3 ***/
				Length Geography $5. State_Alpha $2. State_FIPS $2. ZCTA3 $3.;
				Geography = Cats(Put(SUBSTR(ST_ZCTA3, 4, 2), $ALPHA_to_FIPS.), Substr(ST_ZCTA3, 1, 3));
				State_Alpha = Put(Substr(Geography, 1, 2), $FIPS_to_Alpha.);
				State_FIPS = Substr(Geography, 1, 2);
				ZCTA3 = Substr(Geography, 3, 3);

				/*@Action: Reset numeric null (.) to zeros (0) ***/
				Array Change _Numeric_; Do over Change; If Change=. Then Change=0; End;

				/*@Action: Compute Total ACS Population ***/
				TOTAL_ACS_POPULATION=B01001A_001+B01001B_001+B01001C_001+B01001D_001+B01001E_001+B01001F_001+B01001G_001;

				if TOTAL_ACS_POPULATION=0 then delete;

				/*@Action: Combine specific race categories with others ***/
				/*@Note: NHPI is collapsed into ASIAN ***/
				AGE_20_24_MALE_ASIAN=AGE_20_24_MALE_ASIAN+AGE_20_24_MALE_NHPI;
				AGE_25_29_MALE_ASIAN=AGE_25_29_MALE_ASIAN+AGE_25_29_MALE_NHPI;
				AGE_30_34_MALE_ASIAN=AGE_30_34_MALE_ASIAN+AGE_30_34_MALE_NHPI;
				AGE_35_44_MALE_ASIAN=AGE_35_44_MALE_ASIAN+AGE_35_44_MALE_NHPI;
				AGE_45_54_MALE_ASIAN=AGE_45_54_MALE_ASIAN+AGE_45_54_MALE_NHPI;
				AGE_55_64_MALE_ASIAN=AGE_55_64_MALE_ASIAN+AGE_55_64_MALE_NHPI;
				AGE_20_24_FEMALE_ASIAN=AGE_20_24_FEMALE_ASIAN+AGE_20_24_FEMALE_NHPI;
				AGE_25_29_FEMALE_ASIAN=AGE_25_29_FEMALE_ASIAN+AGE_25_29_FEMALE_NHPI;
				AGE_30_34_FEMALE_ASIAN=AGE_30_34_FEMALE_ASIAN+AGE_30_34_FEMALE_NHPI;
				AGE_35_44_FEMALE_ASIAN=AGE_35_44_FEMALE_ASIAN+AGE_35_44_FEMALE_NHPI;
				AGE_45_54_FEMALE_ASIAN=AGE_45_54_FEMALE_ASIAN+AGE_45_54_FEMALE_NHPI;
				AGE_55_64_FEMALE_ASIAN=AGE_55_64_FEMALE_ASIAN+AGE_55_64_FEMALE_NHPI;
				LATIN_ASIAN=LAT_ASIAN+LAT_NHPI;

				/*@Note: GE2R and AIAN are collapsed into OTHER ***/
				AGE_20_24_MALE_OTHER=AGE_20_24_MALE_OTHER+AGE_20_24_MALE_GE2R+AGE_20_24_MALE_AIAN;
				AGE_25_29_MALE_OTHER=AGE_25_29_MALE_OTHER+AGE_25_29_MALE_GE2R+AGE_25_29_MALE_AIAN;
				AGE_30_34_MALE_OTHER=AGE_30_34_MALE_OTHER+AGE_30_34_MALE_GE2R+AGE_30_34_MALE_AIAN;
				AGE_35_44_MALE_OTHER=AGE_35_44_MALE_OTHER+AGE_35_44_MALE_GE2R+AGE_35_44_MALE_AIAN;
				AGE_45_54_MALE_OTHER=AGE_45_54_MALE_OTHER+AGE_45_54_MALE_GE2R+AGE_45_54_MALE_AIAN;
				AGE_55_64_MALE_OTHER=AGE_55_64_MALE_OTHER+AGE_55_64_MALE_GE2R+AGE_55_64_MALE_AIAN;
				AGE_20_24_FEMALE_OTHER=AGE_20_24_FEMALE_OTHER+AGE_20_24_FEMALE_GE2R+AGE_20_24_FEMALE_AIAN;
				AGE_25_29_FEMALE_OTHER=AGE_25_29_FEMALE_OTHER+AGE_25_29_FEMALE_GE2R+AGE_25_29_FEMALE_AIAN;
				AGE_30_34_FEMALE_OTHER=AGE_30_34_FEMALE_OTHER+AGE_30_34_FEMALE_GE2R+AGE_30_34_FEMALE_AIAN;
				AGE_35_44_FEMALE_OTHER=AGE_35_44_FEMALE_OTHER+AGE_35_44_FEMALE_GE2R+AGE_35_44_FEMALE_AIAN;
				AGE_45_54_FEMALE_OTHER=AGE_45_54_FEMALE_OTHER+AGE_45_54_FEMALE_GE2R+AGE_45_54_FEMALE_AIAN;
				AGE_55_64_FEMALE_OTHER=AGE_55_64_FEMALE_OTHER+AGE_55_64_FEMALE_GE2R+AGE_55_64_FEMALE_AIAN;
				LATIN_OTHER=LAT_OTHER+LAT_GE2R+LAT_AIAN;

				/*@Note: Compute % of adults aged 25-64 with Education Bachelor+ ***/
				AGE_25_64_BACH_GRAD=Sum(AGE_25_34_MALE_BACHELOR, AGE_25_34_FEMALE_BACHELOR, AGE_35_44_MALE_BACHELOR, AGE_35_44_FEMALE_BACHELOR, AGE_45_64_MALE_BACHELOR, AGE_45_64_FEMALE_BACHELOR, AGE_25_34_MALE_GRAD_PROF, AGE_25_34_FEMALE_GRAD_PROF, AGE_35_44_MALE_GRAD_PROF, AGE_35_44_FEMALE_GRAD_PROF, AGE_45_64_MALE_GRAD_PROF, AGE_45_64_FEMALE_GRAD_PROF)/Sum(AGE_25_34_MALE_EDUC, AGE_25_34_FEMALE_EDUC, AGE_35_44_MALE_EDUC, AGE_35_44_FEMALE_EDUC, AGE_45_64_MALE_EDUC, AGE_45_64_FEMALE_EDUC);
				AGE_25_64_BACH_GRAD_GTR10PERC=(AGE_25_64_BACH_GRAD>0.1);
		Run;
	%End;
	%Else %Do;
		Data SASOut.&ACS_PRE_Out. (Keep=Geography State_Alpha State_FIPS County &ACSNew. Rename=(County=GEO3));
			Retain Geography State_Alpha State_FIPS County &ACSNew.;
			Set &ACS_PRE_Out.(Keep=State_Code County_Code &ACSOriginal. Rename=(&ACSRename.) where=(state_code ne 72));
				/*@Action: Extract location information from GEOID, State_Alpha and County ***/
				Length Geography $5. State_Alpha $2. State_FIPS $2. County $3.;
				Geography = Cats(Put(State_Code, z2.), put(County_Code, z3.)); 
				State_Alpha = Put(Substr(Geography, 1, 2), $FIPS_to_Alpha.);
				State_FIPS = Substr(Geography, 1, 2);
				County = Substr(Geography, 3, 3);

				/*@Action: Reset numeric null (.) to zeros (0) ***/
				Array Change _Numeric_; Do over Change; If Change=. Then Change=0; End;

				/*@Action: Compute Total ACS Population ***/
				TOTAL_ACS_POPULATION=B01001A_001+B01001B_001+B01001C_001+B01001D_001+B01001E_001+B01001F_001+B01001G_001;

				if TOTAL_ACS_POPULATION=0 then delete;

				/*@Action: Combine specific race categories with others ***/
				/*@Note: NHPI is collapsed into ASIAN ***/
				AGE_20_24_MALE_ASIAN=AGE_20_24_MALE_ASIAN+AGE_20_24_MALE_NHPI;
				AGE_25_29_MALE_ASIAN=AGE_25_29_MALE_ASIAN+AGE_25_29_MALE_NHPI;
				AGE_30_34_MALE_ASIAN=AGE_30_34_MALE_ASIAN+AGE_30_34_MALE_NHPI;
				AGE_35_44_MALE_ASIAN=AGE_35_44_MALE_ASIAN+AGE_35_44_MALE_NHPI;
				AGE_45_54_MALE_ASIAN=AGE_45_54_MALE_ASIAN+AGE_45_54_MALE_NHPI;
				AGE_55_64_MALE_ASIAN=AGE_55_64_MALE_ASIAN+AGE_55_64_MALE_NHPI;
				AGE_20_24_FEMALE_ASIAN=AGE_20_24_FEMALE_ASIAN+AGE_20_24_FEMALE_NHPI;
				AGE_25_29_FEMALE_ASIAN=AGE_25_29_FEMALE_ASIAN+AGE_25_29_FEMALE_NHPI;
				AGE_30_34_FEMALE_ASIAN=AGE_30_34_FEMALE_ASIAN+AGE_30_34_FEMALE_NHPI;
				AGE_35_44_FEMALE_ASIAN=AGE_35_44_FEMALE_ASIAN+AGE_35_44_FEMALE_NHPI;
				AGE_45_54_FEMALE_ASIAN=AGE_45_54_FEMALE_ASIAN+AGE_45_54_FEMALE_NHPI;
				AGE_55_64_FEMALE_ASIAN=AGE_55_64_FEMALE_ASIAN+AGE_55_64_FEMALE_NHPI;
				LATIN_ASIAN=LAT_ASIAN+LAT_NHPI;

				/*@Note: GE2R and AIAN are collapsed into OTHER ***/
				AGE_20_24_MALE_OTHER=AGE_20_24_MALE_OTHER+AGE_20_24_MALE_GE2R+AGE_20_24_MALE_AIAN;
				AGE_25_29_MALE_OTHER=AGE_25_29_MALE_OTHER+AGE_25_29_MALE_GE2R+AGE_25_29_MALE_AIAN;
				AGE_30_34_MALE_OTHER=AGE_30_34_MALE_OTHER+AGE_30_34_MALE_GE2R+AGE_30_34_MALE_AIAN;
				AGE_35_44_MALE_OTHER=AGE_35_44_MALE_OTHER+AGE_35_44_MALE_GE2R+AGE_35_44_MALE_AIAN;
				AGE_45_54_MALE_OTHER=AGE_45_54_MALE_OTHER+AGE_45_54_MALE_GE2R+AGE_45_54_MALE_AIAN;
				AGE_55_64_MALE_OTHER=AGE_55_64_MALE_OTHER+AGE_55_64_MALE_GE2R+AGE_55_64_MALE_AIAN;
				AGE_20_24_FEMALE_OTHER=AGE_20_24_FEMALE_OTHER+AGE_20_24_FEMALE_GE2R+AGE_20_24_FEMALE_AIAN;
				AGE_25_29_FEMALE_OTHER=AGE_25_29_FEMALE_OTHER+AGE_25_29_FEMALE_GE2R+AGE_25_29_FEMALE_AIAN;
				AGE_30_34_FEMALE_OTHER=AGE_30_34_FEMALE_OTHER+AGE_30_34_FEMALE_GE2R+AGE_30_34_FEMALE_AIAN;
				AGE_35_44_FEMALE_OTHER=AGE_35_44_FEMALE_OTHER+AGE_35_44_FEMALE_GE2R+AGE_35_44_FEMALE_AIAN;
				AGE_45_54_FEMALE_OTHER=AGE_45_54_FEMALE_OTHER+AGE_45_54_FEMALE_GE2R+AGE_45_54_FEMALE_AIAN;
				AGE_55_64_FEMALE_OTHER=AGE_55_64_FEMALE_OTHER+AGE_55_64_FEMALE_GE2R+AGE_55_64_FEMALE_AIAN;
				LATIN_OTHER=LAT_OTHER+LAT_GE2R+LAT_AIAN;

				/*@Note: Compute % of adults aged 25-64 with Education Bachelor+ ***/
				AGE_25_64_BACH_GRAD=Sum(AGE_25_34_MALE_BACHELOR, AGE_25_34_FEMALE_BACHELOR, AGE_35_44_MALE_BACHELOR, AGE_35_44_FEMALE_BACHELOR, AGE_45_64_MALE_BACHELOR, AGE_45_64_FEMALE_BACHELOR, AGE_25_34_MALE_GRAD_PROF, AGE_25_34_FEMALE_GRAD_PROF, AGE_35_44_MALE_GRAD_PROF, AGE_35_44_FEMALE_GRAD_PROF, AGE_45_64_MALE_GRAD_PROF, AGE_45_64_FEMALE_GRAD_PROF)/Sum(AGE_25_34_MALE_EDUC, AGE_25_34_FEMALE_EDUC, AGE_35_44_MALE_EDUC, AGE_35_44_FEMALE_EDUC, AGE_45_64_MALE_EDUC, AGE_45_64_FEMALE_EDUC);
				AGE_25_64_BACH_GRAD_GTR10PERC=(AGE_25_64_BACH_GRAD>0.1);
		Run;
	%End;
%Mend;

%ACSprocess();


/*******************************************************************************************************************************************/
/*************************************************** -- Import EHR Data File into SAS -- ***************************************************/
/********************************** -- Reformat and create variables needed for prevalence estimation -- ***********************************/
/*******************************************************************************************************************************************/
%Macro Import_EHR_Data;
	/*@Action: FILENAME step to preload input file ***/
	Filename EHR "&ROOT_PRE.\0_Raw_Data\&EHR_FILENAME..csv";
/*	Filename EHRCond "&ROOT_PRE.\0_Raw_Data\&EHR_COND_FILENAME..csv";*/

	/*@Action: Load import file and convert into SAS dataset 		 ***/
	/*@Note: This file will be copied into output destination folder ***/
	Data Include_EHR(label="&EHR_PRE_Out.");
		Infile EHR dsd dlm="," lrecl=500 firstobs=2 MISSOVER;

		Attrib SUBJID							 length=$25   format=$25.
			   SEX_NUM							  length=$5  format=$5.
			   AGEYEARS							  length=8   format=8.
			   RACE_ETH    						  length=$16 format=$16.
			   STATE_ABR						  length=$2  format=$2.
			   GEO3				  					  length=$3   format=$3.
			   WEIGHT_CATEGORY			length=$34 format=$34.
			   YEAR									  length=4   format=4.
			   DIABETES_SPECTRUM	   length=3   format=4.
			   SCD										length=3   format=4.
			   PREGNANCY_FLAG			  length=3   format=4.
			   ZIP									     length=$5   format=$5.
			   ;

		Input SUBJID
			SEX_NUM
			AGEYEARS
			RACE_ETH
			STATE_ABR
			GEO3
			WEIGHT_CATEGORY
			YEAR
			DIABETES_SPECTRUM
			SCD
			PREGNANCY_FLAG
			ZIP
			  ;  

			    /*@Action: Perform various clean-up to the EHR file ***/
			    If ^(20<=AGEYEARS<=64) Then Do;
					WEIGHT_CATEGORY="";
					STATE_ABR="";
					GEO3="";
				End;

				If WEIGHT_CATEGORY="" Then FLG_WTCAT=0;
					Else FLG_WTCAT=1;

				/*@Action: Assign weight category description ***/
				WTCAT_LIT = PUT(WEIGHT_CATEGORY, $WgtCat.);

				/*@Action: Set Indicated Sex ***/
				Length Sex $8.;
				If SEX_NUM=0 then Sex="Male";
					Else if SEX_NUM=1 then Sex="Female";
					Else Sex="Unknown";

				/*@Action: Set Indicated Race ***/
				Length Race $8.;
				If RACE_ETH="AFRICAN AMERICAN" then Race="Black";
					Else If RACE_ETH="CAUCASIAN" then Race="White";
					Else If RACE_ETH="ASIAN" then Race="Asian";
					Else If RACE_ETH="HISPANIC" then Race="Hispanic";
					Else If RACE_ETH="OTHER" then Race="Other";
					Else If RACE_ETH="UNKNOWN" then Race="Unknown";
					Else Race=RACE_ETH;
	Run;

	/*@Action: Macro to keep order of yearly variables, dropping 2015 from list because out of scope ***/
	/*@Note: Keep list begins 1 year after begin date												 ***/
	%Macro SQL_Var_Order;
		%if &COUNTY.=N %then %do;
			AGEYEARS as AGEYR, Put(AGEYEARS, Age.) as AGE_CATEGORIES, WTCAT_LIT as WTCAT, FLG_WTCAT,
			state_abr as STATE_ALPHA, Put(state_abr, $ALPHA_to_FIPS.) as STATE_FIPS, ZIP,
			GEO3, Cats(Calculated STATE_FIPS, GEO3) as Geography Length=5 Format=$5., diabetes_spectrum, SCD, pregnancy_flag
		%end;
		%else %do;
			AGEYEARS as AGEYR, Put(AGEYEARS, Age.) as AGE_CATEGORIES, WTCAT_LIT as WTCAT, FLG_WTCAT,
			state_abr as STATE_ALPHA, Put(state_abr, $ALPHA_to_FIPS.) as STATE_FIPS, ZIP,
			GEO3, Cats(Calculated STATE_FIPS, GEO3) as Geography Length=5 Format=$5., diabetes_spectrum, SCD, pregnancy_flag
		%end;
	%Mend;

	/*@Action: Apply new ordering of variables and exclude any variables not needed for analysis ***/
	Proc Sql;
		Create table Include_EHR_Pre0 as
			Select SUBJID as PATID, %SQL_Var_Order, RACE, SEX, year
				From Include_EHR;
	Quit;	

	/*@Action: Check for bad geography in EHR data, defined as ACS population=0 or not present in ACS ***/
	Proc Sort Data=Include_EHR_Pre0;
		By GEOGRAPHY;
	Proc Sort Data=SASOut.&ACS_PRE_Out. Out=Sorted_ACS;
		Where TOTAL_ACS_POPULATION>0;
		By GEOGRAPHY;
	Data Include_EHR_Pre;
		Merge Include_EHR_Pre0(In=A) Sorted_ACS(In=B Keep=GEOGRAPHY Rename=(GEOGRAPHY=GEOGRAPHY));
			By GEOGRAPHY;
				If A;
				If WTCAT^="" and A and ^(B) then Bad_Geo=1;
					Else Bad_Geo=0;
		Run;

	/*@Action: Exclude records with bad geography or out of scope (i.e. younger than 20 or older than 64, or missing weight information for all years) ***/
	Data &EHR_PRE_Out.(Drop=Bad_Geo FLG_WTCAT) Removed_EHR;
		Set Include_EHR_Pre;
			/*@Action: Exclude People outside 20-64 Ages Range ***/
			If (^(20<=AGEYR<=64)) or
				Sum(of FLG_WTCAT)=0 or 
				Sum(of Bad_Geo)=Sum(of FLG_WTCAT) Then Output Removed_EHR;
			Else Output &EHR_PRE_Out.;

	/*@Action: Clear out preloaded import files ***/
	Filename EHR Clear;
%Mend;

%Import_EHR_Data;


/***********************************************************************************************************************/
/***************************************** -- Begin Race Imputation Routine -- *****************************************/
/*************************************** -- Module 1: People with Conditions  -- ***************************************/
/*********************** -- Module 2: People with indicated Hispanic Race, without Conditions -- ***********************/
/**************************************** -- Module 3: All reminaing people  -- ****************************************/
/***********************************************************************************************************************/
/*@Action: Prepare Data for each of the 3 Modules ***/
Data PreEHR_PQ_Pre0;
	Set &EHR_PRE_Out.;
		/*@Action: Set variables to most recent encounter, beginning with 2030 ***/
		If Year=2030 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2029 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2028 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2027 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2026 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2025 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2024 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2023 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2022 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2021 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2020 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2019 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		Else If Year=2018 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		Else If Year=2017 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		Else If Year=2016 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		Else If Year=2015 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2014 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2013 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2012 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2011 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2010 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2009 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2008 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2007 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2006 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2005 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2004 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2003 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2002 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2001 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		ELSE If Year=2000 and WTCAT^="" Then do;
			Age_Model=AGEYR;
			If "&COUNTY."="N" then do;
				State_ZIP_Model=Cats(STATE_ALPHA, GEO3);
			End;
			Else do;
				State_ZIP_Model=Cats(STATE_ALPHA, Substr(ZIP, 1, 3));
			End;	
			Geography=Geography;
			Sex_Model=Sex;
		End;
		Else Delete;

		/*@Action: Hard code ZIP collapse (Module 3) ***/
		If State_ZIP_Model='RI029' Then State_ZIP_Model='RI020';
		If State_ZIP_Model='NH035' Then State_ZIP_Model='NH030';
		If State_ZIP_Model='VT050' Then State_ZIP_Model='VT050';
		If State_ZIP_Model='VT052' Then State_ZIP_Model='VT050';
		If State_ZIP_Model='VT056' Then State_ZIP_Model='VT050';
		If State_ZIP_Model='VT057' Then State_ZIP_Model='VT050';
		If State_ZIP_Model='CT069' Then State_ZIP_Model='CT060';
		If State_ZIP_Model='NJ071' Then State_ZIP_Model='NJ070';
		If State_ZIP_Model='NJ073' Then State_ZIP_Model='NJ070';
		If State_ZIP_Model='NJ075' Then State_ZIP_Model='NJ070';
		If State_ZIP_Model='NJ081' Then State_ZIP_Model='NJ080';
		If State_ZIP_Model='NJ083' Then State_ZIP_Model='NJ080';
		If State_ZIP_Model='NJ084' Then State_ZIP_Model='NJ080';
		If State_ZIP_Model='NJ089' Then State_ZIP_Model='NJ080';
		If State_ZIP_Model='NY101' Then State_ZIP_Model='NY100';
		If State_ZIP_Model='NY108' Then State_ZIP_Model='NY100';
		If State_ZIP_Model='NY111' Then State_ZIP_Model='NY110';
		If State_ZIP_Model='NY116' Then State_ZIP_Model='NY110';
		If State_ZIP_Model='NY135' Then State_ZIP_Model='NY130';
		If State_ZIP_Model='NY139' Then State_ZIP_Model='NY130';
		If State_ZIP_Model='NY149' Then State_ZIP_Model='NY140';
		If State_ZIP_Model='PA158' Then State_ZIP_Model='PA150';
		If State_ZIP_Model='PA162' Then State_ZIP_Model='PA160';
		If State_ZIP_Model='PA169' Then State_ZIP_Model='PA160';
		If State_ZIP_Model='PA185' Then State_ZIP_Model='PA180';
		If State_ZIP_Model='PA188' Then State_ZIP_Model='PA180';
		If State_ZIP_Model='VA246' Then State_ZIP_Model='VA240';
		If State_ZIP_Model='GA312' Then State_ZIP_Model='GA310';
		If State_ZIP_Model='TN422' Then State_ZIP_Model='TN420';
		If State_ZIP_Model='MI499' Then State_ZIP_Model='MI490';
		If State_ZIP_Model='IA513' Then State_ZIP_Model='IA510';
		If State_ZIP_Model='IA528' Then State_ZIP_Model='IA520';
		If State_ZIP_Model='WI532' Then State_ZIP_Model='WI530';
		If State_ZIP_Model='WI534' Then State_ZIP_Model='WI530';
		If State_ZIP_Model='WI537' Then State_ZIP_Model='WI530';
		If State_ZIP_Model='WI538' Then State_ZIP_Model='WI530';
		If State_ZIP_Model='WI541' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI542' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI543' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI544' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI545' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI546' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI547' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI548' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='WI549' Then State_ZIP_Model='WI540';
		If State_ZIP_Model='MN557' Then State_ZIP_Model='MN550';
		If State_ZIP_Model='MN558' Then State_ZIP_Model='MN550';
		If State_ZIP_Model='MN567' Then State_ZIP_Model='MN560';
		If State_ZIP_Model='SD573' Then State_ZIP_Model='SD570';
		If State_ZIP_Model='SD574' Then State_ZIP_Model='SD570';
		If State_ZIP_Model='SD575' Then State_ZIP_Model='SD570';
		If State_ZIP_Model='ND582' Then State_ZIP_Model='ND580';
		If State_ZIP_Model='MT590' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT591' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT594' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT595' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT596' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT597' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT598' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MT599' Then State_ZIP_Model='MT590';
		If State_ZIP_Model='MO636' Then State_ZIP_Model='MO630';
		If State_ZIP_Model='MO637' Then State_ZIP_Model='MO630';
		If State_ZIP_Model='MO638' Then State_ZIP_Model='MO630';
		If State_ZIP_Model='KS666' Then State_ZIP_Model='KS660';
		If State_ZIP_Model='KS667' Then State_ZIP_Model='KS660';
		If State_ZIP_Model='KS668' Then State_ZIP_Model='KS660';
		If State_ZIP_Model='KS670' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS671' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS672' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS673' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS677' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS678' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='KS679' Then State_ZIP_Model='KS670';
		If State_ZIP_Model='NE693' Then State_ZIP_Model='NE690';
		If State_ZIP_Model='LA713' Then State_ZIP_Model='LA710';
		If State_ZIP_Model='AR718' Then State_ZIP_Model='AR710';
		If State_ZIP_Model='OK736' Then State_ZIP_Model='OK730';
		If State_ZIP_Model='OK738' Then State_ZIP_Model='OK730';
		If State_ZIP_Model='OK739' Then State_ZIP_Model='OK730';
		If State_ZIP_Model='OK745' Then State_ZIP_Model='OK740';
		If State_ZIP_Model='OK746' Then State_ZIP_Model='OK740';
		If State_ZIP_Model='OK747' Then State_ZIP_Model='OK740';
		If State_ZIP_Model='TX755' Then State_ZIP_Model='TX750';
		If State_ZIP_Model='TX788' Then State_ZIP_Model='TX780';
		If State_ZIP_Model='CO807' Then State_ZIP_Model='CO800';
		If State_ZIP_Model='CO810' Then State_ZIP_Model='CO810';
		If State_ZIP_Model='WY820' Then State_ZIP_Model='WY820';
		If State_ZIP_Model='WY822' Then State_ZIP_Model='WY820';
		If State_ZIP_Model='WY824' Then State_ZIP_Model='WY820';
		If State_ZIP_Model='WY825' Then State_ZIP_Model='WY820';
		If State_ZIP_Model='WY828' Then State_ZIP_Model='WY820';
		If State_ZIP_Model='ID832' Then State_ZIP_Model='ID830';
		If State_ZIP_Model='ID835' Then State_ZIP_Model='ID830';
		If State_ZIP_Model='AZ859' Then State_ZIP_Model='AZ850';
		If State_ZIP_Model='AZ865' Then State_ZIP_Model='AZ860';
		If State_ZIP_Model='NM873' Then State_ZIP_Model='NM870';
		If State_ZIP_Model='NM877' Then State_ZIP_Model='NM870';
		If State_ZIP_Model='NM883' Then State_ZIP_Model='NM880';
		If State_ZIP_Model='NV895' Then State_ZIP_Model='NV890';
		If State_ZIP_Model='NV897' Then State_ZIP_Model='NV890';
		If State_ZIP_Model='NV898' Then State_ZIP_Model='NV890';
		If State_ZIP_Model='CA903' Then State_ZIP_Model='CA900';
		If State_ZIP_Model='CA905' Then State_ZIP_Model='CA900';
		If State_ZIP_Model='CA943' Then State_ZIP_Model='CA940';
		If State_ZIP_Model='CA944' Then State_ZIP_Model='CA940';
		If State_ZIP_Model='CA946' Then State_ZIP_Model='CA940';
		If State_ZIP_Model='CA947' Then State_ZIP_Model='CA940';
		If State_ZIP_Model='CA948' Then State_ZIP_Model='CA940';
		If State_ZIP_Model='CA961' Then State_ZIP_Model='CA960';
		If State_ZIP_Model='WA988' Then State_ZIP_Model='WA980';
		If State_ZIP_Model='WA994' Then State_ZIP_Model='WA990';
		If State_ZIP_Model='AK998' Then State_ZIP_Model='AK990';
		If State_ZIP_Model='AK999' Then State_ZIP_Model='AK990';

		/*@Action: Recode Race values ***/
		If Race="White" Then Race_Resp=1;
			Else If Race="Black" Then Race_Resp=2;
			Else If Race="Asian" Then Race_Resp=3;
			Else If Race="Other" Then Race_Resp=4;

		/*@Action: Select single condition when more than one present ***/
		Length Condition $6.;
		If SCD=1 Then Condition="SCD";
				Run;

proc sort data=PreEHR_PQ_Pre0;
	by patid descending year;
run;

proc sort data=PreEHR_PQ_Pre0 out=PreEHR_PQ_Pre nodupkey;
	by patid;
run;

/*@Action: Separate File into three pieces to be used in race imputation process ***/
/*@Note: Module 1 -- Known condition information ***/
Data People_with_Condition;
	Set PreEHR_PQ_Pre;
		if Condition^="" and Race in ("Unknown", "Hispanic");
Run;

/*@Action: Module 2&3 Prep ***/
Proc Sql;
	/*@Note: Module 2 -- Indicated as Hispanic race with no condition information ***/
	Create table People_with_Hispanic as
		Select *
			from PreEHR_PQ_Pre
				Where Race = "Hispanic" and PATID not in (Select distinct PATID from People_with_Condition);

	/*@Note: Module 3 -- All remaining (No conditions and not indicated as Hispanic) ***/
	Create table People_Impute_By_Model as
		Select *
			from PreEHR_PQ_Pre
				Where PATID not in (Select distinct PATID From People_with_Condition) and
					  PATID not in (Select distinct PATID From People_with_Hispanic) and
					  Race = "Unknown";
Quit;

/*@Action: Run each of the Pre-Processing PQ modules ***/
%Include "&PROGS_PRE.\&Module0..sas" /LRECL=500;
%Include "&PROGS_PRE.\&Module1..sas" /LRECL=500;
%Include "&PROGS_PRE.\&Module2..sas" /LRECL=500;
%Include "&PROGS_PRE.\&Module3..sas" /LRECL=500;

/*@Action: Remove those who were imputed as Hispanic in Phase 1*/
Data Imputed_Race_by_Cond_Nonhispanic;
	Set IMPUTED_RACE_BY_COND;
		Where IMPUTE_RACE ne "Hispanic";
			Run;

/*@Action: Compile imputed Race values and add to output file ***/
Data Imputed_Race_Values(Keep=PATID Impute_Race);
	Set Imputed_Race_by_Cond_Nonhispanic Imputed_Race_by_Hisp Imputed_Race_by_Model;
Proc Sort Data=Imputed_Race_Values;
	By PATID;
Proc Sort Data=&EHR_PRE_Out.;
	By PATID;
Data SASOut.Pre_Processed_&EHR_PRE_Out.(Drop=Impute_Race);
	Merge &EHR_PRE_Out.(in=A) Imputed_Race_Values(in=B);
		By PATID;
			Length Imputed_Race $7.;
			Race_Imputed=0;
			If A and B Then Do;
				Imputed_Race=Impute_Race;
				Race_Imputed=1;
			End;
			Else if A and ^(B) and Race in ("Unknown","Hispanic") Then Imputed_Race="Unknown";
			Else Imputed_Race=Race;
			If PATID="" THEN DELETE;
Run;

/*@Action: Clear temporary work library ***/
Proc Datasets Library=WORK Kill Nolist;
Quit;

/*@Action: Cease SAS Log output ***/
Proc Printto;
Run;
/*@PROGRAM END ***/
