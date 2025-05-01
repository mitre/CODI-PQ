
/*******************************************************************************************/
/***PROGRAM: Module1-CODI_HPQ.SAS						 				 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)							 ***/
/***DESCRIPTION:  Prepare user selected data and sample size check						 ***/
/*******************************************************************************************/
 
/*** Check for valid selections  here***/

%macro HPQ;
%global HHAdultsSupress_Foot  RaceSupress_Foot ChildageSupress_Foot Collapse_Foot Perc_Imp_Race RaceImpute_Foot FailureCode; 

%Let HHAdultsSupress_Foot=(Error);
%Let RaceSupress_Foot=(Error); 
%Let ChildageSupress_Foot=(Error);
%Let FailureCode=0;
%Let Collapse_Foot=(Error);
%Let Perc_Imp_Race=(Error);


/*@Action: Reassign Empty Years for Macro Handling*/
%let YEAR_FOOT=&H_Year;
%if %length(&H_YEAR)=0 %then %do; %let H_YEAR=(Error); %end;
%if &GEO_H_GROUP.= %then %Let GEO_H_GROUP=invalid;

	/*@Action: Load User Input Macro vairables into a macro list ***/
	%Let Age_List  = %STR(AGE_UNDER_6, AGE_6_17, AGE_BOTH);
	%Let Race_List = %STR(RACE_WHITE, RACE_BLACK, RACE_ASIAN, RACE_OTHER);


	/*@Action: User input QC, default value set to no (N) ***/
	%Macro Selection_Default(Include_All, Var_List);
		/*@Note: If the ALL option is specified, set all macro selections to "Y" ***/
		%IF %SYSFUNC(UPCASE(&Include_All.)) = Y %THEN %DO;
			%Let I=1; %Let User_Input = %SCAN(&Var_List., &I., ",");
			%DO %WHILE(&User_Input. NE);
				%LET &USER_INPUT. = Y;
				%Let I=%EVAL(&I.+1); %Let User_Input = %SCAN(&Var_List., &I., ",");
			%END;
		%END;
		/*@Note: If the ALL option is not specified, check and correct (if invalid) individual macro selections ***/
		%ELSE %DO;
			%Let I=1; %Let User_Input = %SCAN(&Var_List., &I., ",");
			%DO %WHILE(&User_Input. NE);
				%IF %SUBSTR(%SYSFUNC(UPCASE(&&&User_Input.)), 1, 1)^=Y %THEN %LET &USER_INPUT. = N; %ELSE %LET &USER_INPUT. = Y;
				%Let I=%EVAL(&I.+1); %Let User_Input = %SCAN(&Var_List., &I., ",");
			%END;
		%END;
	%Mend;

	/*@Action: Execute USER QC Macro ***/
	%Selection_Default(Include_All=&ALL_H_AGES.,  Var_List=&Age_List.);
	%Selection_Default(Include_All=&All_Races., Var_List=&Race_List.);

	%Global STATE_LIST RACEVAR QUERY_FOOT AGE_FOOT RACE_FOOT GEOGRAPHY_FOOT YEAR_FOOT
			YEAR_FOOT MASTER_LOGIC
			AGE_QUERY RACE_QUERY;

	/****************************************************************/
	/*@Action: Construct query logic based on user macro input variables ***/

	%Let MASTER_LOGIC=; %Let STATE_LIST=;

	/*@Action Load user macro responses and values needed to select IQVIA records ***/
	/*@Note: AGE Selection, IF INDIVIDUAL VALUES CHANGE UPDATE AGE_VALUES VARIABLE ***/
	%Let AGE_REQUEST = %Sysfunc(CATS(&AGE_UNDER_6., &AGE_6_17., &AGE_BOTH.));
	%Let AGE_VALUES  = %STR(Under 6 years only,6 to 17 years only,Under 6 years and 6 to 17 years);
		
	/*@Note: RACE Selection, IF INDIVIDUAL VALUES CHANGE UPDATE RACE_VALUES VARIABLE ***/
	%If &IMP_RACES.=Y %Then %Let RACEVAR=IMPUTE_RACE; %Else %Let RACEVAR=RACE_ETH;
	%Let RACE_REQUEST = %Sysfunc(CATS(&RACE_WHITE., &RACE_BLACK., &RACE_ASIAN., &RACE_OTHER.));
	%Let RACE_VALUES = %STR(White,Black,Asian,Other);


	/*@Action: Load selection criteria into SQL query logic ***/
		%Macro Build_Query(Request, Values, Var, Query);

		%If %Sysfunc(COUNTC(&REQUEST., "Y"))>0 %Then %Do;
			%Let BUILD_QUERY=;
			%Let I=1; %Let VALUE = %Scan(&VALUES., &I., ",");
			%Do %While("&VALUE." NE "");
				%If %Substr(&REQUEST., &I., 1) = Y %Then %Do;
					%If "&BUILD_QUERY."="" %Then %Let BUILD_QUERY = %unquote(%str(%'&VALUE.%'));
						%Else %Let BUILD_QUERY = &BUILD_QUERY., %unquote(%str(%'&VALUE.%'));
				%End;
				%Let I = %Eval(&I.+1); %Let VALUE = %Scan(&VALUES., &I., ",");
			%End;

		%Let &Query._Query  = &BUILD_QUERY.;
		%Let &Query._FOOT  = %SYSFUNC(Compress((&BUILD_QUERY.), %str(%')));
			%If "&MASTER_LOGIC."="" %Then %Let MASTER_LOGIC = &Var. IN (&BUILD_QUERY.);
				%Else %Let MASTER_LOGIC = &MASTER_LOGIC. AND &Var. IN (&BUILD_QUERY.);
		%End;
		%Else %Let &Query._FOOT  = (None Selected);
		%put &BUILD_QUERY. &Query._FOOT;
	%Mend;

	%Build_Query(Request=&AGE_REQUEST.,  Values=&AGE_VALUES.,  Var=household_childage_cat, Query=AGE);
	%Build_Query(Request=&RACE_REQUEST., Values=&RACE_VALUES., Var=RACE, Query=RACE);



	%Global Geo_level;

	%If %Sysfunc(UPCASE(&GEO_H_GROUP.)) = STATE %Then %Let Geo_level=STATE_FIPS;
	%else %Let Geo_level=Geography;

	%let Foot_List=(Error);

	/*@Action: Logic for requested GEOGRAPHY ***/
	%IF &ALL_H_STATES.=Y %Then %Do;
		%Let GEO_H_LIST=%STR('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53','54','55','56');
		%Let GEOGRAPHY_FOOT  = National, all states selected (includes District of Columbia);

		/*@Action: Query logic for geography ***/
		%If "&MASTER_LOGIC."="" %Then %Let MASTER_LOGIC = STATE_FIPS IN (&GEO_H_LIST.);
			%Else %Let MASTER_LOGIC = &MASTER_LOGIC. AND STATE_FIPS IN (&GEO_H_LIST.);
	%End;

	%Else %If &GEO_H_GROUP. NE and &GEO_H_LIST. NE %Then %Do;
		%If %Sysfunc(UPCASE(&GEO_H_GROUP.)) = STATE %Then %Let QueryVar=STATE_FIPS;
			%Else %Let QueryVar=Geography;

		/*@Action: Query logic for geography ***/
		%If "&MASTER_LOGIC."="" %Then %Let MASTER_LOGIC = &QueryVar. IN (&GEO_H_LIST.);
			%Else %Let MASTER_LOGIC = &MASTER_LOGIC. AND &QueryVar. IN (&GEO_H_LIST.);

		/*@Action: Footnote for geography ***/
		%If %Sysfunc(UPCASE(&GEO_H_GROUP.)) = STATE %Then %Do;
			Proc Sql NOPRINT;
				Select Full_Label into :Foot_List separated by ", " from FIPS_Codes Where Label in (&GEO_H_LIST.);
			Quit;
			%Let GEOGRAPHY_FOOT = &Foot_List.;
		%End;
		%Else %If %Sysfunc(UPCASE(&GEO_H_GROUP.)) = COUNTY %Then %Let GEOGRAPHY_FOOT  = %SYSFUNC(Compress((&GEO_H_LIST.), %Str(%')));
		%Else %Let GEOGRAPHY_FOOT = Geography: (None Selected);
	%End;

	%Let QUERY_FOOT = Query Parameters: AGE RACE GEOGRAPHY YEAR;


	/*@Action: Print footnote and query info to log ***/
	%PUT &QUERY_FOOT.;
	%PUT &AGE_FOOT.;
	%PUT &RACE_FOOT.;
	%PUT &GEOGRAPHY_FOOT.;
	%PUT &MASTER_LOGIC.;
	%PUT &YEAR_FOOT.;
	/**************************************************/

	/*@Action: Macro to check input values for all "N", for example exclusion of all ages 				   ***/
	/*@Note: The user MUST select at least one level for each SDOH, i.e. at least one "Y" in each category ***/
	%Macro Selection_Fail(Var, Var_List);
		%If (&Var.^=Geography and &Var.^=Year and %Index(&VAR_List., Y)=0) or (&Var.=Geography and &Var_List.=) or (&Var.=Year and (&H_Year.=)) %Then %Do;
			%Let Select_Fail=1;
			%Let Fail_List=&Fail_List. &Var.;
		%End;
	%Mend;

	%Let Fail_List=; %Let Select_Fail=0;

	%Selection_Fail(Var=Geography, Var_List=&GEO_H_LIST.);
	%Selection_Fail(Var=Age, 	   Var_List=&AGE_UNDER_6. &AGE_6_17. &AGE_BOTH.);
	%Selection_Fail(Var=Race, 	   Var_List=&RACE_WHITE. &RACE_BLACK. &RACE_ASIAN. &RACE_OTHER.);
	%Selection_Fail(Var=Year, 	   Var_List=&H_Year.);

	%If %Eval(&Select_Fail.=1) %Then %Do;
		%Let FailureCode=1;
		%Goto Exit;
	%End;


	/*@Action: Year ***/
	%If not(&H_Year. in (2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 
						 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 
					 	 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029))  %Then %Do;
		%Let FailureCode=2;
		%Goto Exit;
	 
	%End;
	

		%If %Eval(&Select_Fail.=1) %Then %Do;
		%Let FailureCode=1;
		%Goto Exit;
	%End;

	/*@Action: GEO_GROUP ***/
	%If &ALL_H_STATES.=N and (not(&GEO_H_GROUP. in (STATE COUNTY)))%Then %Do;
		%Let FailureCode=3;
		%Goto Exit;
	%End;

	/*Action: Bad GEO_H_LIST ***/
	%If &ALL_H_STATES.=N %Then %Do;
		%Let I=1; %Let Scan_Geo=%SCAN(&GEO_H_LIST., &I., %STR(,));
		%Do %While(&Scan_Geo. NE); 
			%If (&GEO_H_GROUP.=STATE and %Length(&Scan_Geo.)^=4) or (&GEO_H_GROUP.=COUNTY and %Length(&Scan_Geo.)^=7) %Then %Do;
				%Let FailureCode=4;
				%Goto Exit;
			%End;
			%Let I=%Eval(&I.+1); %Let Scan_Geo=%SCAN(&GEO_H_LIST., &I., %STR(,));
		%End;
	%End;


	/**************************************************/

	/*@Action: Query EHR File based on user selection citeria ***/
	%Global  ACS_POP_TOT USER_SAMP_TOT; 

	/*@Action: Apply user selection criteria to EHR data file ***/
		Data EHR0;
		set EHR0;
		STATE_FIPS=Substr(GEOGRAPHY,1,2);
		Race=&RACEVAR;
		run;


		Proc Sql NOPRINT;
			Create table User_Select as
				Select *
					From EHR0
						Where &MASTER_LOGIC. and WEIGHT_CATEGORY is not null and year=&H_YEAR.
							Order by HOUSEHOLD_ID, Year;
		Quit;
	
		Proc Freq data=User_Select;
		table household_childage_cat / list missing;
		table Race / list missing;
		table Geography / list missing;
		run;

		/*@Action: Execute sample size check ***/
		Proc Freq Data=User_Select noprint;
			Table household_childage_cat/list missing Out=Geo_age_cat (Drop=Percent Rename=(household_childage_cat=Values)); 
				Table Race/list missing Out=Geo_race (Drop=Percent Rename=(Race=Values)); 
		Run;

		Data Geo_freq;
			Length Factor Values $100.;
			Set Geo_age_cat (in=a) Geo_race (in=b) ;
			If a then Factor="Age Categories";
			Else if b then Factor="Race";
			If count<20 then Insufficient="Yes";
			Else Insufficient="No";
		Run;

		Proc Print data=Geo_freq (drop=Count);
		Run;

	Proc Sql NOPRINT;
		/*@Action: Check number of records in User_Select, if 0 then algorithm will fail ***/
		Select NOBS into :Queried_Records Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
	Quit;

	%If &Queried_Records.=0 %Then %Do;
		%Let FailureCode=5;
		%Goto Exit;
	%End;

	/*@Action: Suppression based on sample size	*/
			
		%macro EHR_Suppress_Race;
			%global Drop_Race;
			%Let FailureCode=None;

			/*@Action: Check Survey counts by race and remove race if necessary ***/
			Proc Freq Data=User_Select;
					Table Race / Out=Screen_Race_Counts Noprint;
			Run;


			Proc Sql noprint;
				/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
				Select NOBS into :Queried_Records Trimmed From Dictionary.Tables where Libname='WORK' and Memname='User_Select';
			Quit;

			%If &Queried_Records.=0 %Then %Do;
				%Let FailureCode=5;
				/*Exit and generate report here*/
				%Goto Exit;
			%End;

		/*@Action: Unduplicate individuals by selecting most recent record based on year ***/
		/*Proc sort data=User_Select; by PATID; run;*/

			/*@Action: Check Survey counts by race and remove race if necessary ***/
			Proc Freq Data=User_Select;
				Table Race / Out=Screen_Race_Counts Noprint;
			Run;

			Proc Sql noprint;
				%Let Drop_Race=;
				Select Distinct cats("'",Race,"'") into :Drop_Race Separated by ',' From Screen_Race_Counts Where Count<20;
				Select Distinct Race into :Present_In_EHR Separated by ' ' From User_Select;
				%If &Race_White.=Y and not(White in (&Present_In_EHR.)) and "&Drop_Race." ne "" %Then %Let Drop_Race=&Drop_Race., 'White';
					%Else %If &Race_White.=Y and not(White in (&Present_In_EHR.)) %Then %Let Drop_Race='White';
				%If &Race_Black.=Y and not(Black in (&Present_In_EHR.)) and "&Drop_Race." ne "" %Then %Let Drop_Race=&Drop_Race., 'Black';
					%Else %If &Race_Black.=Y and not(Black in (&Present_In_EHR.)) %Then %Let Drop_Race='Black';
				%If &Race_Asian.=Y and not(Asian in (&Present_In_EHR.)) and "&Drop_Race." ne "" %Then %Let Drop_Race=&Drop_Race., 'Asian';
					%Else %If &Race_Asian.=Y and not(Asian in (&Present_In_EHR.)) %Then %Let Drop_Race='Asian';
				%If &Race_Other.=Y and not(Other in (&Present_In_EHR.)) and "&Drop_Race." ne "" %Then %Let Drop_Race=&Drop_Race., 'Other';
					%Else %If &Race_Other.=Y and not(Other in (&Present_In_EHR.)) %Then %Let Drop_Race='Other';
			Quit;

			%If "&Drop_Race."^="" %Then %do;
				%let RaceSupress_Foot = (%Sysfunc(compress("&Drop_Race.",%STR(%'%"))));
					Data User_Select;
						Set User_Select;
							Where Race not in (&Drop_Race.);
					Run;
			%end;
			%Else %do;
				%Let Drop_Race='None';
				%Let RaceSupress_Foot = (None);
			%end;
			

			/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
			Proc Sql Noprint;
				Select NOBS into :Queried_Records_2 Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
			Quit;

			%If &Queried_Records_2.=0 %Then %Do;
				%Let FailureCode=5;
				/*Exit and generate report here*/
				%Goto Exit;
			%End;


			/*@Note: Special Footnote 2, Percentage of selected EHR records with imputed Race. ***/
			%If &IMP_RACES.=Y %Then %Do;
				Proc Freq Data=User_Select;
					Table Race_Imputed / Out=Freq_Impute_Race Missing List Noprint;
				Data _Null_;
					Set Freq_Impute_Race;
					Where Race_Imputed='Y';
						Call Symput("Perc_Imp_Race", Put(Percent, 5.2));
				Run;
			%End;

		%Exit:

		Data Exit;
		FailureCode="&FailureCode";
		RaceSupress_Foot="&RaceSupress_Foot";
		RaceImpute_Foot="&RaceImpute_Foot";
		run;
		

		%mend;

			
		%macro EHR_Suppress_Age;
			%global  Drop_Childage Drop_Childage2;
			%Let FailureCode=None;

			Data User_Select;
			set User_Select;
			Childage=tranwrd(trimn(household_childage_cat)," ","_");
			run;

			/*@Action: Check Survey counts by Childage and remove Childage if necessary ***/
			Proc Freq Data=User_Select;
					Table Childage / Out=Screen_Childage_Counts Noprint;
			Run;


			Proc Sql noprint;
				/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
				Select NOBS into :Queried_Records Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
			Quit;

			%If &Queried_Records.=0 %Then %Do;
				%Let FailureCode=5;
				%Goto Exit;
			%End;

		/*@Action: Unduplicate individuals by selecting most recent record based on year ***/
		/*Proc sort data=User_Select; by PATID; run;*/

			/*@Action: Check Survey counts by Childage and remove Childage if necessary ***/
			Proc Freq Data=User_Select;
				Table Childage / Out=Screen_Childage_Counts Noprint;
			Run;

			/***/ %LET AGE_UNDER_6 = N;	 /*@Note: Children’s Age Range: include households that have kids under the age of 6, but do not have kids 6 to 17 years of age (ACCEPTED VALUES: Y/N) 			 	   	   ***/
			/***/ %LET AGE_6_17 = Y;	 /*@Note: Children’s Age Range: include households that have kids over the age of 6, but do not have kids under the age of 6 (ACCEPTED VALUES: Y/N) ***/
			/***/ %LET AGE_BOTH = N;

			Proc Sql ;
				%Let Drop_Childage=;
				Select Distinct cats("'",Childage,"'") into :Drop_Childage Separated by ', ' From Screen_Childage_Counts Where Count<20;
				Select Distinct Childage into :Present_In_EHR Separated by ' ' From User_Select;
				%If &AGE_UNDER_6.=Y and not(Under_6_years_only in (&Present_In_EHR.)) and "&Drop_Childage." ne "" %Then %Let Drop_Childage=&Drop_Childage., 'Under_6_years_only';
					%Else %If &AGE_UNDER_6.=Y and not(Under_6_years_only in (&Present_In_EHR.)) %Then %Let Drop_Childage='Under_6_years_only';
				%If &AGE_6_17.=Y and not(6_to_17_years_only in (&Present_In_EHR.)) and "&Drop_Childage." ne "" %Then %Let Drop_Childage=&Drop_Childage., '6_to_17_years only';
					%Else %If &AGE_6_17.=Y and not(6_to_17_years_only in (&Present_In_EHR.)) %Then %Let Drop_Childage='6_to_17_years_only';
				%If &AGE_BOTH.=Y and not(Under_6_years_and_6_to_17_years in (&Present_In_EHR.)) and "&Drop_Childage." ne "" %Then %Let Drop_Childage=&Drop_Childage., 'Under_6_years_and_6_to_17_years';
					%Else %If &AGE_BOTH.=Y and not(Under_6_years_and_6_to_17_years in (&Present_In_EHR.)) %Then %Let Drop_Childage='Under_6_years_and_6_to_17_years';
			Quit;

			%Let Drop_Childage2=&Drop_Childage;
			%Let Drop_Childage=%sysfunc(tranwrd( %QUOTE(&Drop_Childage) ,_, ));

			%If "&Drop_Childage."^="" %Then %do;
				%let ChildageSupress_Foot = (%Sysfunc(compress("&Drop_Childage.",%STR(%'%"))));
					Data User_Select;
						Set User_Select;
							Where Childage not in (&Drop_Childage2.);
					Run;
			%end;	
			%Else %do;
				%Let Drop_Childage='None';
				%Let ChildageSupress_Foot = Childage Suppressed: (None);
			%end;
			/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
			Proc Sql Noprint;
				Select NOBS into :Queried_Records_2 Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
			Quit;

			%If &Queried_Records_2.=0 %Then %Do;
				%Let FailureCode=5;
				%Goto Exit;
			%End;
		 
		%Exit:
		
		Data Exit;
		FailureCode="&FailureCode";
		ChildageSupress_Foot="&ChildageSupress_Foot";
		run;


	%mend;

	%macro EHR_Suppress_HHAdults;
		%global Drop_HHAdults ;
		%Let FailureCode=None;


		Data User_Select;
		set User_Select;
		if nb_adults>1 then HHadults="two adults";
		else if nb_adults=1 then HHadults="one adult";
		run;

		/*@Action: Check Survey counts by HHAdults and remove HHAdults if necessary ***/
		Proc Freq Data=User_Select;
				Table HHadults/ Out=Screen_HHAdults_Counts Noprint;
		Run;


		Proc Sql noprint;
			/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
			Select NOBS into :Queried_Records Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
		Quit;

		%If &Queried_Records.=0 %Then %Do;
			%Let FailureCode=5;
			%Goto Exit;
		%End;

		/*@Action: Unduplicate individuals by selecting most recent record based on year ***/
		/*Proc sort data=User_Select; by PATID; run;*/

			/*@Action: Check Survey counts by HHAdults and remove HHAdults if necessary ***/
			Proc Freq Data=User_Select;
				Table HHAdults / Out=Screen_HHAdults_Counts Noprint;
			Run;

			Proc Sql ;
				%Let Drop_HHAdults=;
				Select Distinct cats("'",HHAdults,"'") into :Drop_HHAdults Separated by ', ' From Screen_HHAdults_Counts Where Count<20;
				Select Distinct HHAdults into :Present_In_EHR Separated by ' ' From User_Select;
			Quit;

			%Let Drop_HHAdults=%sysfunc(tranwrd( %QUOTE(&Drop_HHAdults) ,_, ));

			%If "&Drop_HHAdults."^="" %Then %do;
				%let HHAdultsSupress_Foot = (%Sysfunc(compress("&Drop_HHAdults.",%STR(%'%"))));
					Data User_Select;
						Set User_Select;
							Where HHAdults not in (&Drop_HHAdults.);
					Run;
			%end;	
			%Else %do;
				%Let Drop_HHAdults='None';
				%Let HHAdultsSupress_Foot = (None);
			%end;
			/*@Action: Check number of records in EHR, if 0 then algorithm will fail ***/
			Proc Sql Noprint;
				Select NOBS into :Queried_Records_2 Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
			Quit;

			%If &Queried_Records_2.=0 %Then %Do;
				%Let FailureCode=5;
				%Goto Exit;
			%End;
		 
		%Exit:
			
		Data Exit;
		FailureCode="&FailureCode";
		HHAdultsSupress_Foot="&HHAdultsSupress_Foot";
		run;
	%mend;

%EHR_Suppress_Race;
%EHR_Suppress_Age;
%EHR_Suppress_HHAdults;

Data USER_SELECT;
set USER_SELECT;
	%If &IMP_RACES.=N %Then %Do;
		if RACE_IMPUTED="N";
	%End;
run;

Proc Sql NOPRINT;
		/*@Action: Check number of records in User_Select, if 0 then algorithm will fail ***/
		Select NOBS into :Queried_Records Trimmed From Dictionary.Tables where Libname='WORK' and Memname='USER_SELECT';
	Quit;

	%If &Queried_Records.=0 %Then %Do;
		%Let FailureCode=5;
		%Goto Exit;
	%End;


%Exit:
		Data Exit_all;
		/*Exit and generate report here*/
		FailureCode="&FailureCode";
		run;

%If &IMP_RACES.=Y %Then %Do;
	 %Let RaceImpute_Foot=&Perc_Imp_Race.% of race values were imputed. Please be advised, prevalence estimates may incur additional bias with imputed race values. Extreme caution is recommended when the proportion of imputed race values exceeds 40%.;
%End;
%Else %Do;
	%Let RaceImpute_Foot=People with unknown race were excluded.;
%End;

%mend;
 
%HPQ;
	/*@Action: Print footnote and query info to log ***/
	%PUT &QUERY_FOOT.;
	%PUT &AGE_FOOT. &AGE_Query.;
	%PUT &RACE_FOOT. &RACE_QUERY.;
	%PUT &GEOGRAPHY_FOOT. &GEO_H_LIST. ;
	%PUT &YEAR_FOOT. &H_YEAR;
	%PUT &MASTER_LOGIC.;
	%PUT &RACEVAR;
	%PUT &HHAdultsSupress_Foot;
	%PUT &ChildageSupress_Foot;
	%PUT &RaceSupress_Foot;
	%PUT &RaceImpute_Foot &Perc_Imp_Race;
	%PUT &FailureCode;
	%PUT &Geo_Level;

	/*@Action: Census Control totals computation ***/
	/*@Note: This macro is stored in the SAS program named Macro1-CODI_PC_GEO3 ***/



/*subset based on imputation here*/ 