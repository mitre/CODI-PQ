/*******************************************************************************************/
/***PROGRAM: Macro4-CODI_APQ_GEO3.SAS									 				 ***/
/***VERSION: 1.0																		 	 		***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)				***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)		   ***/
/*******************************************************************************************/
/*@Action: Macro to compute prevalence estimates ***/
%Macro Generate_Prev_Report(Infile, Pass, FailCode);
	/*@Action: Load Age Adjust Information (If requested) ***/
		%If &AGE_ADJ.=Y %then %do;
			%Let Incld_Age_Adj_P1=, Put(pop_perc_age_adj, 5.2) as AgeAdj_Prev Label="Age-Adjusted Prevalence", Put(std_err_age_adj, 5.2) as AgeAdj_StdErr Label="Age-Adjusted Prevalence Standard Error";
			%Let Incld_Age_Adj_P2=, AgeAdj_Prev, AgeAdj_StdErr;
			%Let Age_Adj_Footnote=AGE adjusted: (Yes);
			%Let Age_Adj_Caveat=Union Select 24 as Order, "The age-adjusted prevalence calculations are documented in the Implementation Guide." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report;

			%Let Incld_Age_Adj_F1=, AgeAdj_Prev, AgeAdj_StdErr;
			%Let Incld_Age_Adj_F2=, AgeAdj_Prev, AgeAdj_StdErr;
		%End;
		%Else %Do;
			%Let Age_Adj_Footnote=AGE adjusted: (No);
			%Let Age_Adj_Caveat=;
			%Let Incld_Age_Adj_P1=;
			%Let Incld_Age_Adj_P2=;

			%Let Incld_Age_Adj_F1=;
			%Let Incld_Age_Adj_F2=;
		%End;

	/*@Action: create Pregnanacy inclusion footnote***/
		%If &INCLUDE_PREGNANCY.=Y %then %do;
			%Let Pregnancy_Foot=Pregnancy: included in analysis;
		%End;
		%Else %do;
			%Let Pregnancy_Foot=Pregnancy: excluded from analysis;
		%End;

	/*@Action: Load Dummy table for footnote generation ***/
		Data Null_Prev_Report;
			Length WtCat $300. Samp Pop Crde_Prev Crde_StdErr Wgt_Prev Wgt_StdErr AgeAdj_Prev AgeAdj_StdErr $5.;
			Label WtCat="Weight Category"
				  Samp="Sample"
				  Pop="Population"
				  Crde_Prev="Crude Prevalence"
				  Crde_StdErr="Crude Prevalence Standard Error"
				  Wgt_Prev="Weighted Prevalence"
				  Wgt_StdErr="Weighted Prevalence Standard Error"
				  AgeAdj_Prev="Age-Adjusted Prevalence"
				  AgeAdj_StdErr="Age-Adjusted Prevalence Standard Error";
				  
			WtCat="";
			Samp="";
			Pop="";
			Crde_Prev="";
			Crde_StdErr="";
			Wgt_Prev="";
			Wgt_StdErr="";
			AgeAdj_Prev="";
			AgeAdj_StdErr="";
		Run;

	/*@Action: If algorithm has passed up to this point, begin report generation ***/
	%If &Pass. = Y %Then %Do;
		Proc Sql;
			Create table Prevalence_Report as
				Select 1 as Order, WtCat Label = "Weight Category" Length=300,
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population",
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile.
							Group By WtCat
								Union
				Select 2 as Order, "Totals:" as WtCat, Put(&USER_SAMP_TOT., Comma20.) as Samp, Put(&ACS_POP_TOT., Comma20.) as Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 3 as Order, "Version: CODI-APQ GEO3 2015-2019" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 4 as Order, "&Query_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 5 as Order, "&Age_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 6 as Order, "&Sex_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 7 as Order, "&Pregnancy_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 8 as Order, "&Race_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 9 as Order, "&RaceSupress_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 10 as Order, "&RaceImpute_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 11 as Order, "&Geography_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 12 as Order, "&Year_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 13 as Order, "&Collapse_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 14 as Order, "&Age_Adj_Footnote." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 15 as Order, "Error Codes: (&Suppress_Error.)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 17 as Order, "Query Date: &DateTime2." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2.." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "Caveats" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 22 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates."  as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report
				&Age_Adj_Caveat.;
		Quit;
	%End;

	%Else %Do;
		%If 		  &Failcode.=1 %Then %Let Fail_Desc=One or more demographic or geographic category has no groups selected. One or more group must be selected in each category. Ensure that each demographic and geographic category has one or more groups selected (e.g., age group, select an age range for inclusion).;
			%Else %If &Failcode.=2 %Then %Let Fail_Desc=Years are out of scope. CODI-APQ was built between 2019 and 2021, see Implementation Guide for More details.;
			%Else %If &Failcode.=3 %Then %Let Fail_Desc=Geographic level (GEO_GROUP) has been left blank or has been set to an unacceptable value. To remedy the issue, update the GEO_GROUP variable to either STATE, ZCTA-3, or county.;
			%Else %If &Failcode.=4 %Then %Let Fail_Desc=State and/or GEO3 is incorrectly specified. Review the lists and ensure each value is: Surrounded by quotations, Comma delimited, and/or The correct length (e.g., "08001", "08002", "08003", etc.).;
			%Else %If &Failcode.=5 %Then %Let Fail_Desc=Current selections return an insufficient number of patients and do not meet the minimum threshold to calculate sample weights. Ensure that selections are correct (e.g., correct list of state codes or GEO3 values) or include additional geographic or demographic categories (e.g., add additional communities or include additional or all races, age groups, sex, etc.).;
			%Else %If &Failcode.=6 %Then %Let Fail_Desc=Iterative proportional fitting weighting routine has failed to converge. Please revise selections and rerun algorithm.;
			%Else 						 %Let Fail_Desc=A SAS error has occurred within the algorithm. Review the SAS log or contact a system administrator for further assistance.;

		%Let RaceSupress_Foot=RACE Suppressed: (Error);
		%If &IMP_RACES.=Y %Then %Let RaceImpute_Foot=RACE Imputed: (Error) of race values were imputed. Please be advised, prevalence may incur additional bias with imputed race values. Extreme caution is encouraged when the proportion of imputed race values exceeds 40%.;
			%Else %Let RaceImpute_Foot=Imputed race: People with unknown race were excluded.;
		%Let Collapse_Foot=Weighting cells were consolidated for: (Error);
 
		Proc Sql;
			Create table Prevalence_Report as
				Select 1 as Order, "(1) Underweight (BMI<18.5)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F1. From Null_Prev_Report Union
				Select 1 as Order, "(2) Healthy Weight (18.5<=BMI<25)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 1 as Order, "(3) Overweight (25<=BMI<30)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 1 as Order, "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 1 as Order, "(4a) Obesity (Class 1) (30<=BMI<35)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 1 as Order, "(4b) Obesity (Class 2) (35<=BMI<40)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 1 as Order, "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 2 as Order, "Totals:" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 3 as Order, "Version: CODI-APQ GEO3 2015-2019" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 4 as Order, "&Query_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report Union
				Select 5 as Order, "&Age_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 6 as Order, "&Sex_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 7 as Order, "&Pregnancy_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 8 as Order, "&Race_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 9 as Order, "&RaceSupress_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 10 as Order, "&RaceImpute_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 11 as Order, "&Geography_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 12 as Order, "&Year_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 13 as Order, "&Collapse_Foot." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 14 as Order, "&Age_Adj_Footnote." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 15 as Order, "Error Codes: (&Fail_Desc.)" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 17 as Order, "Query Date: &DateTime2." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2.." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "Caveats" as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 22 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as WtCat, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report 
				&Age_Adj_Caveat.;
		Quit;
	%End;

	data Prevalence_report;
		set Prevalence_report;
		if WtCat="" then delete;
	run;

	/*@Action: Create CSV output file for prevalence results ***/
	Proc Export Data=Prevalence_report Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..csv" label DBMS=CSV Replace;
		Run;
%Mend;
