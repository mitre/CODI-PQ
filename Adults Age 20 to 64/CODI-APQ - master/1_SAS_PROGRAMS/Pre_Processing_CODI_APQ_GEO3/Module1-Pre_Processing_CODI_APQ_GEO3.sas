/*******************************************************************************************/
/***PROGRAM: Module1-Pre-Processing_CODI_APQ_ZCTA3.SAS					 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)							 ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)					    ***/
/*******************************************************************************************/
/*@Action: CDC Condition Distribution ***/
Data CDC_Condition_Dist;
	Informat Condition $19. Abbreviation $6.;
	Infile datalines DSD;
	Input Condition $ Abbreviation $ Race $ Cumulative;
	Datalines;
Sickle Cell Disease,SCD,Asian,0.00576987215196052
Sickle Cell Disease,SCD,Black,0.927302891018112
Sickle Cell Disease,SCD,Hispanic,0.957488231653114
Sickle Cell Disease,SCD,Other,0.960180479887402
Sickle Cell Disease,SCD,White,1
;
Run;

/*@Action: CDC Distribution by Disease ***/
Proc Sort Data=CDC_Condition_Dist;
	By Abbreviation Cumulative;
Run;

Proc Transpose Data=CDC_Condition_Dist Out=CDC_Condition_Dist_2(DROP=_NAME_ Rename=(Abbreviation=Condition)) Prefix=CDC_;
	ID Race;
	Var Cumulative;
	By Abbreviation;
Run;

Proc Sql NOPRINT;
	Select Count(Distinct Condition) Into :Cond_Cnt Trimmed From CDC_Condition_Dist_2;
	Select Condition Into :ABBRV Separated by " " From CDC_Condition_Dist_2;
Quit;

/*************************************************************************************************************/
/**************************************** -- RACE IMPUTATION MACRO -- ****************************************/
/*************************************************************************************************************/
%Macro Impute_Race_Condition(Intake, Seed);
	Proc Datasets Lib=Work nolist; Delete Imputed_Race_by_Cond; Quit;

	%Do I=1 %To &Cond_Cnt. %By 1;
		%Let Condition = %SCAN(&ABBRV., &I.);
		Proc Sql;
			Create table Cond_&I. as
				Select *, Ranuni(%EVAL(&SEED.+&I.)) as Randuni
					From &Intake.
						Where Condition = "&Condition."
							Order by Condition, PATID;
		Quit;

		Data Cond_&I._Impute(Drop=Randuni CDC_:);
			Merge Cond_&I. CDC_Condition_Dist_2(Where=(Condition="&Condition."));
				By Condition;
					Length Impute_Race $9.;
					If 		  0<=Randuni<=CDC_Asian    Then Impute_Race = "Asian";    Else
					If CDC_Asian<Randuni<=CDC_Black    Then Impute_Race = "Black";    Else
					If CDC_Black<Randuni<=CDC_Hispanic Then Impute_Race = "Hispanic"; Else
					If CDC_Hispanic<Randuni<=CDC_Other Then Impute_Race = "Other";    Else
														    Impute_Race = "White";
		Run;

		Proc Append Base=Imputed_Race_by_Cond Data=Cond_&I._Impute;
		Run;
		Proc Datasets NOLIST;
			Delete Cond_:;
		Quit;
	%End;
%Mend;
/*************************************************************************************************************/

/*************************************************************************************************************/
/**************************************** -- RUN IMPUTATION MACRO -- *****************************************/
/*************************************************************************************************************/
/*@Action: Impute Race for records with a condition and indicated race: unknown ***/
%Impute_Race_Condition(Intake=People_with_Condition, Seed=23);

/*************************************************************************************************************/
/*@PROGRAM END ***/
