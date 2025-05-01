/*******************************************************************************************/
/***PROGRAM: Module2-CODI_HPQ.SAS						 				 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)							 ***/
/***DESCRIPTION:  Raking preparation and Raking									 		 ***/
/*******************************************************************************************/
 
Data Exit_Imputed;
set USER_SELECT;
Base_Weight=1;
if household_childage_cat='Under 6 years and 6 to 17 years' then household_childage_cat='Both l6 and 6to17';
run;

Proc Freq data=Exit_Imputed;
table geography household_childage_cat HHAdults race;
run;
 
%Macro ACS_Geo;
%If &ALL_H_STATES=Y %then %do;
	Proc SQL; 
	create table ACS_select as 
	select distinct b.*
	from FIPS_Codes as a left join ACS as b
	on a.label = substr(b.geography,1,2)
	where a.label is not null;
%end;

%else %if &ALL_H_STATES=N and &GEO_H_GROUP=STATE %then %do;
	Proc SQL; 
	create table ACS_select as 
	select *
	from ACS 
	where geography is not null and substr(geography,1,2) in (&GEO_H_LIST) ;
%end;

%else %if &ALL_H_STATES=N and &GEO_H_GROUP=COUNTY %then %do;
	Proc SQL; 
	create table ACS_select as 
	select distinct b.*
	from Exit_Imputed as a left join ACS as b
	on a.geography = b.geography
	where a.geography is not null;
%end;

%Mend;

%ACS_Geo;

Data ACS_in;
set ACS_select ;

hh_fam_ppl_l18_rel=female_rel_child_l18+male_rel_child_l18+married_rel_child_l18;


/*Race cat in ACS: hh_fam_female_asian, hh_fam_female_black,hh_fam_female_ge2race, hh_fam_female_nhpi,hh_fam_female_nian,hh_fam_female_other,hh_fam_female_white */
Asian=round(hh_fam_ppl_l18*(hh_fam_asian/hh_fam),1);	
White=round(hh_fam_ppl_l18*(hh_fam_white/hh_fam),1);
Black=round(hh_fam_ppl_l18*(hh_fam_black/hh_fam),1);
/*Other: hh_fam_female_ge2race, hh_fam_female_nhpi, hh_fam_female_nian, hh_fam_female_other */
Other=hh_fam_ppl_l18-Asian-White-Black;  

'Under 6 years only'n=hh_fam_ppl_l18*(female_rel_child_l6+male_rel_child_l6+married_rel_child_l6)/hh_fam_ppl_l18_rel;
'6 to 17 years only'n=hh_fam_ppl_l18*(female_rel_child_6_17+male_rel_child_6_17+married_rel_child_6_17)/hh_fam_ppl_l18_rel;
'Both l6 and 6to17'n=hh_fam_ppl_l18-'Under 6 years only'n-'6 to 17 years only'n;

'one adult'n=hh_fam_ppl_l18*(female_rel_child_l18+male_rel_child_l18)/hh_fam_ppl_l18_rel;
'two adults'n=hh_fam_ppl_l18-'one adult'n;

rename 'Both l6 and 6to17'n='Both l6 and 6to17'n;

run;


Data Prepped_USER_File;
length HHAdults_Raking Race_Raking $16.;
		Set Exit_Imputed;
			Label Age_Raking   = "Raking: Age"
				  Race_Raking  = "Raking: Race"
				  GEO_Raking   = "Raking: Geography"
				  PersonHH_Raking	= "Raking: Number of person in household"
				  Educ_Raking  = "Raking: Education"
				  ;
			Orig_Age_Raking   = household_childage_cat; 	   Age_Raking   = household_childage_cat;
			Orig_Race_Raking  = Race;		  		   		   Race_Raking  = Race;
			Orig_Geo_Raking	  = Geography;					   Geo_Raking   = Geography;
			Orig_Educ_Raking  = ba_g20; 					   	   Educ_Raking  = ba_g20;
			Orig_HHAdults_Raking = HHAdults;					   HHAdults_Raking = HHAdults;
Run;

