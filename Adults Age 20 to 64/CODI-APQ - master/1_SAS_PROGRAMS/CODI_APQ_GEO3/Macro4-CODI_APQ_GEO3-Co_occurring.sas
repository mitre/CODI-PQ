/*******************************************************************************************/
/***PROGRAM: Macro4-CODI_APQ_GEO3.SAS									 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: SCOTT CAMPBELL																		    				 ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)		 			    ***/
/*******************************************************************************************/
/*@Action: Macro to compute prevalence estimates ***/
%Macro Generate_Prev_Report_CoOccur(Infile1, Infile2, Infile3, Infile4, Infile5, Infile6, Infile7, Infile8, Infile9, Infile10, Pass, FailCode);
	/*@Action: Load Age Adjust Information (If requested) ***/
		%If &AGE_ADJ.=Y %then %do;
			%Let Incld_Age_Adj_P1=, Put(pop_perc_age_adj, 5.2) as AgeAdj_Prev Label="Age-Adjusted Prevalence", Put(std_err_age_adj, 5.2) as AgeAdj_StdErr Label="Age-Adjusted Prevalence Standard Error";
			%Let Incld_Age_Adj_P2=, AgeAdj_Prev, AgeAdj_StdErr;
			%Let Incld_Age_Adj_P3=, Put(Pop_n_age_adj, Comma20.) as Pop_age_adj Label  = "Population (Age Adjusted)";
			%Let Incld_Age_Adj_P4=, Pop_age_adj;
			%let Incld_Age_Adj_P5=, Put(&ACS_POP_TOT., Comma20.) as Pop_age_adj;
			%Let Age_Adj_Footnote=AGE adjusted: (Yes);
			%Let Age_Adj_Caveat1=Union Select 23 as Order, "The age-adjusted prevalence calculations are documented in the Implementation Guide." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report;
			%Let Age_Adj_Caveat2=Union Select 25 as Order, "The age-adjusted prevalence calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond;
			%Let Age_Adj_Caveat3=Union Select 24 as Order, "The age-adjusted prevalence calculations are documented in the Implementation Guide." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt;

			%Let Incld_Age_Adj_F1=, AgeAdj_Prev, AgeAdj_StdErr;
			%Let Incld_Age_Adj_F2=, AgeAdj_Prev, AgeAdj_StdErr;
			%Let Incld_Age_Adj_F3=, Pop_age_adj;
			%Let Incld_Age_Adj_F4=, Pop_age_adj;
		%End;
		%Else %Do;
			%Let Age_Adj_Footnote=AGE adjusted: (No);
			%Let Age_Adj_Caveat1=;
			%Let Age_Adj_Caveat2=;
			%Let Age_Adj_Caveat3=;
			%Let Incld_Age_Adj_P1=;
			%Let Incld_Age_Adj_P2=;
			%Let Incld_Age_Adj_P3=;
			%Let Incld_Age_Adj_P4=;
			%Let Incld_Age_Adj_P5=;

			%Let Incld_Age_Adj_F1=;
			%Let Incld_Age_Adj_F2=;
			%Let Incld_Age_Adj_F3=;
			%Let Incld_Age_Adj_F4=;
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
			Length Condition WtCat $300. Samp Pop Crde_Prev Crde_StdErr Wgt_Prev Wgt_StdErr AgeAdj_Prev AgeAdj_StdErr $5.;
			Label Condition="Condition"
				  WtCat="Weight Category"
				  Samp="Sample"
				  Pop="Population"
				  Pop_age_adj="Population (Age Adjusted)"
				  Crde_Prev="Crude Prevalence"
				  Crde_StdErr="Crude Prevalence Standard Error"
				  Wgt_Prev="Weighted Prevalence"
				  Wgt_StdErr="Weighted Prevalence Standard Error"
				  AgeAdj_Prev="Age-Adjusted Prevalence"
				  AgeAdj_StdErr="Age-Adjusted Prevalence Standard Error";
				  
			Condition="";
			WtCat="";
			Samp="";
			Pop="";
			Pop_age_adj="";
			Crde_Prev="";
			Crde_StdErr="";
			Wgt_Prev="";
			Wgt_StdErr="";
			AgeAdj_Prev="";
			AgeAdj_StdErr="";
		Run;

		Data Null_Prev_Report_cond;
			Length Condition $300. Samp Pop Crde_Prev Crde_StdErr Wgt_Prev Wgt_StdErr AgeAdj_Prev AgeAdj_StdErr $5.;
			Label Condition="Condition"
				  Samp="Sample"
				  Pop="Population"
				  Pop_age_adj="Population (Age Adjusted)"
				  Crde_Prev="Crude Prevalence"
				  Crde_StdErr="Crude Prevalence Standard Error"
				  Wgt_Prev="Weighted Prevalence"
				  Wgt_StdErr="Weighted Prevalence Standard Error"
				  AgeAdj_Prev="Age-Adjusted Prevalence"
				  AgeAdj_StdErr="Age-Adjusted Prevalence Standard Error";
				  
			Condition="";
			Samp="";
			Pop="";
			Pop_age_adj="";
			Crde_Prev="";
			Crde_StdErr="";
			Wgt_Prev="";
			Wgt_StdErr="";
			AgeAdj_Prev="";
			AgeAdj_StdErr="";
		Run;

		Data Null_Prev_Report_wgt;
			Length WtCat $300. Samp Pop Crde_Prev Crde_StdErr Wgt_Prev Wgt_StdErr AgeAdj_Prev AgeAdj_StdErr $5.;
			Label WtCat="Weight Category"
				  Samp="Sample"
				  Pop="Population"
				  Pop_age_adj="Population (Age Adjusted)"
				  Crde_Prev="Crude Prevalence"
				  Crde_StdErr="Crude Prevalence Standard Error"
				  Wgt_Prev="Weighted Prevalence"
				  Wgt_StdErr="Weighted Prevalence Standard Error"
				  AgeAdj_Prev="Age-Adjusted Prevalence"
				  AgeAdj_StdErr="Age-Adjusted Prevalence Standard Error";
				  
			WtCat="";
			Samp="";
			Pop="";
			Pop_age_adj="";
			Crde_Prev="";
			Crde_StdErr="";
			Wgt_Prev="";
			Wgt_StdErr="";
			AgeAdj_Prev="";
			AgeAdj_StdErr="";
		Run;

	/*@Action: If algorithm has passed up to this point, begin report generation ***/
	%If &Pass. = Y %Then %Do;
		/*@Action: Load total ACS and USER counts by weight category into macro variables for report output ***/
		Proc sql Noprint;
			Select Sum(Pop_n) Into :ACS_POP_TOT_uw Trimmed From &Infile3. where wtcat="(1) Underweight (BMI<18.5)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_hw Trimmed From &Infile3. where wtcat="(2) Healthy Weight (18.5<=BMI<25)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_ow Trimmed From &Infile3. where wtcat="(3) Overweight (25<=BMI<30)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_ob123 Trimmed From &Infile3. where wtcat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_ob1 Trimmed From &Infile3. where wtcat="(4a) Obesity (Class 1) (30<=BMI<35)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_ob2 Trimmed From &Infile3. where wtcat="(4b) Obesity (Class 2) (35<=BMI<40)";
			Select Sum(Pop_n) Into :ACS_POP_TOT_ob3 Trimmed From &Infile3. where wtcat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_uw Trimmed From &Infile3. where wtcat="(1) Underweight (BMI<18.5)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_hw Trimmed From &Infile3. where wtcat="(2) Healthy Weight (18.5<=BMI<25)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_ow Trimmed From &Infile3. where wtcat="(3) Overweight (25<=BMI<30)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_ob123 Trimmed From &Infile3. where wtcat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_ob1 Trimmed From &Infile3. where wtcat="(4a) Obesity (Class 1) (30<=BMI<35)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_ob2 Trimmed From &Infile3. where wtcat="(4b) Obesity (Class 2) (35<=BMI<40)";
			Select Sum(Sample_PT) Into :USER_SAMP_TOT_ob3 Trimmed From &Infile3. where wtcat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_uw Trimmed From &Infile3. where wtcat="(1) Underweight (BMI<18.5)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_hw Trimmed From &Infile3. where wtcat="(2) Healthy Weight (18.5<=BMI<25)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_ow Trimmed From &Infile3. where wtcat="(3) Overweight (25<=BMI<30)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_ob123 Trimmed From &Infile3. where wtcat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_ob1 Trimmed From &Infile3. where wtcat="(4a) Obesity (Class 1) (30<=BMI<35)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_ob2 Trimmed From &Infile3. where wtcat="(4b) Obesity (Class 2) (35<=BMI<40)";
			Select Sum(Pop_n_age_adj) Into :AGE_ADJ_POP_TOT_ob3 Trimmed From &Infile3. where wtcat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
		Quit;

		/*@Action: Load Age Adjust Information (If requested) ***/
			%If &AGE_ADJ.=Y %then %do;
				%let Incld_Age_Adj_uw=, Put(&AGE_ADJ_POP_TOT_uw., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_hw=, Put(&AGE_ADJ_POP_TOT_hw., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_ow=, Put(&AGE_ADJ_POP_TOT_ow., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_ob123=, Put(&AGE_ADJ_POP_TOT_ob123., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_ob1=, Put(&AGE_ADJ_POP_TOT_ob1., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_ob2=, Put(&AGE_ADJ_POP_TOT_ob2., Comma20.) as Pop_age_adj;
				%let Incld_Age_Adj_ob3=, Put(&AGE_ADJ_POP_TOT_ob3., Comma20.) as Pop_age_adj;
			%End;
			%Else %Do;
				%Let Incld_Age_Adj_uw=;
				%Let Incld_Age_Adj_hw=;
				%Let Incld_Age_Adj_ow=;
				%Let Incld_Age_Adj_ob123=;
				%Let Incld_Age_Adj_ob1=;
				%Let Incld_Age_Adj_ob2=;
				%Let Incld_Age_Adj_ob3=;
			%End;

		Proc Sql;
			Create table Prevalence_Report_Counts as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					WtCat Label = "Weight Category" Length=300,
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.
						From &Infile1.
							Group By co_occurring_label, WtCat
								Union
				Select 2 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 3 as Order, "&Query_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 4 as Order, "&Age_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 5 as Order, "&Sex_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 6 as Order, "&Pregnancy_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 7 as Order, "&Race_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 8 as Order, "&RaceSupress_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 9 as Order, "&RaceImpute_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 10 as Order, "&Geography_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 11 as Order, "&Year_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 12 as Order, "&Collapse_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 13 as Order, "&Age_Adj_Footnote." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 14 as Order, "Error Codes: (&Suppress_Error.)" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 15 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 16 as Order, "Query Date: &DateTime2." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 17 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 17 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 18 as Order, "Caveats" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 19 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 20 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union
				Select 21 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report Union 
				Select 22 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, WtCat, Samp, Pop &Incld_Age_Adj_P4. From Null_Prev_Report
				&Age_Adj_Caveat1.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Weight as
				Select 1 as Order, WtCat Label = "WtCat",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile3.
							Group By WtCat
								Union
				Select 2 as Order, "Totals:" as WtCat, Put(&USER_SAMP_TOT., Comma20.) as Samp, Put(&ACS_POP_TOT., Comma20.) as Pop &Incld_Age_Adj_P5., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 4 as Order, "&Query_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 5 as Order, "&Age_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 6 as Order, "&Sex_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 7 as Order, "&Pregnancy_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 8 as Order, "&Race_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 9 as Order, "&RaceSupress_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 10 as Order, "&RaceImpute_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 11 as Order, "&Geography_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 12 as Order, "&Year_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 13 as Order, "&Collapse_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 14 as Order, "&Age_Adj_Footnote." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 15 as Order, "Error Codes: (&Suppress_Error_wgt.)" as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 17 as Order, "Query Date: &DateTime2." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 19 as Order, "Caveats" as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 22 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 23 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as WtCat, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt
				&Age_Adj_Caveat3.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Condition as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile2.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT., Comma20.) as Samp, Put(&ACS_POP_TOT., Comma20.) as Pop &Incld_Age_Adj_P5., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "Error Codes: (&Suppress_Error_occur_all.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat3.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Underweight as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile4.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_uw., Comma20.) as Samp, Put(&ACS_POP_TOT_uw., Comma20.) as Pop &Incld_Age_Adj_uw., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (1) Underweight (BMI<18.5)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_UW.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Healthy as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile5.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_hw., Comma20.) as Samp, Put(&ACS_POP_TOT_hw., Comma20.) as Pop &Incld_Age_Adj_hw., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (2) Healthy Weight (18.5<=BMI<25)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_HW.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" 																																																			   as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." 																										   as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Over as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile6.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_ow., Comma20.) as Samp, Put(&ACS_POP_TOT_ow., Comma20.) as Pop &Incld_Age_Adj_ow., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (3) Overweight (25<=BMI<30)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_OW.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2.  From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese123 as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile7.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_ob123., Comma20.) as Samp, Put(&ACS_POP_TOT_ob123., Comma20.) as Pop &Incld_Age_Adj_ob123., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_OB123.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese1 as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile8.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_ob1., Comma20.) as Samp, Put(&ACS_POP_TOT_ob1., Comma20.) as Pop &Incld_Age_Adj_ob1., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4a) Obesity (Class 1) (30<=BMI<35)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_OB1.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese2 as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile9.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_ob2., Comma20.) as Samp, Put(&ACS_POP_TOT_ob2., Comma20.) as Pop &Incld_Age_Adj_ob2., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4b) Obesity (Class 2) (35<=BMI<40)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union	
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_OB2.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese3 as
				Select 1 as Order, co_occurring_label as Condition Label = "Condition",
					Put(Sample_PT, Comma20.) as Samp Label = "Sample",
					Put(Pop_n, Comma20.) as Pop Label  = "Population"
					&Incld_Age_Adj_P3.,
					Put(Crude_Prev, 5.2) as Crde_Prev Label = "Crude Prevalence",
					Put(Crude_StdErr, 5.2) as Crde_StdErr Label = "Crude Prevalence Standard Error",
					Put(Pop_Perc, 5.2) as Wgt_Prev Label = "Weighted Prevalence",
					Put(STD_Err, 5.2) as Wgt_StdErr Label = "Weighted Prevalence Standard Error"
					&Incld_Age_Adj_P1.
						From &Infile10.
							Group By co_occurring_label
								Union
				Select 2 as Order, "Totals:" as Condition, Put(&USER_SAMP_TOT_ob3., Comma20.) as Samp, Put(&ACS_POP_TOT_ob3., Comma20.) as Pop &Incld_Age_Adj_ob3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Condition, Samp, Pop, Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F4. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Suppress_Error_occur_OB3.)" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_P4., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;
	%End;

	%Else %Do;
		%If 		  &Failcode.=1 %Then %Let Fail_Desc=One or more demographic or geographic category has no groups selected. One or more group must be selected in each category. Ensure that each demographic and geographic category has one or more groups selected (e.g., age group, select an age range for inclusion).;
			%Else %If &Failcode.=2 %Then %Let Fail_Desc=Years are out of scope. CODI-PQ was built between 2019 and 2021, see Implementation Guide for More details.;
			%Else %If &Failcode.=3 %Then %Let Fail_Desc=Geographic level (GEO_GROUP) has been left blank or has been set to an unacceptable value. To remedy the issue, update the GEO_GROUP variable to either STATE, ZCTA-3, or county.;
			%Else %If &Failcode.=4 %Then %Let Fail_Desc=State and/or GEO3 is incorrectly specified. Review the lists and ensure each value is: Surrounded by quotations, Comma delimited, and/or The correct length (e.g., "08001", "08002", "08003", etc.).;
			%Else %If &Failcode.=5 %Then %Let Fail_Desc=Current selections return an insufficient number of patients and do not meet the minimum threshold to calculate sample weights. Ensure that selections are correct (e.g., correct list of state codes or GEO3 values) or include additional geographic or demographic categories (e.g., add additional communities or include additional or all races, age groups, sex, etc.).;
			%Else %If &Failcode.=6 %Then %Let Fail_Desc=Iterative proportional fitting weighting routine has failed to converge. Please revise selections and rerun algorithm.;
			%Else 						 %Let Fail_Desc=A SAS error has occurred within the algorithm. Review the SAS log or contact a system administrator for further assistance.;

		%Let RaceSupress_Foot=RACE Suppressed: (Error);
		%If &IMP_RACES.=Y %Then %Let RaceImpute_Foot=RACE Imputed: (Error) of race values were imputed. Please be advised, prevalence may incur additional bias with imputed race values. Extreme caution is encouraged when the proportion of imputed race values exceeds 40%.;
			%Else %Let RaceImpute_Foot=Imputed race: People with unknown race were excluded.;
		%Let Collapse_Foot=Weighting cells were collapsed for: (Error);

		Proc Sql;
			Create table Prevalence_Report_Counts as
				Select 1 as Order, "(1) No Evidence" as Condition, "(1) Underweight (BMI<18.5)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(2) Healthy Weight (18.5<=BMI<25)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(3) Overweight (25<=BMI<30)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(4a) Obesity (Class 1) (30<=BMI<35)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(4b) Obesity (Class 2) (35<=BMI<40)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(1) No Evidence" as Condition, "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(1) Underweight (BMI<18.5)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(2) Healthy Weight (18.5<=BMI<25)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(3) Overweight (25<=BMI<30)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(4a) Obesity (Class 1) (30<=BMI<35)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(4b) Obesity (Class 2) (35<=BMI<40)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(2) Prediabetes" as Condition, "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(1) Underweight (BMI<18.5)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(2) Healthy Weight (18.5<=BMI<25)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(3) Overweight (25<=BMI<30)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(4a) Obesity (Class 1) (30<=BMI<35)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(4b) Obesity (Class 2) (35<=BMI<40)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 1 as Order, "(3) Diabetes" as Condition, "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 2 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 3 as Order, "&Query_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 4 as Order, "&Age_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 5 as Order, "&Sex_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 6 as Order, "&Pregnancy_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 7 as Order, "&Race_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 8 as Order, "&RaceSupress_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 9 as Order, "&RaceImpute_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 10 as Order, "&Geography_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 11 as Order, "&Year_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 12 as Order, "&Collapse_Foot." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 13 as Order, "&Age_Adj_Footnote." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 14 as Order, "Error Codes: (&Fail_Desc.)" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 15 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 16 as Order, "Query Date: &DateTime2." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 17 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 17 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 18 as Order, "Caveats" as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 19 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 20 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 21 as Order, "The population is calculated from age-race-sex-geography specific counts from the user provided American Community Survey Five-year Estimates." as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report Union
				Select 22 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, WtCat, Samp, Pop &Incld_Age_Adj_F3. From Null_Prev_Report
				&Age_Adj_Caveat1.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Weight as
				Select 1 as Order, "(1) Underweight (BMI<18.5)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(2) Healthy Weight (18.5<=BMI<25)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(3) Overweight (25<=BMI<30)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(4a) Obesity (Class 1) (30<=BMI<35)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(4b) Obesity (Class 2) (35<=BMI<40)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 1 as Order, "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 2 as Order, "Totals:" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 4 as Order, "&Query_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_wgt Union
				Select 5 as Order, "&Age_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 6 as Order, "&Sex_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 7 as Order, "&Pregnancy_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 8 as Order, "&Race_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 9 as Order, "&RaceSupress_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 10 as Order, "&RaceImpute_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 11 as Order, "&Geography_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 12 as Order, "&Year_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 13 as Order, "&Collapse_Foot." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 14 as Order, "&Age_Adj_Footnote." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 15 as Order, "Error Codes: (&Fail_Desc.)" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 17 as Order, "Query Date: &DateTime2." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 19 as Order, "Caveats" as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 22 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt Union
				Select 23 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as WtCat, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_wgt
				&Age_Adj_Caveat3.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Condition as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 18 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat3.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Underweight as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (1) Underweight (BMI<18.5)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Healthy as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (2) Healthy Weight (18.5<=BMI<25)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Over as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (3) Overweight (25<=BMI<30)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese123 as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese1 as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4a) Obesity (Class 1) (30<=BMI<35)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese2 as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4b) Obesity (Class 2) (35<=BMI<40)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 a Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

		Proc Sql;
			Create table Prevalence_Report_Obese3 as
				Select 1 as Order, "(1) No Evidence" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(2) Prediabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 1 as Order, "(3) Diabetes" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 2 as Order, "Totals:" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 3 as Order, "Query Version: CODI-APQ GEO3 2015-2019" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 4 as Order, "Weight Category: (4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 5 as Order, "&Query_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_F2. From Null_Prev_Report_cond Union
				Select 6 as Order, "&Age_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 7 as Order, "&Sex_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 8 as Order, "&Pregnancy_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 9 as Order, "&Race_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 10 as Order, "&RaceSupress_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 11 as Order, "&RaceImpute_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 12 as Order, "&Geography_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 13 as Order, "&Year_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 14 as Order, "&Collapse_Foot." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 15 as Order, "&Age_Adj_Footnote." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 16 as Order, "Error Codes: (&Fail_Desc.)" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 17 as Order, "Implementation Guide: See https://github.com/NORC-UChicago/CODI-PQ for more information and full details on data sources and calculations." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 18 as Order, "Query Date: &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 19 as Order, "Suggested Citation: Tanenbaum, E., Campbell, S., Chelluri, D., Zalsha, S., Boim, J., Paddock, S., Copeland, K. (2021). Clinical and Community Data Initiative Prevalence Query (CODI-PQ) SAS programs (version 2015-2019)." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report Union
				Select 19 as Order, "The Centers for Medicare & Medicaid Services Alliance to Modernize Healthcare federally funded research and development center, Health FFRDC. Retrieved from https://github.com/NORC-UChicago/CODI-PQ on &DateTime2." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 20 as Order, "Caveats" as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 21 as Order, "Patients with either missing or invalid age, sex, height, weight, or geography are not included in results." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 22 as Order, "The standard error calculations are documented in the Implementation Guide." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 23 as Order, "The population estimates are based on age-race-sex-location specific counts from the 2015-2019 American Community Survey Five-year Estimates released by the Census Bureau on December9, 2020." as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond Union
				Select 24 as Order, "CODI PQ was developed between 2019 and 2021 and tested with EHR from 2015 through 2019. Please review the Implementation Guide in full to determine whether CODI-PQ methodology is appropriate for your use case when used outside of these date ranges."  as Condition, Samp, Pop &Incld_Age_Adj_F3., Crde_Prev, Crde_StdErr, Wgt_Prev, Wgt_StdErr &Incld_Age_Adj_P2. From Null_Prev_Report_cond
				&Age_Adj_Caveat2.;
		Quit;

	%End;

	data Prevalence_Report_Weight;
		set Prevalence_Report_Weight;
		if WtCat="" then delete;
	run;

	/*@Action: Create CSV output file for prevalence results ***/
	Proc Export Data=Prevalence_Report_Counts Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Counts";
	run;
	Proc Export Data=Prevalence_Report_Weight Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Weight Category";
	run;
	Proc Export Data=Prevalence_Report_Condition Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Spectrum";
	run;
	Proc Export Data=Prevalence_Report_Underweight Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Underweight";
	run;
	Proc Export Data=Prevalence_Report_Healthy Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Healthy Weight";
	run;
	Proc Export Data=Prevalence_Report_Over Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Overweight";
	run;
	Proc Export Data=Prevalence_Report_Obese123 Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Obese Class 1,2,3";
	run;
	Proc Export Data=Prevalence_Report_Obese1 Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Obese Class 1";
	run;
	Proc Export Data=Prevalence_Report_Obese2 Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Obese Class 2";
	run;
	Proc Export Data=Prevalence_Report_Obese3 Outfile="&Root_PQ.\2_Output\&FileOUT_Name._&DateTime..xlsx" DBMS = xlsx Replace Label;
        Sheet="Diabetes Obese Class 3";
	run;

%Mend;
