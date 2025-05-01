/*****************************************************************************************/
/***PROGRAM: Quickstart-Pre_Processing_CODI_PQ_GEO3.SAS						  	   ***/
/***VERSION: 1.0																	   ***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)						   ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago) and ERIN TANENBAUM (NORC at the University of Chicago)		   ***/
/***DATE CREATED: 7/20/2020, DATE LAST MOD: 12/07/2021								   ***/
/***INPUT: American Community Survey - ZCTA3-level (CSV) or American Community Survey - County-level (CSV)		   					   ***/
/***INPUT: EHR data file (CSV)														   ***/
/***OUTPUT: Pre-Processed American Community Survey -ZCTA3-Level (SAS)	or Pre-Processed American Community Survey -County-Level (SAS)				   ***/
/***OUTPUT: Pre-Processed EHR SAS file (SAS)							   			   ***/
/***OBJECTIVE: PREPROCESSES CHILDHOOD and TEEN OBESITY EHR DATA and ACS ZCTA3/County DATA     ***/
/***OBJECTIVE: IMPORT ACS 5-YEAR FILE. APPLY FORMATS, EDITS AND  					   ***/
/***OBJECTIVE: CHECK FOR INCONSISTENCIES/MISSINGNESS. OUTPUT FILE INTO A SAS DATAFILE. ***/
/***OBJECTIVE: REPEATS WITH EHR DATA												   ***/
/*****************************************************************************************/

/*************************************************************************************************************************************/
/*********************** -- PREPROCESSING ALGORITHM USER INPUT SECTION (PLEASE COMPLETE SECTIONS 1-4 BELOW)	-- ***********************/
/******************* -- PLEASE UPDATE THE BLACK TEXT AFTER THE EQUAL SIGN  (ACCEPTED VALUES LISTED IN SAS NOTE) -- *******************/
/*************************************************************************************************************************************/
/*SECTION 1: Input Folder and file names																								    ***/
/***/ %LET ROOT_PRE		= P:\Example;		/*@Note: base directory (ACCEPTABLE VALUES: computer directory name) ***/
/***/ %LET PRE_DEST		= CODI_PQ;		/*@Note: Suffix name for EHR Output folder (ACCEPTABLE VALUES: folder name (no puctuation) 		      ***/
/***/ %LET ACS_FILENAME	= ACS_State_ZCTA3;	  	 /*@Note: ACS file name (ACCEPTABLE VALUES: file name, do not include ".csv") ***/
/***/ %LET EHR_FILENAME = EHRFile;			 /*@Note: EHR file name (ACCEPTABLE VALUES: file name, do not include ".csv") 17 characters or less***/
/***/ %LET EHR_PRE_OUT	= SAVE_FILE_HERE; /*@Note: Optional, name the pre-processing output file (ACCEPTABLE VALUES: file name (no punctuations)) ***/
/***/ %LET LOG_NAME_PRE	= Pre_Processing_Peds; /*@Note: SAS log file name prefix ACCEPTABLE VALUES: SAS file name (no punctuation) 	   ***/

/*SECTION 2: Beginning and End Year of longitudinal EHR data																			   ***/
/***/ %LET BEGIN_YEAR = 2015; /*@Note: LONGITUDINAL Start year (ACCEPTABLE VALUES: 4-digit numeric year) ***/
/***/ %LET END_YEAR	  = 2019; /*@Note: LONGITUDINAL End year (ACCEPTABLE VALUES: 4-digit numeric year)   ***/

/***/ %LET COUNTY=N; /*@Note: County/ZCTA3 indicator (ACCEPTABLE VALUES: Y for County level data, N for ZCTA3 level data	 ***/ 

/***Note: ROOT_PRE directory includes subfolders: 
								"..\0_Raw_Data" 
								"..\1_SAS_Programs"
								"..\2_Output" and 
								"..\2_Output\SAS LOGS"										   									 	***/
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