/*@Action: Generate Control Totals ***/
 %let Age_list= 'Under 6 years only'n '6 to 17 years only'n 'Both l6 and 6to17'n;
 %let Race_list= White Black Asian Other;
 %let HHAdults_list= 'one adult'n 'two adults'n;


  /*@Action: HHAdults Full Control Totals ***/
Proc sort data=ACS; by Geography; run;

Proc tabulate data=ACS_in out=ACS_HHAdults_Controls0(drop=_TYPE_	_PAGE_	_TABLE_) missing;
var &HHAdults_list;
table &HHAdults_list;
by Geography;
run;

Proc transpose data=ACS_HHAdults_Controls0 out=ACS_HHAdults_Controls(rename=COL1=mrgtotal rename=_NAME_=HHAdults_raking);
by Geography;
run;

Data ACS_HHAdults_Controls;
length HHAdults_Raking $16.;
set ACS_HHAdults_Controls;
HHAdults_raking=tranwrd(HHAdults_raking,"_Sum","");
run;

 /*@Action: Age Control Totals ***/
Proc sort data=ACS; by Geography; run;

Proc tabulate data=ACS_in out=ACS_Age_Controls0(drop=_TYPE_	_PAGE_	_TABLE_) missing;
var &Age_list;
table &Age_list;
by Geography;
run;

Proc transpose data=ACS_Age_Controls0 out=ACS_Age_Controls(rename=COL1=mrgtotal rename=_NAME_=Age_raking);
by Geography;
run;

Data ACS_Age_Controls;
set ACS_Age_Controls;
Age_raking=tranwrd(Age_raking,"_Sum","");
run;

/*@Action: Race Control Totals ***/
Proc tabulate data=ACS_in out=ACS_Race_Controls0(drop=_TYPE_	_PAGE_	_TABLE_) missing;
var &Race_list;
table &Race_list,sum;
by Geography;
run;

Proc transpose data=ACS_Race_Controls0 out=ACS_Race_Controls(rename=COL1=mrgtotal rename=_NAME_=Race_Raking);
by Geography;
run;

Data ACS_Race_Controls;
length Race_Raking $16.;
set ACS_Race_Controls;
Race_raking=tranwrd(Race_raking,"_Sum","");
run;

/*@Action: Geography Control Totals ***/
Proc tabulate data=ACS_in out=ACS_Geo_Controls0(drop=_TYPE_	_PAGE_	_TABLE_) missing;
var hh_fam_ppl_l18;
class ba_g20;
table ba_g20,hh_fam_ppl_l18*sum;
by Geography;
run;

Proc transpose data=ACS_Geo_Controls0 out=ACS_Geo_Controls(rename=(COL1=mrgtotal ba_g20=Educ_Raking) rename=Geography=Geo_Raking drop=_NAME_);
by Geography ba_g20;
run;

/*@Action: All Control Totals ***/
Data ACS_full_controls;
retain Group Level Geo_Raking Geography MrgTotal;
set ACS_Geo_Controls(in=a ) ACS_HHAdults_Controls(in=b) ACS_Race_Controls(in=c) ACS_Age_Controls(in=d);
if a=1 then Group="Geography";
else if b=1 then Group="HHAdults";
else if c=1 then Group="Race";
else if d=1 then Group="Age";
else Group="None";
Geography=coalescec(compress(Geo_Raking),Geography);
STATE_FIPS=Substr(GEOGRAPHY,1,2);
Level=coalescec(HHAdults_raking,Race_Raking,Age_raking,compress(Educ_Raking));
run;


%let AGE_INPUT_CLEAN= %sysfunc(tranwrd(%QUOTE(&Age_query),'Under 6 years and 6 to 17 years','Both l6 and 6to17'));
%let Drop_Childage_clean= %sysfunc(tranwrd(%QUOTE(&Drop_Childage),'Under 6 years and 6 to 17 years','Both l6 and 6to17'));


/*@Action: Control Totals Adjustment***/
Proc sort data=ACS_full_controls; by Group; run;
Data ACS_select;
set ACS_full_controls;

