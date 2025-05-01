/*******************************************************************************************/
/***PROGRAM: Module4-Pre-Processing_CODI_HPQ.SAS						 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)		
/*** DESCRIPTION: Race Imputation      													 ***/
/*** Step 3: Assign race based on non-Hispanic racial distribution in the state-county.  ***/ 
/*** Impute unknown race for Non-Hispanic 												 ***/
/*******************************************************************************************/
 
Data Known_NonHispanic;
	Set &EHR_PRE_Out._hh2;
		if Race NOT in ("Unknown", "Hispanic");
Run; 

Proc SQL; 
create table Known_NonHispanic_count as select
Geography, 
sum(Race0="White") as NH_White, sum(Race0="Black") as NH_Black, sum(Race0="Asian") as NH_Asian, sum(Race0="Other") as NH_Other
from Known_NonHispanic
group by Geography;

Proc SQL;
create table ACS_withData(drop=geography2) as
select a.*, b.*
from SASOut.acs_county as a right join Known_NonHispanic_count(rename=geography=geography2) as b 
on a.geography=b.geography2;


Data ACS1_withData;
set ACS_withData;
pop_nhisp_white=NON_LATX_WHITE;
pop_nhisp_black=NON_LATX_BLACK;
pop_nhisp_asian=NON_LATX_ASIAN;
pop_nhisp_other=NON_LATX_GE2R+NON_LATX_AIAN+NON_LATX_NHPI+NON_LATX_OTHER;

pop_aug_nhisp_white=max(0,pop_nhisp_white-NH_White);
pop_aug_nhisp_black=max(0,pop_nhisp_black-NH_Black);
pop_aug_nhisp_asian=max(0,pop_nhisp_asian-NH_Asian);
pop_aug_nhisp_other=max(0,pop_nhisp_other-NH_Other);

pop_nhisp=TOTAL_NON_LATX;
pop_hisp=total_lat;
pop_aug_nhisp=max(0,pop_nhisp-NH_White-NH_Black-NH_Asian-NH_Other);

if pop_aug_nhisp>0 then do;
 pop_aug_nhisp_white_cpct=(pop_aug_nhisp_white) /pop_aug_nhisp;
 pop_aug_nhisp_black_cpct=(pop_aug_nhisp_white + pop_aug_nhisp_black) /pop_aug_nhisp;
 pop_aug_nhisp_asian_cpct=(pop_aug_nhisp_white + pop_aug_nhisp_black + pop_aug_nhisp_asian)/ pop_aug_nhisp;
 pop_aug_nhisp_other_cpct=(pop_aug_nhisp_white + pop_aug_nhisp_black + pop_aug_nhisp_asian + pop_aug_nhisp_other)/pop_aug_nhisp;

 pop_nhisp_white_cpct=(pop_nhisp_white) /pop_nhisp;
 pop_nhisp_black_cpct=(pop_nhisp_white + pop_nhisp_black) /pop_nhisp;
 pop_nhisp_asian_cpct=(pop_nhisp_white + pop_nhisp_black + pop_nhisp_asian)/ pop_nhisp;
 pop_nhisp_other_cpct=(pop_nhisp_white + pop_nhisp_black + pop_nhisp_asian + pop_nhisp_other)/pop_nhisp;
end;

else do;
 pop_aug_nhisp_white_cpct=0;
 pop_aug_nhisp_black_cpct=0;
 pop_aug_nhisp_asian_cpct=0;
 pop_aug_nhisp_other_cpct=0;

 pop_nhisp_white_cpct=0;
 pop_nhisp_black_cpct=0;
 pop_nhisp_asian_cpct=0;
 pop_nhisp_other_cpct=0;
end;

keep geography state_code county_code NH_White NH_Black NH_Asian NH_Other
pop_hisp pop_nhisp 
pop_nhisp_white pop_nhisp_black pop_nhisp_asian pop_nhisp_other
pop_aug_nhisp_white pop_aug_nhisp_black pop_aug_nhisp_asian pop_aug_nhisp_other pop_aug_nhisp
pop_nhisp_white_cpct pop_nhisp_black_cpct pop_nhisp_asian_cpct pop_nhisp_other_cpct  
pop_aug_nhisp_white_cpct pop_aug_nhisp_black_cpct pop_aug_nhisp_asian_cpct pop_aug_nhisp_other_cpct 
;
run;

Data Unknown_NonHispanic;
	Set &EHR_PRE_Out._hh2;
		if Race in ("Unknown");
where householder=1;
Run;

Proc SQL;
create table Unknown_NonHispanic2(drop=geography2) as
select a.*, b.*
from Unknown_Nonhispanic as a left join ACS1_withData(rename=geography=geography2 drop=state_code county_code) as b 
on a.geography=b.geography2;

Data Nonhispanic_unknownrace0;
set Unknown_NonHispanic2;
rand1=rand("Uniform");

if pop_aug_nhisp >0 then do;
	if rand1<=pop_aug_nhisp_white_cpct then Impute_Race="White  ";
	else if pop_aug_nhisp_white_cpct<rand1 and rand1<=pop_aug_nhisp_black_cpct then Impute_Race="Black";
	else if pop_aug_nhisp_black_cpct<rand1 and rand1<=pop_aug_nhisp_asian_cpct then Impute_Race="Asian";
	else if pop_aug_nhisp_asian_cpct<rand1 then Impute_Race="Other";
end;

else do;
	if rand1<=pop_nhisp_white_cpct then Impute_Race="White  ";
	else if pop_nhisp_white_cpct<rand1 and rand1<=pop_nhisp_black_cpct then Impute_Race="Black";
	else if pop_nhisp_black_cpct<rand1 and rand1<=pop_nhisp_asian_cpct then Impute_Race="Asian";
	else if pop_nhisp_asian_cpct<rand1 then Impute_Race="Other";
 
end;
run;
 
data  Nonhispanic_unknownrace;
	set  Nonhispanic_unknownrace0;
	array Impute_Race2_(&M) $;

	call streaminit(124987653);
	do i = 1 to &M;
	   r = rand("Uniform");  

	   
	if pop_aug_nhisp >0 then do;
		if r<=pop_aug_nhisp_white_cpct then Impute_Race2_(i)="White  ";
		else if pop_aug_nhisp_white_cpct<r and r<=pop_aug_nhisp_black_cpct then Impute_Race2_(i)="Black";
		else if pop_aug_nhisp_black_cpct<r and r<=pop_aug_nhisp_asian_cpct then Impute_Race2_(i)="Asian";
		else if pop_aug_nhisp_asian_cpct<=r then Impute_Race2_(i)="Other";
	end;

	else do;
		if r<=pop_nhisp_white_cpct then Impute_Race2_(i)="White  ";
		else if pop_nhisp_white_cpct<r and r<=pop_nhisp_black_cpct then Impute_Race2_(i)="Black";
		else if pop_nhisp_black_cpct<r and r<=pop_nhisp_asian_cpct then Impute_Race2_(i)="Asian";
		else if pop_nhisp_asian_cpct<=r then Impute_Race2_(i)="Other";

	end;


	end;
	keep geography household_id Impute_Race2_:;
run;


/*End of program*/