/***/ %LET PROGS_PRE	= &Root_PRE.\1_SAS_Programs\Pre_Processing_GEO3;/*@Note: where SAS programs are stored (ACCEPTABLE VALUES: computer directory name) ***/
/***NOTE: SAS programs must be stored in the PROGS_PRE directory including: 
								Module0-Pre_Processing_CODI_PQ.sas
								Module1-Pre_Processing_CODI_PQ.sas
								Module2-Pre_Processing_CODI_PQ.sas
								Module3-Pre_Processing_CODI_PQ.sas		   															***/













/*@Action: Set SAS options ***/
Options Fullstimer Nofmterr Mlogic Mprint Minoperator SymbolGen Compress=Yes;

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

%LET REG_EST_NAME = Pre_PQ_Reg_Est_CODI10;			  /*@Note: Regression estimates SAS filename (ACCEPTABLE VALUES: file name, do not include ".sas7bdat") ***/
%LET MODULE0 =Module0-Pre_Processing_CODI_PQ_GEO3; /*@Note: Module 1 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE1 =Module1-Pre_Processing_CODI_PQ_GEO3; /*@Note: Module 1 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE2 =Module2-Pre_Processing_CODI_PQ_GEO3; /*@Note: Module 2 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/
%LET MODULE3 =Module3-Pre_Processing_CODI_PQ_GEO3; /*@Note: Module 3 (ACCEPTABLE VALUES: name of SAS program, do not include ".sas") ***/

/*@Action: Check if optional input value was entered missing, if missing set default ***/
%Macro Check_Optional;
	%If "&EHR_PRE_Out." = "" %Then %Let EHR_PRE_Out = CODI_PQ_GEO3;
%Mend;
%Check_Optional;

/*@Action: Create LOG/PDF output folder and begin SAS log and PDF output ***/
SYSTASK COMMAND "MKDIR ""&ROOT_Pre.\2_Output\SAS LOG""" WAIT;
Proc Printto Log="&ROOT_Pre.\2_Output\SAS LOG\&LOG_NAME_PRE._&DateTime..log" New; Run;

/*@Action: Create and initialize SAS output Destination library ***/
SYSTASK COMMAND "MKDIR ""&ROOT_Pre.\2_Output\Pre_Processed_&Pre_Dest.""" WAIT;
Libname SASOut "&ROOT_Pre.\2_Output\Pre_Processed_&Pre_Dest.";

/*@Action: Create formats for literal text translation ***/
Proc Format;
		/*@Note: Weight Categories ***/
		Value $WgtCat "Underweight"    = "(1) Underweight (<5th percentile)"
					  "Normal or Healthy Weight" = "(2) Healthy Weight (5th to <85th percentile)"
					  "Overweight" 	   = "(3) Overweight (85th to <95th percentile)"
					  "Obese" 	   	   = "(4) Obesity (>95th percentile)"
					  "Severe Obesity" = "(4b) Severe Obesity (>120% of the 95th percentile)"
					  Other 		   = " "
					  ;

	/*@Note: Age Categories ***/
	Value Wgt_Age 2 - 4  = "02 - 04"
			  5 - 9  = "05 - 09"
			 10 - 14 = "10 - 14"
			 15 - 17 = "15 - 17"
			 18 - 19 = "18 - 19"
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
%Let ACSOriginal=B01001A_003 B01001A_004 B01001A_005 B01001A_006 B01001A_007 B01001A_018 B01001A_019
B01001A_020 B01001A_021 B01001A_022 B01001B_003 B01001B_004 B01001B_005 B01001B_006 B01001B_007
B01001B_018 B01001B_019 B01001B_020 B01001B_021 B01001B_022 B01001C_003 B01001C_004 B01001C_005
B01001C_006 B01001C_007 B01001C_018 B01001C_019 B01001C_020 B01001C_021 B01001C_022 B01001D_003
B01001D_004 B01001D_005 B01001D_006 B01001D_007 B01001D_018 B01001D_019 B01001D_020 B01001D_021
B01001D_022 B01001E_003 B01001E_004 B01001E_005 B01001E_006 B01001E_007 B01001E_018 B01001E_019
B01001E_020 B01001E_021 B01001E_022 B01001F_003 B01001F_004 B01001F_005 B01001F_006 B01001F_007
B01001F_018 B01001F_019 B01001F_020 B01001F_021 B01001F_022 B01001G_003 B01001G_004 B01001G_005
B01001G_006 B01001G_007 B01001G_018 B01001G_019 B01001G_020 B01001G_021 B01001G_022 B15001_011
B15001_017 B15001_018 B15001_019 B15001_025 B15001_026 B15001_027 B15001_033 B15001_034 B15001_052
B15001_058 B15001_059 B15001_060 B15001_066 B15001_067 B15001_068 B15001_074 B15001_075 B03002_012
B03002_013 B03002_014 B03002_015 B03002_016 B03002_017 B03002_018 B03002_019 B01001A_001 B01001B_001
B01001C_001 B01001D_001 B01001E_001 B01001F_001 B01001G_001;