if "&ALL_H_STATES"="N" then do; 
	if (upcase(level) in (%sysfunc(upcase(&RACE_QUERY.,&AGE_INPUT_CLEAN.)))) and &Geo_level in (&GEO_H_LIST.) 
		then keep=1;
	else keep=0;

	if group="HHAdults"  or (Group="Geography" and &Geo_level in (&GEO_H_LIST.)) then keep=1;
end;

else do;
	if (upcase(level) in (%sysfunc(upcase(&RACE_QUERY.,&AGE_INPUT_CLEAN.)))) then keep=1;
	else keep=0;

	if group="HHAdults"  or (Group="Geography") then keep=1;
end;

/* Dropped variables */
if (upcase(level) in (%sysfunc(upcase(&Drop_Race)),%sysfunc(upcase(&Drop_Childage_clean)))) then keep=0;

run; 

%put &GEO_H_LIST.;

Proc SQL;
create table Percent_select as select
Group,Geography,Keep,sum(MrgTotal) as MrgTotal,sum(MrgTotal*Keep) as MrgTotal_Keep 
from ACS_select
Group by Group,Geography,Keep;

Proc SQL;
create table Dist_select as select
Group,Geography,level,Keep,
sum(MrgTotal*Keep) as MrgTotal_Keep,
max(0,(MrgTotal*Keep)/sum(MrgTotal*Keep)) as dist_keep
from ACS_select(where=(keep=1))
Group by Group,Geography,Keep;

Proc SQL;
create table Count_select as select
Group,Geography,sum(MrgTotal) as MrgTotal,
sum(MrgTotal_Keep) as MrgTotal_Keep,
sum(MrgTotal_Keep)/sum(MrgTotal) as Percent_Keep
from Percent_select
Group by Group,Geography
order by Geography, MrgTotal;

Proc transpose data=Count_select out=Count_select2(drop=_NAME_) prefix=Pct_;
by Geography MrgTotal;
id Group;
var Percent_Keep;
run;

Proc SQL;
create table Count_select3 as select
*, (Pct_Age*Pct_Race*Pct_HHAdults) as Pct_total,
(Pct_Age*Pct_Race*Pct_HHAdults)*MrgTotal as Total_Updated
from Count_select2 
order by Geography;

Proc SQL;
create table Updated_Totals as select
a.*, b.Total_Updated, b.Total_Updated*a.dist_keep as MrgTotal,
c.Educ_Raking,c.HHAdults_raking,c.Race_Raking,c.Age_raking,c.Geo_raking
from dist_select as a left join Count_select3 as b 
on a.geography=b.geography
left join ACS_full_controls as c
on a.geography=c.geography and a.level=c.level
Order by Geography,Group;

Proc Sql;
		Create table ACS_Age_Controls as
			Select Age_Raking,Geography, mrgtotal From Updated_Totals(where=(Group="Age"));
		Create table ACS_HHAdults_Controls as
			Select HHAdults_Raking,Geography, mrgtotal From Updated_Totals(where=(Group="HHAdults"));
		Create table ACS_Race_Controls as
			Select Race_Raking,Geography, mrgtotal From Updated_Totals(where=(Group="Race"));
		Create table ACS_Geo_Controls as
			Select Geo_raking,Educ_Raking, mrgtotal From Updated_Totals(where=(Group="Geography"));
