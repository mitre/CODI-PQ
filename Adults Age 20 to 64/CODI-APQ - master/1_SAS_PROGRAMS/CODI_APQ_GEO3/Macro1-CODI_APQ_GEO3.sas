/*******************************************************************************************/
/***PROGRAM: Macro1-CODI_APQ_GEO3.SAS									 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)							 ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)					    ***/
/*******************************************************************************************/
%Macro Generate_ACS_Controls;
	 /*@Action: Renamed ACS variables that are needed to compute control totals ***/
	%Let ACSNew=AGE_20_24_MALE_WHITE AGE_25_29_MALE_WHITE AGE_30_34_MALE_WHITE
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
	AGE_55_64_FEMALE_OTHER AGE_25_64_BACH_GRAD_GTR10PERC;

	 /*@Action: Formats to standardize ACS values to IQVIA values being used ***/
	 Proc Format;
		/*@Note: Age Categories ***/
		Value $Age_ACS "AGE 20 24" = "20 - 24"
					   "AGE 25 29" = "25 - 29"
					   "AGE 30 34" = "30 - 34"
					   "AGE 35 44" = "35 - 44"
					   "AGE 45 54" = "45 - 54"
					   "AGE 55 64" = "55 - 64"
				  	   ;
		/*@Note: Sex ***/
		Value $Sex_ACS "MALE"   = "Male"
				  	   "FEMALE" = "Female"
					   ;
		/*@Note: Race ***/
		Value $Race_ACS "WHITE" = "White"
				  	    "BLACK" = "Black"
				 	    "ASIAN" = "Asian"
				  	    "OTHER" = "Other"
				  	    ;
	Run;

	/*@Action: Include on the variables necessary to compute control totals ***/
	Data Census_ACS_Prep_Final;
		Retain Geography State_FIPS STGEO3 &ACSNew.;
		Set SASIN.&FileIN_Name2.(Keep=Geography State_FIPS &ACSNew.);
			STGEO3=Geography;
	Run;

	/*@Action: Merge in new ages range (2-4) and drop L5 variables ***/
	/*@Note: Join key is ST+ZCTA3/COUNTY 								   ***/
	Proc Sql NOPRINT;
		select name into :ACS_Full_Var separated by " " from Dictionary.Columns where Libname="WORK" and Memname="CENSUS_ACS_PREP_FINAL" and Name not in ("State_FIPS","Geography","STGEO3","AGE_25_64_BACH_GRAD_GTR10PERC");
	Quit;

	/*@ACtion: Macro to re-orient table from horizontal to vertical ***/
	%Macro Reorient;
		%Let I=1; %Let Curr=%SCAN(&ACS_Full_Var., &I., " "); %Let Next=%SCAN(&ACS_Full_Var., %EVAL(&I.+1), " ");
		%DO %WHILE(&CURR. NE);
			%If "&Next."^="" %Then %Do;
				select Geography, State_FIPS, STGEO3, AGE_25_64_BACH_GRAD_GTR10PERC, "&Curr." as ACS_Var, &Curr. as ACS_Count from Census_ACS_Prep_Final union
			%End;
			%Else %Do;
				select Geography, State_FIPS, STGEO3, AGE_25_64_BACH_GRAD_GTR10PERC, "&Curr." as ACS_Var, &Curr. as ACS_Count from Census_ACS_Prep_Final
			%End;
		%Let I=%EVAL(&I.+1); %Let Curr=%SCAN(&ACS_Full_Var., &I., " "); %Let Next=%SCAN(&ACS_Full_Var., %EVAL(&I.+1), " ");
		%End;
	%Mend;

	Proc Sql;
		Create table ACS_Universe_Controls as
			%Reorient;;
	Quit;

	/*Action: Final ACS Control totals ***/
	/*@Note: Full ACS Universe totals ***/
	Data ACS_Controls_Full_Universe;
		Set ACS_Universe_Controls;
			Age_Categories=Put(Strip(Scan(ACS_Var, 1, "_")||" "||Scan(ACS_Var, 2, "_")||" "||Scan(ACS_Var, 3, "_")), $AGE_ACS.);
			Sex=Put(Scan(ACS_Var, 4, "_"), $Sex_ACS.);
			Race=Put(Scan(ACS_Var, 5, "_"), $RACE_ACS.);

	/*@Action: Apply User selection criteria to ACS file ***/
	/*@Note: Supressed race values are excluded 		 ***/
	Data ACS_Controls_User_Universe;
		Set ACS_Controls_Full_Universe;
			Where &Master_Logic.;
	run;

	%If "&Drop_Race."^="" %Then %do;
		Data ACS_Controls_User_Universe;
			Set ACS_Controls_User_Universe;
				Where Race not in (&Drop_Race.);
		Run;
	%end;

	/*@Action: Finish ACS control totals to be used in weighting ***/
	Proc Sql;
		Create table ACS_Age_Controls as
			Select Age_Categories as AGE_Raking, Sum(ACS_Count) as mrgtotal From ACS_Controls_User_Universe Group by Age_Categories;
		Create table ACS_Sex_Controls as
			Select Sex as SEX_Raking, Sum(ACS_Count) as mrgtotal From ACS_Controls_User_Universe Group by Sex;
		Create table ACS_Race_Controls as
			Select Race as RACE_Raking, Sum(ACS_Count) as mrgtotal From ACS_Controls_User_Universe Group by Race;
		Create table ACS_Geo_Controls as
			Select Geography as GEO_Raking, AGE_25_64_BACH_GRAD_GTR10PERC as Educ_Raking, Sum(ACS_Count) as mrgtotal From ACS_Controls_User_Universe Group by GEO_Raking, AGE_25_64_BACH_GRAD_GTR10PERC;
		Create table ACS_Geography_Totals as
			Select Geography, AGE_25_64_BACH_GRAD_GTR10PERC, Sum(ACS_COUNT) as ACS_POP_CNT from ACS_Controls_User_Universe group by Geography, AGE_25_64_BACH_GRAD_GTR10PERC;
	Quit;
%Mend;
/*@Program End ***/
