/*******************************************************************************************/
/***PROGRAM: Module3-CODI_HPQ.SAS						 				 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)							 ***/
/***DESCRIPTION:  Estimation													 		 ***/
/*******************************************************************************************/
  
proc surveyfreq data=Weighted_USER_File varmethod=taylor ;
strata state_fips_code;
cluster household_id;
table Youth_and_teens*adults /  cl clwt var varwt alpha=0.05;
weight Raked_Weight;
ods output CrossTabs=out_HH_RakeWgt;
run;



proc surveyfreq data=Weighted_USER_File varmethod=taylor ;
strata state_fips_code;
cluster household_id;
table Youth_and_teens*adults /  cl clwt var varwt alpha=0.05;
weight Base_Weight;
ods output CrossTabs=out_HH_BaseWgt;
run;
 
Data output_pop;
retain 'Youth and Teens Weight Category'n 'Adults Weight Category'n;
set out_HH_RakeWgt;
'Youth and Teens Weight Category'n=Youth_and_teens;
'Adults Weight Category'n=Adults;
if Youth_and_teens^="" and Adults^="" ;
drop Table	F_Youth_and_teens	Youth_and_teens	F_Adults Adults _SkipLine;
Population=round(WgtFreq,1);
'Population %'n=round(Percent,.01);
'Population % Standard Error'n=round(StdErr,.01);
keep 'Youth and Teens Weight Category'n	'Adults Weight Category'n
	Population 'Population %'n 'Population % Standard Error'n;
run;
 
Data output_sample;
retain 'Youth and Teens Weight Category'n 'Adults Weight Category'n;
set out_HH_BaseWgt;
'Youth and Teens Weight Category'n=Youth_and_teens;
'Adults Weight Category'n=Adults;
if Youth_and_teens^="" and Adults^="" ;
drop Table	F_Youth_and_teens	Youth_and_teens	F_Adults Adults _SkipLine;
Sample=round(WgtFreq,1);
'Sample %'n=round(Percent,.01);
'Sample % Standard Error'n=round(StdErr,.01);
keep 'Youth and Teens Weight Category'n	'Adults Weight Category'n
	Sample 'Sample %'n 'Sample % Standard Error'n;
run;
 

Data USER_Prevalence_Estimates;
retain Order 'Youth and Teens Weight Category'n	'Adults Weight Category'n Sample Population 'Sample %'n	'Sample % Standard Error'n	'Population %'n	'Population % Standard Error'n;
merge output_sample output_pop;
by 'Youth and Teens Weight Category'n	'Adults Weight Category'n;
run;