Quit;


	/*@action: Collapse Raking Levels ***/
	%Macro Setup_Wgt(Collapse_Var, FileIn, FileOut, Var, Num_Lvls, Min_Count);
		%If &Collapse_Var. = Y %Then %Do;
			Data &FileOut.;
				Set &FileIn.;
			Run;



			%If &Var.^=GEO %Then %Do I=1 %To &Num_Lvls.;
				Proc Freq Data=&FileOut. Noprint;
					Table &Var._Raking / out=Sample_Joint(Keep=&Var._Raking Count);
				Proc Freq Data=ACS_&Var._Controls Noprint;
					Table &Var._Raking / out=ACS_Raking_Levels(Keep=&Var._Raking);
				Data Sample_Joint(Keep=&Var._Raking Count Collapse_Flg);
					Merge Sample_Joint ACS_Raking_Levels;
						By &Var._Raking;
							Array Change _NUMERIC_; Do Over Change; If Change=. Then Change=0; End;
							If Count<&Min_Count. Then Collapse_Flg = Put(&Var._Raking, $&Var._&I._C.);  Else Collapse_Flg="";
				Run;

				Proc Sql Noprint; Select Count(*) into :Collapse_Flg Trimmed From Sample_Joint Where Collapse_Flg = "&I.";
				Quit;

				%put &Collapse_Flg;

				%If %Eval(&Collapse_Flg.>0) %Then %Do;
					%Let &Var._Collapse=&Var.;
					Data Sample_Joint_Collapse;
					Length New_level $16.;
						Set Sample_Joint;
							Collapse_Flg = Put(&Var._Raking, $&Var._&I._C.);
							If Strip(Collapse_Flg)^="" Then New_Level = Put(Collapse_Flg, $Collapse_&Var..);
								Else New_Level = &Var._Raking;
					Proc Sort Data=&FileOut.;
						By &Var._Raking;
					Proc Sort Data=ACS_&Var._Controls;
						By &Var._Raking;
					Data &FileOut.(Rename=(New_Level = &Var._Raking));
						Merge &FileOut.(In=A) Sample_Joint_Collapse(In=B Keep=&Var._Raking New_Level);
							By &Var._Raking;
								If A;
								Drop &Var._Raking;
					RUN;
					Data ACS_&Var._Controls(Rename=(New_Level = &Var._Raking));
						Merge ACS_&Var._Controls(In=A) Sample_Joint_Collapse(In=B Keep=&Var._Raking New_Level);
							By &Var._Raking;
								If A;
								Drop &Var._Raking;
					Run;
				%End;
			%End;
			%Else %Do; 
				%Let I=1; %Let Pass=0;
				%Do %Until(&Pass.=1 or &I.>4);
					Proc Freq Data=&FileOut. Noprint;
						Table Educ_Raking*&Var._Raking / out=Sample_Joint(Keep=Educ_Raking &Var._Raking Count);
					run;					
					Proc Freq Data=ACS_&Var._Controls Noprint;
						Table Educ_Raking*&Var._Raking/ out=ACS_Raking_Levels(Keep=Educ_Raking &Var._Raking);
					run;
					Data Sample_Joint(Keep=Educ_Raking &Var._Raking Count) Counts(Keep=Educ_Raking Tot_Educ);
						Merge Sample_Joint ACS_Raking_Levels;
							By Educ_Raking &Var._Raking;
								Array Change _NUMERIC_; Do Over Change; If Change=. Then Change=0; End;
								Output Sample_Joint;
								If First.Educ_Raking Then Tot_Educ=1; Else Tot_Educ+1;
								If Last.Educ_Raking Then Output Counts;
					Data Sample_Joint;
						Merge Sample_Joint Counts;
							By Educ_Raking;
					Proc Sort Data=Sample_Joint;
						By Tot_Educ Educ_Raking Count;
					Data &Var._Collapse;
						Set Sample_Joint End=Last;
							By Tot_Educ;				
								Retain Global_Fail(0);
								Global=_N_;

								If First.Tot_Educ Then Do; EducCnt=1; Fail=0; End;
									Else EducCnt+1;
					
								If Count<&Min_Count. Then do;
									Call Symput("Geo_Collapse", "Geography");
									Global_Fail+1;
									Fail+1;
								End;
								%If &I.=1 %Then %Do;
									If Count<&Min_Count. Then New_Level="EDUC"||Strip(Educ_Raking);
										Else New_Level=&Var._Raking;
									New_Educ=Educ_Raking;
								%End;
								%Else %If &I.=2 %Then %Do;
									If Fail>0 and ^(First.Tot_Educ and Last.Tot_Educ) and EducCnt in (1, 2) Then New_Level="EDUC"||Strip(Educ_Raking);
										Else New_Level=&Var._Raking;
									New_Educ=Educ_Raking;
								%End;

								If Last then Call Symput('Global_Fail',Global_Fail);
					Run;

					%If &I.=3 or &I.=4 %Then %Do;
						Data &Var._Collapse;
							Set &Var._Collapse;
									%If &I.=3 and %Eval(&Global_Fail.>0) %Then %Do;
										If Substr(&Var._Raking, 1, 4)="EDUC" Then New_Level="EDUC9";
											Else New_Level=&Var._Raking;
										New_Educ="9";
									%End;
									%Else %If &I.=4 and %Eval(&Global_Fail.>0) %Then %Do;
										If Global=2 Then New_Level="EDUC9";
											Else New_Level=&Var._Raking;
										New_Educ=Educ_Raking;
									%End;
									%Else %Do;
										New_Level=&Var._Raking;
										New_Educ=Educ_Raking;
									%End;
						Run;
					%End;

					Proc Sort Data=&Var._Collapse(Keep=Educ_Raking &Var._Raking New_Level New_Educ);
						By Educ_Raking &Var._Raking;
					Proc Sort Data=&FileOut.;
						By Educ_Raking &Var._Raking;
					Run;

					Data &FileOut.(Rename=(New_Educ = Educ_Raking New_Level = &Var._Raking));
						Merge &FileOut.(In=A) &Var._Collapse(In=B);
							By Educ_Raking &Var._Raking;
								If A;
								Drop Educ_Raking &Var._Raking;
					Proc Sort Data=ACS_&Var._Controls;
						By Educ_Raking &Var._Raking;
					Data ACS_&Var._Controls(Rename=(New_Educ = Educ_Raking New_Level = &Var._Raking));
						Merge ACS_&Var._Controls(In=A) &Var._Collapse(In=B);
							By Educ_Raking &Var._Raking;
								If A;
								Drop Educ_Raking &Var._Raking;
					Run;

					/*@Action: Update exit criteria ***/
					%If &Global_Fail.=0 %Then %Let Pass=1;			
					%Let I=%Eval(&I.+1);
				%End;
			%End;

			/*@Action: Update the Collapse Pass macro variable, if failed replace 1 with a 0 ***/
			Proc Freq Data=&FileOut. Noprint;
				Table &Var._Raking / out=Collapse_Check(Keep=&Var._Raking Count);
			Run;

			Proc SQL Noprint;
				Select Count(*) into: Collapse_Check_&Var. Trimmed From Collapse_Check Where Count<&Min_Count.;
				%If &&&Collapse_Check_&Var>0 %Then %Let Collapse_Pass=0;
			Quit;
		%End;

		%Else %Do;
			Data &FileOut.;
				Set &FileIn.;
			Run;

			/*@Action: Update the Collapse Pass macro variable, if failed replace 1 with a 0 ***/
			Proc Freq Data=&FileOut. Noprint;
				Table &Var._Raking / out=Collapse_Check(Keep=&Var._Raking Count);
			Run;

			Proc SQL Noprint;
				Select Count(*) into: Collapse_Check_&Var. Trimmed From Collapse_Check Where Count<&Min_Count.;
				%If %Eval(&&&Collapse_Check_&Var>0) %Then %Let Collapse_Pass=0;
			Quit;
		%End;
	%Mend;

	/*@Action: Run collapse macro on each weighting variable ***/
	%Global Collapse_Foot;
	%Let Age_Collapse=; %Let Geo_Collapse=;

	/*@Action: Perform collapsing and/or cell count checks ***/
	%Setup_Wgt(Collapse_Var=N, FileIn=Prepped_USER_File, FileOut=PREWGT_USER_FILE, Var=HHAdults,  Num_Lvls=,  Min_Count=&WGTCELL_MIN.);
	%Setup_Wgt(Collapse_Var=N, FileIn=PREWGT_USER_FILE,	 FileOut=PREWGT_USER_FILE, Var=Age,  Num_Lvls=,  Min_Count=&WGTCELL_MIN.);
	%Setup_Wgt(Collapse_Var=N, FileIn=PREWGT_USER_FILE,	 FileOut=PREWGT_USER_FILE, Var=Race,  Num_Lvls=,  Min_Count=&WGTCELL_MIN.);
	%Setup_Wgt(Collapse_Var=Y, FileIn=PREWGT_USER_FILE,	 FileOut=PREWGT_USER_FILE, Var=GEO,  Num_Lvls=,  Min_Count=&WGTCELL_MIN.);
 
	%macro collapse_notes;
	/*@Action: Load collapsing information into macro variable, output as footnote in report ***/
	%If &Age_Collapse.= and &Geo_Collapse.= %Then %Let Collapse_Foot=(None);
		%Else %Let Collapse_Foot=(%SYSFUNC(COMPBL(&Geo_Collapse.)));

	ods exclude none;

	Proc Freq data=PREWGT_USER_FILE;
	table Geography*Orig_Educ_Raking/ missing list;
	table Geo_Raking/ missing list;
	table Geo_Raking*Geography*Orig_Educ_Raking/ missing list;
	run;

	/*@Action: Update Census controls with new raking levels (post-collapse) ***/
	Proc Sql;
		Create table ACS_Age as
			Select Age_Raking, sum(mrgtotal) as mrgtotal From ACS_Age_Controls Group by Age_Raking;
		Create table ACS_HHAdults as
			Select HHAdults_Raking, sum(mrgtotal) as mrgtotal From ACS_HHAdults_Controls Group by HHAdults_Raking;
		Create table ACS_Race as
			Select Race_Raking, sum(mrgtotal) as mrgtotal From ACS_Race_Controls Group by Race_Raking;
		Create table ACS_Geo as
			Select GEO_Raking, sum(mrgtotal) as mrgtotal From ACS_Geo_Controls Group by GEO_Raking;
	Quit;


	/*@Action: Load collapsing information into macro variable, output as footnote in report ***/
	%If &Age_Collapse.= and &Geo_Collapse.= %Then %Let Collapse_Foot=(None);
		%Else %Let Collapse_Foot=(%SYSFUNC(COMPBL(&Age_Collapse. &Geo_Collapse.)));
	%mend;
	
	%collapse_notes;

	/*********************************************************************************************************************/
	/************************************************ -- RAKING -- *******************************************************/
	/*********************************************************************************************************************/

	/*@Action: Get Variables for raking dimension specification ***/
	%macro GetRakingVars;
	%global Raking_var Raking_var2 Raking_var_n;
	Proc Sql noprint;
			%Let Raking_var=ACS_Geo;
			%Let Raking_var2=GEO_Raking;
			%let Raking_var_n=;
			Select (count(Distinct Age_Raking))>1 into :n_ACS_Age From ACS_Age;
			Select (count(Distinct HHAdults_Raking))>1 into :n_ACS_HHAdults From ACS_HHAdults;
			Select (count(Distinct Race_Raking))>1 into :n_ACS_Race From ACS_Race;
			%let raking_var_n=%eval(1+&n_ACS_Age+&n_ACS_Race+&n_ACS_HHAdults);
			%If (&n_ACS_Age=1) %Then %do; 
				%Let Raking_var=&Raking_var. ACS_Age;
				%Let Raking_var2=&Raking_var2. Age_Raking;
			%end;
			%If (&n_ACS_HHAdults=1) %Then %do;
				%Let Raking_var=&Raking_var. ACS_HHAdults;
				%Let Raking_var2=&Raking_var2. HHAdults_Raking;
			%end;
			%If (&n_ACS_Race=1) %Then %do;
				%Let Raking_var=&Raking_var. ACS_Race;
				%Let Raking_var2=&Raking_var2. Race_Raking;
			%end; 
	quit;
	%mend;
	
	%GetRakingVars;

	/*@Action: Raking ***/
	%RAKING(inds=PREWGT_USER_FILE, outds=Weighted_USER_File, inwt=Base_Weight, freqlist= &Raking_var., outwt=Raked_Weight, byvar=, varlist= &Raking_var2., numvar=&raking_var_n., cntotal=, trmprec=1, numiter=50);


/*End of program*/