/*@Action: Final list of ACS variables ***/
%Let ACSNew=TOTAL_ACS_POPULATION AGE_L5_MALE_WHITE AGE_5_9_MALE_WHITE AGE_10_14_MALE_WHITE AGE_15_17_MALE_WHITE
AGE_18_19_MALE_WHITE AGE_L5_FEMALE_WHITE AGE_5_9_FEMALE_WHITE AGE_10_14_FEMALE_WHITE AGE_15_17_FEMALE_WHITE
AGE_18_19_FEMALE_WHITE AGE_L5_MALE_BLACK AGE_5_9_MALE_BLACK AGE_10_14_MALE_BLACK AGE_15_17_MALE_BLACK
AGE_18_19_MALE_BLACK AGE_L5_FEMALE_BLACK AGE_5_9_FEMALE_BLACK AGE_10_14_FEMALE_BLACK AGE_15_17_FEMALE_BLACK
AGE_18_19_FEMALE_BLACK AGE_L5_MALE_ASIAN AGE_5_9_MALE_ASIAN AGE_10_14_MALE_ASIAN AGE_15_17_MALE_ASIAN
AGE_18_19_MALE_ASIAN AGE_L5_FEMALE_ASIAN AGE_5_9_FEMALE_ASIAN AGE_10_14_FEMALE_ASIAN AGE_15_17_FEMALE_ASIAN
AGE_18_19_FEMALE_ASIAN AGE_L5_MALE_OTHER AGE_5_9_MALE_OTHER AGE_10_14_MALE_OTHER AGE_15_17_MALE_OTHER
AGE_18_19_MALE_OTHER AGE_L5_FEMALE_OTHER AGE_5_9_FEMALE_OTHER AGE_10_14_FEMALE_OTHER AGE_15_17_FEMALE_OTHER
AGE_18_19_FEMALE_OTHER AGE_25_64_BACH_GRAD AGE_25_64_BACH_GRAD_GTR20PERC TOTAL_LATIN LATIN_WHITE LATIN_BLACK
LATIN_ASIAN LATIN_OTHER;

/*@Action: Rename statements to rename original ACS variables into standardized names ***/
%Let ACSRename=%Str(B01001A_003=AGE_L5_MALE_WHITE B01001A_004=AGE_5_9_MALE_WHITE B01001A_005=AGE_10_14_MALE_WHITE
B01001A_006=AGE_15_17_MALE_WHITE B01001A_007=AGE_18_19_MALE_WHITE B01001A_018=AGE_L5_FEMALE_WHITE
B01001A_019=AGE_5_9_FEMALE_WHITE B01001A_020=AGE_10_14_FEMALE_WHITE B01001A_021=AGE_15_17_FEMALE_WHITE
B01001A_022=AGE_18_19_FEMALE_WHITE B01001B_003=AGE_L5_MALE_BLACK B01001B_004=AGE_5_9_MALE_BLACK
B01001B_005=AGE_10_14_MALE_BLACK B01001B_006=AGE_15_17_MALE_BLACK B01001B_007=AGE_18_19_MALE_BLACK
B01001B_018=AGE_L5_FEMALE_BLACK B01001B_019=AGE_5_9_FEMALE_BLACK B01001B_020=AGE_10_14_FEMALE_BLACK
B01001B_021=AGE_15_17_FEMALE_BLACK B01001B_022=AGE_18_19_FEMALE_BLACK B01001C_003=AGE_L5_MALE_AIAN
B01001C_004=AGE_5_9_MALE_AIAN B01001C_005=AGE_10_14_MALE_AIAN B01001C_006=AGE_15_17_MALE_AIAN
B01001C_007=AGE_18_19_MALE_AIAN B01001C_018=AGE_L5_FEMALE_AIAN B01001C_019=AGE_5_9_FEMALE_AIAN
B01001C_020=AGE_10_14_FEMALE_AIAN B01001C_021=AGE_15_17_FEMALE_AIAN B01001C_022=AGE_18_19_FEMALE_AIAN
B01001D_003=AGE_L5_MALE_ASIAN B01001D_004=AGE_5_9_MALE_ASIAN B01001D_005=AGE_10_14_MALE_ASIAN
B01001D_006=AGE_15_17_MALE_ASIAN B01001D_007=AGE_18_19_MALE_ASIAN B01001D_018=AGE_L5_FEMALE_ASIAN
B01001D_019=AGE_5_9_FEMALE_ASIAN B01001D_020=AGE_10_14_FEMALE_ASIAN B01001D_021=AGE_15_17_FEMALE_ASIAN
B01001D_022=AGE_18_19_FEMALE_ASIAN B01001E_003=AGE_L5_MALE_NHPI B01001E_004=AGE_5_9_MALE_NHPI
B01001E_005=AGE_10_14_MALE_NHPI B01001E_006=AGE_15_17_MALE_NHPI B01001E_007=AGE_18_19_MALE_NHPI
B01001E_018=AGE_L5_FEMALE_NHPI B01001E_019=AGE_5_9_FEMALE_NHPI B01001E_020=AGE_10_14_FEMALE_NHPI
B01001E_021=AGE_15_17_FEMALE_NHPI B01001E_022=AGE_18_19_FEMALE_NHPI B01001F_003=AGE_L5_MALE_OTHER
B01001F_004=AGE_5_9_MALE_OTHER B01001F_005=AGE_10_14_MALE_OTHER B01001F_006=AGE_15_17_MALE_OTHER
B01001F_007=AGE_18_19_MALE_OTHER B01001F_018=AGE_L5_FEMALE_OTHER B01001F_019=AGE_5_9_FEMALE_OTHER
B01001F_020=AGE_10_14_FEMALE_OTHER B01001F_021=AGE_15_17_FEMALE_OTHER B01001F_022=AGE_18_19_FEMALE_OTHER
B01001G_003=AGE_L5_MALE_GE2R B01001G_004=AGE_5_9_MALE_GE2R B01001G_005=AGE_10_14_MALE_GE2R
B01001G_006=AGE_15_17_MALE_GE2R B01001G_007=AGE_18_19_MALE_GE2R B01001G_018=AGE_L5_FEMALE_GE2R
B01001G_019=AGE_5_9_FEMALE_GE2R B01001G_020=AGE_10_14_FEMALE_GE2R B01001G_021=AGE_15_17_FEMALE_GE2R
B01001G_022=AGE_18_19_FEMALE_GE2R B15001_011=AGE_25_34_MALE_EDUC B15001_017=AGE_25_34_MALE_BACHELOR
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

			/*@Action: Combine specific race categories with others ***/
			/*@Note: NHPI is collapsed into ASIAN ***/
			AGE_L5_MALE_ASIAN=AGE_L5_MALE_ASIAN+AGE_L5_MALE_NHPI;
			AGE_5_9_MALE_ASIAN=AGE_5_9_MALE_ASIAN+AGE_5_9_MALE_NHPI;
			AGE_10_14_MALE_ASIAN=AGE_10_14_MALE_ASIAN+AGE_10_14_MALE_NHPI;
			AGE_15_17_MALE_ASIAN=AGE_15_17_MALE_ASIAN+AGE_15_17_MALE_NHPI;
			AGE_18_19_MALE_ASIAN=AGE_18_19_MALE_ASIAN+AGE_18_19_MALE_NHPI;
			AGE_L5_FEMALE_ASIAN=AGE_L5_FEMALE_ASIAN+AGE_L5_FEMALE_NHPI;
			AGE_5_9_FEMALE_ASIAN=AGE_5_9_FEMALE_ASIAN+AGE_5_9_FEMALE_NHPI;
			AGE_10_14_FEMALE_ASIAN=AGE_10_14_FEMALE_ASIAN+AGE_10_14_FEMALE_NHPI;
			AGE_15_17_FEMALE_ASIAN=AGE_15_17_FEMALE_ASIAN+AGE_15_17_FEMALE_NHPI;
			AGE_18_19_FEMALE_ASIAN=AGE_18_19_FEMALE_ASIAN+AGE_18_19_FEMALE_NHPI;
			LATIN_ASIAN=LAT_ASIAN+LAT_NHPI;

			/*@Note: GE2R and AIAN are collapsed into OTHER ***/
			AGE_L5_MALE_OTHER=AGE_L5_MALE_OTHER+AGE_L5_MALE_GE2R+AGE_L5_MALE_AIAN;
			AGE_5_9_MALE_OTHER=AGE_5_9_MALE_OTHER+AGE_5_9_MALE_GE2R+AGE_5_9_MALE_AIAN;
			AGE_10_14_MALE_OTHER=AGE_10_14_MALE_OTHER+AGE_10_14_MALE_GE2R+AGE_10_14_MALE_AIAN;
			AGE_15_17_MALE_OTHER=AGE_15_17_MALE_OTHER+AGE_15_17_MALE_GE2R+AGE_15_17_MALE_AIAN;
			AGE_18_19_MALE_OTHER=AGE_18_19_MALE_OTHER+AGE_18_19_MALE_GE2R+AGE_18_19_MALE_AIAN;
			AGE_L5_FEMALE_OTHER=AGE_L5_FEMALE_OTHER+AGE_L5_FEMALE_GE2R+AGE_L5_FEMALE_AIAN;
			AGE_5_9_FEMALE_OTHER=AGE_5_9_FEMALE_OTHER+AGE_5_9_FEMALE_GE2R+AGE_5_9_FEMALE_AIAN;
			AGE_10_14_FEMALE_OTHER=AGE_10_14_FEMALE_OTHER+AGE_10_14_FEMALE_GE2R+AGE_10_14_FEMALE_AIAN;
			AGE_15_17_FEMALE_OTHER=AGE_15_17_FEMALE_OTHER+AGE_15_17_FEMALE_GE2R+AGE_15_17_FEMALE_AIAN;
			AGE_18_19_FEMALE_OTHER=AGE_18_19_FEMALE_OTHER+AGE_18_19_FEMALE_GE2R+AGE_18_19_FEMALE_AIAN;
			LATIN_OTHER=LAT_OTHER+LAT_GE2R+LAT_AIAN;

			/*@Note: Compute % of adults aged 25-64 with Education Bachelor+ ***/
			AGE_25_64_BACH_GRAD=Sum(AGE_25_34_MALE_BACHELOR, AGE_25_34_FEMALE_BACHELOR, AGE_35_44_MALE_BACHELOR, AGE_35_44_FEMALE_BACHELOR, AGE_45_64_MALE_BACHELOR, AGE_45_64_FEMALE_BACHELOR, AGE_25_34_MALE_GRAD_PROF, AGE_25_34_FEMALE_GRAD_PROF, AGE_35_44_MALE_GRAD_PROF, AGE_35_44_FEMALE_GRAD_PROF, AGE_45_64_MALE_GRAD_PROF, AGE_45_64_FEMALE_GRAD_PROF)/Sum(AGE_25_34_MALE_EDUC, AGE_25_34_FEMALE_EDUC, AGE_35_44_MALE_EDUC, AGE_35_44_FEMALE_EDUC, AGE_45_64_MALE_EDUC, AGE_45_64_FEMALE_EDUC);
			AGE_25_64_BACH_GRAD_GTR20PERC=(AGE_25_64_BACH_GRAD>0.2);
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
   
			/*@Action: Combine specific race categories with others ***/
			/*@Note: NHPI is collapsed into ASIAN ***/
			AGE_L5_MALE_ASIAN=AGE_L5_MALE_ASIAN+AGE_L5_MALE_NHPI;
			AGE_5_9_MALE_ASIAN=AGE_5_9_MALE_ASIAN+AGE_5_9_MALE_NHPI;
			AGE_10_14_MALE_ASIAN=AGE_10_14_MALE_ASIAN+AGE_10_14_MALE_NHPI;
			AGE_15_17_MALE_ASIAN=AGE_15_17_MALE_ASIAN+AGE_15_17_MALE_NHPI;
			AGE_18_19_MALE_ASIAN=AGE_18_19_MALE_ASIAN+AGE_18_19_MALE_NHPI;
			AGE_L5_FEMALE_ASIAN=AGE_L5_FEMALE_ASIAN+AGE_L5_FEMALE_NHPI;
			AGE_5_9_FEMALE_ASIAN=AGE_5_9_FEMALE_ASIAN+AGE_5_9_FEMALE_NHPI;
			AGE_10_14_FEMALE_ASIAN=AGE_10_14_FEMALE_ASIAN+AGE_10_14_FEMALE_NHPI;
			AGE_15_17_FEMALE_ASIAN=AGE_15_17_FEMALE_ASIAN+AGE_15_17_FEMALE_NHPI;
			AGE_18_19_FEMALE_ASIAN=AGE_18_19_FEMALE_ASIAN+AGE_18_19_FEMALE_NHPI;
			LATIN_ASIAN=LAT_ASIAN+LAT_NHPI;

			/*@Note: GE2R and AIAN are collapsed into OTHER ***/
			AGE_L5_MALE_OTHER=AGE_L5_MALE_OTHER+AGE_L5_MALE_GE2R+AGE_L5_MALE_AIAN;
			AGE_5_9_MALE_OTHER=AGE_5_9_MALE_OTHER+AGE_5_9_MALE_GE2R+AGE_5_9_MALE_AIAN;
			AGE_10_14_MALE_OTHER=AGE_10_14_MALE_OTHER+AGE_10_14_MALE_GE2R+AGE_10_14_MALE_AIAN;
			AGE_15_17_MALE_OTHER=AGE_15_17_MALE_OTHER+AGE_15_17_MALE_GE2R+AGE_15_17_MALE_AIAN;
			AGE_18_19_MALE_OTHER=AGE_18_19_MALE_OTHER+AGE_18_19_MALE_GE2R+AGE_18_19_MALE_AIAN;
			AGE_L5_FEMALE_OTHER=AGE_L5_FEMALE_OTHER+AGE_L5_FEMALE_GE2R+AGE_L5_FEMALE_AIAN;
			AGE_5_9_FEMALE_OTHER=AGE_5_9_FEMALE_OTHER+AGE_5_9_FEMALE_GE2R+AGE_5_9_FEMALE_AIAN;
			AGE_10_14_FEMALE_OTHER=AGE_10_14_FEMALE_OTHER+AGE_10_14_FEMALE_GE2R+AGE_10_14_FEMALE_AIAN;
			AGE_15_17_FEMALE_OTHER=AGE_15_17_FEMALE_OTHER+AGE_15_17_FEMALE_GE2R+AGE_15_17_FEMALE_AIAN;
			AGE_18_19_FEMALE_OTHER=AGE_18_19_FEMALE_OTHER+AGE_18_19_FEMALE_GE2R+AGE_18_19_FEMALE_AIAN;
			LATIN_OTHER=LAT_OTHER+LAT_GE2R+LAT_AIAN;

			/*@Note: Compute % of adults aged 25-64 with Education Bachelor+ ***/
			AGE_25_64_BACH_GRAD=Sum(AGE_25_34_MALE_BACHELOR, AGE_25_34_FEMALE_BACHELOR, AGE_35_44_MALE_BACHELOR, AGE_35_44_FEMALE_BACHELOR, AGE_45_64_MALE_BACHELOR, AGE_45_64_FEMALE_BACHELOR, AGE_25_34_MALE_GRAD_PROF, AGE_25_34_FEMALE_GRAD_PROF, AGE_35_44_MALE_GRAD_PROF, AGE_35_44_FEMALE_GRAD_PROF, AGE_45_64_MALE_GRAD_PROF, AGE_45_64_FEMALE_GRAD_PROF)/Sum(AGE_25_34_MALE_EDUC, AGE_25_34_FEMALE_EDUC, AGE_35_44_MALE_EDUC, AGE_35_44_FEMALE_EDUC, AGE_45_64_MALE_EDUC, AGE_45_64_FEMALE_EDUC);
			AGE_25_64_BACH_GRAD_GTR20PERC=(AGE_25_64_BACH_GRAD>0.2);
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

	/*@Action: Load import file and convert into SAS dataset 		 ***/
	/*@Note: This file will be copied into output destination folder ***/
	data Include_EHR0;
		%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
		Infile EHR dsd dlm="," lrecl=32767 firstobs=2 MISSOVER;
		informat patid $50.;
		informat sex_num best12.;
		informat ageyears best32.;
		informat race_eth $16.;
		informat state_abr $2.;
		informat geo3 $3.;
		informat weight_category $34.;
		informat year best12.;
		informat SCDCNT best12.;
		informat pregnancy_flag best12.;
		informat zip $5.;
		format patid $50.;
		format sex_num best12.;
		format ageyears best32.;
		format race_eth $16.;
		format state_abr $2.;
		format geo3 $3.;
		format weight_category $34.;
		format year best12.;
		format SCDCNT best12.;
		format pregnancy_flag best12.;
		format zip $5.;
		input
			patid $
			sex_num  
			ageyears
			race_eth  $
			state_abr  $
			geo3 $
			weight_category  $
			year 
			SCDCNT
			pregnancy_flag
			zip $
		;

		if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
	Run;

	Data Include_EHR;
		Set Include_EHR0;

		/*@Action: Perform various clean-up to the EHR file ***/
		If ^(2<=ageyears<=19) Then Do;
		 	weight_category="";
		  	state_abr="";
		  	geo3=.;
		End;

		If weight_category="" Then FLG_WTCAT=0;
		Else FLG_WTCAT=1;

		/*@Action: Assign weight category description ***/
		WTCAT_LIT = PUT(weight_category, $WgtCat.);

		/*@Action: Set Indicated Sex ***/
		Length Sex $8.;
		If sex_num=1 then Sex="Female";
			Else if sex_num=0 then Sex="Male";
			Else Sex="Unknown";

		/*@Action: Set Indicated Sex ***/
		Length Race $8.;
		If race_eth='AFRICAN AMERICAN' then Race='Black';
			Else if race_eth='ASIAN' then Race='Asian';
			Else if race_eth='CAUCASIAN' then Race='White';
			Else if race_eth='HISPANIC' then Race='Hispanic';
			Else if race_eth='OTHER' then Race='Other';
			Else if race_eth='UNKNOWN' then Race='Unknown';
			Else Race = race_eth;
	Run;

	/*@Action: Macro to keep order of yearly variables, dropping 2015 from list because out of scope ***/
	/*@Note: Keep list begins 1 year after begin date												 ***/
	%Macro SQL_Var_Order;
		%if &COUNTY.=N %then %do;
			AGEYEARS as AGEYR, Put(AGEYEARS, Wgt_Age.) as WGT_AGE_CATEGORIES, WTCAT_LIT as WTCAT, FLG_WTCAT,
			state_abr as STATE_ALPHA, Put(state_abr, $ALPHA_to_FIPS.) as STATE_FIPS, ZIP,
			GEO3, Cats(Calculated STATE_FIPS, GEO3) as Geography Length=5 Format=$5., SCDCNT, pregnancy_flag
		%end;
		%else %do;
			AGEYEARS as AGEYR, Put(AGEYEARS, Wgt_Age.) as WGT_AGE_CATEGORIES, WTCAT_LIT as WTCAT, FLG_WTCAT,
			state_abr as STATE_ALPHA, Put(state_abr, $ALPHA_to_FIPS.) as STATE_FIPS, ZIP,
			GEO3, Cats(Calculated STATE_FIPS, GEO3) as Geography Length=5 Format=$5., SCDCNT, pregnancy_flag
		%end;
	%Mend;

	/*@Action: Apply new ordering of variables and exclude any variables not needed for analysis ***/
	Proc Sql;
		Create table Include_EHR_Pre0 as
			Select PATID, %SQL_Var_Order, RACE, SEX, year
				From Include_EHR;
	Quit;		

	/*@Action: Check for bad geography in EHR data, defined as ACS population=0 or not present in ACS ***/
	/*@Note: Begins 1 year after begin date		   ***/
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

	/*@Action: Exclude records with bad geography or out of scope (i.e. younger than 2 or older than 19, or missing weight information for all years) ***/
	Data Initial_EHR_PreProcess(Drop=Bad_Geo FLG_WTCAT) Removed_EHR;
		Set Include_EHR_Pre;
			/*@Action: Exclude People outside 2-19 Ages Range ***/
			If (^(2<=AGEYR<=19)) or
				Sum(of FLG_WTCAT)=0 or 
				Sum(of Bad_Geo)=Sum(of FLG_WTCAT) Then Output Removed_EHR;
			Else Output Initial_EHR_PreProcess;
	Run;

	/*@Action: Create Condition Flags ***/
	Data &EHR_PRE_Out.;
		Set Initial_EHR_PreProcess;
			Length SCD 3.;
			Label SCD	 = "Sickle-Cell: Flag";
			If SCDCNT>0    Then SCD    = 1;    Else SCD=.;
	Run;

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
		Else If Year=2029 and WTCAT^="" Then do;
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
		Else If Year=2028 and WTCAT^="" Then do;
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
		Else If Year=2027 and WTCAT^="" Then do;
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
		Else If Year=2026 and WTCAT^="" Then do;
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
		Else If Year=2025 and WTCAT^="" Then do;
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
		Else If Year=2024 and WTCAT^="" Then do;
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
		Else If Year=2023 and WTCAT^="" Then do;
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
		Else If Year=2022 and WTCAT^="" Then do;
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
		Else If Year=2021 and WTCAT^="" Then do;
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
		Else If Year=2020 and WTCAT^="" Then do;
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
		Else If Year=2019 and WTCAT^="" Then do;
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
		Else If Year=2014 and WTCAT^="" Then do;
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
		Else If Year=2013 and WTCAT^="" Then do;
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
		Else If Year=2012 and WTCAT^="" Then do;
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
		Else If Year=2011 and WTCAT^="" Then do;
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
		Else If Year=2010 and WTCAT^="" Then do;
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
		Else If Year=2009 and WTCAT^="" Then do;
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
		Else If Year=2008 and WTCAT^="" Then do;
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
		Else If Year=2007 and WTCAT^="" Then do;
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
		Else If Year=2006 and WTCAT^="" Then do;
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
		Else If Year=2005 and WTCAT^="" Then do;
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
		Else If Year=2004 and WTCAT^="" Then do;
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
		Else If Year=2003 and WTCAT^="" Then do;
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
		Else If Year=2002 and WTCAT^="" Then do;
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
		Else If Year=2001 and WTCAT^="" Then do;
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
			Else Condition="";
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

/*@Action: subset the patients who were imputed as Hispanic in phase 1*/
Data Imputed_Race_by_Cond_nonHisp;
	Set Imputed_Race_by_Cond;
		Where find(IMPUTE_RACE,"HISPA","i")=0
			and Patid is not null;
				Run;

/*@Action: Compile imputed Race values and add to output file ***/
Data Imputed_Race_Values(Keep=PATID Impute_Race);
	Set Imputed_Race_by_Cond_nonHisp Imputed_Race_by_Hisp Imputed_Race_by_Model;
Run;
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
Run;

/*@Action: Clear temporary work library ***/
/*Proc Datasets Library=WORK Kill Nolist;
Quit;*/

/*@Action: Cease SAS Log output ***/
Proc Printto;
Run;
/*@PROGRAM END ***/
