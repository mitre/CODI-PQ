
/*******************************************************************************************/
/***PROGRAM: Module1-Pre-Processing_CODI_HPQ.SAS						 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)							 ***/
/***DESCRIPTION:  Prepare needed variables for statistical weighting					 ***/
/*******************************************************************************************/
   

/*Prepare needed variables for statistical weighting */


/*Pre-process ACS files */
Data ACS_PRE_Out_Household;
set  SASOut.ACS_COUNTY; 
run;


Proc sort data=ACS_PRE_Out_Household; by geography State_Code County_code; run;

/*Assign householder based on age distribution of householders in the county*/

Proc transpose  data=ACS_PRE_Out_Household out=ACS_age(rename=COL1=count) name=agegrp;
by geography State_Code County_code;
var hh_income_l25 hh_income_25_44 hh_income_45_64 hh_income_65pl;
run;

Proc SQL;
create table ACS_age_fr as select
geography, State_Code, county_code,agegrp, count, sum(count) as sum_county, count/sum(count) as agegrp_pct 
from ACS_age
group by geography,state_code,county_code;

/*Pre process EHR*/
Data EHR_HH4;
set EHR_SYNTHETIC;

/** Geography **/
County=compress("00"||county_fips_code);
County=substr(County,length(County)-2,3);
State=compress("0"||state_fips_code);
State=substr(state,length(state)-1,2);
Geography=compress(State||County);

/** Clean race **/
if upcase(Race_eth) in ('AFRICAN AMERICAN','BLACK') then Race_eth="Black";
else if upcase(Race_eth) in ('CAUCASIAN','White') then Race_eth="White";
else if upcase(Race_eth) in ('HISPANIC') then Race_eth="Hispanic";
else if upcase(Race_eth) in ('ASIAN') then Race_eth="Asian";
else if upcase(Race_eth) in ('OTHER') then Race_eth="Other";
else if upcase(Race_eth) in ('UNKNOWN') then Race_eth="Unknown";

/** Clean sex **/
if Sex_Num=1 then Sex="Female";
	else if Sex_Num=0 then Sex="Male";

if ageyears>=20 then age_cat="Adults              ";
	else age_cat="Youth/Teens";


/** Clean weight category **/
weight_category0=weight_category;
if weight_category in ("Normal or Healthy Weight","Overweight","Underweight","Does Not Have Obesity") then weight_category="Not Obese";
	else if weight_category in ("Obese","Obesity","Severe Obesity") 
		OR lowcase(substr(weight_category,1,7))="obesity" 
		OR lowcase(substr(weight_category,1,6))="obese"   
		then weight_category="Obese";
	else weight_category="";

if weight_category="Obese" and age_cat in ("Youth/Teens") then age_weight="Youth teens obese      ";
	else if weight_category="Obese" and age_cat in ("Adults") then age_weight="Adults obese";
	else if weight_category="Not Obese" and age_cat in ("Youth/Teens") then age_weight="Youth teens not obese";
	else if weight_category="Not Obese" and age_cat in ("Adults") then age_weight="Adults not obese";

drop Sex_Num State County weight_category0 ;
run;

/* Check Variable Mapping*/
proc freq Data=EHR_HH4;
table weight_category/ list missing;
table age_cat*age_weight /list missing;
table weight_category*age_weight / list missing;
run;
 

/* Create counts of hh members by age group-weight */
Proc sql;
create table Obese_HH as select
geography,state_fips_code,county_fips_code,household_id, age_weight, count(household_id) as n
from EHR_HH4
group by geography,state_fips_code,county_fips_code,household_id, age_weight;
run;

proc transpose data=Obese_HH out=Obese_HH2(drop=_NAME_); 
by geography state_fips_code county_fips_code household_id;
id age_weight;
run;

/* Reassign the weight category of all adults, youth, and teens. Exclude households without an adult or a youth/teen */

Data Obese_HH3;

set Obese_HH2;

if 'Youth teens not obese'n=. then 'Youth teens not obese'n=0;
if 'Youth teens obese'n=. then 'Youth teens obese'n=0;
if 'Adults not obese'n=. then 'Adults not obese'n=0;
if 'Adults obese'n=. then 'Adults obese'n=0;

exclude=0;

if max('Youth teens not obese'n,'Youth teens obese'n)=0 then exclude=1;
if max('Adults not obese'n,'Adults obese'n)=0 then exclude=1;

if 'Adults obese'n>0 then Adults='One or more adults with obesity';
	else Adults='No adults with obesity';
if 'Youth teens obese'n>0 then Youth_and_teens='One or more youth or teens with obesity';
	else Youth_and_teens='No youth or teens with obesity';

if exclude=0;

run;

Proc SQL;
create table EHR_HH5 as select 
b.*,a.Adults,a.Youth_and_teens
from Obese_HH3 as a left join EHR_HH4 as b
on a.household_id=b.household_id;


/*Assign householder based on age group*/

Data EHR_HH6;
set EHR_HH5;

if ageyears<25 then agegrp="hh_income_l25             ";
else if (25<=ageyears and ageyears<=44) then agegrp="hh_income_25_44";
else if (45<=ageyears and ageyears<=64) then agegrp="hh_income_45_64";
else if (65<=ageyears) then agegrp="hh_income_65pl";

if upcase(Race_eth) in ("UNKNOWN") then Race_eth_missing=1;
else  Race_eth_missing=0;

if upcase(Race_eth) not in ("BLACK","ASIAN","WHITE","OTHER") then Race_imputed="Y";
else Race_imputed="N";
run;

proc freq Data=EHR_HH6;
table agegrp / missing;
run;

proc freq Data=EHR_HH6;
table Race_eth / list missing;
run;


/*Exclude age group if it is not contained in the hh and also if person is below 19 from being a householder*/

Proc SQL;
create table EHR_ACS1 as select
a.*,b.agegrp_pct 
from EHR_HH6 as a left join ACS_age_fr as b on
a.state_fips_code=b.State_code and a.county_fips_code=b.County_code and a.agegrp=b.agegrp;


Proc SQL;
create table EHR_ACS2 as select
distinct  state_fips_code,county_fips_code,household_id, agegrp,agegrp_pct 
from EHR_ACS1
where ageyears>=19;

Proc SQL;
create table EHR_ACS3 as select
*, agegrp_pct /sum(agegrp_pct) as ACS_age_fr2
from EHR_ACS2
group by state_fips_code,county_fips_code,household_id
order by state_fips_code,county_fips_code,household_id;

Data EHR_ACS4(drop=r2);
set EHR_ACS3;
r2=RANUNI(912354875); 
householder_age=0;
if first.household_id then do;
	ACS_age_fr2_cum=ACS_age_fr2;
	rd_hh=r2*1;
	IF rd_hh<=ACS_age_fr2_cum then householder_age=1;
	end; 
else do;	
	ACS_age_fr2_cum+ACS_age_fr2;
	rd_hh+0;
end;	
by state_fips_code county_fips_code household_id;
if lag1(ACS_age_fr2_cum)<rd_hh and rd_hh<=ACS_age_fr2_cum then householder_age=1;
run;


Proc SQL;
create table EHR_ACS_HH0 as select
a.*,coalesce(b.householder_age,0) as householder_age,RANUNI(12354345) as r3
from EHR_ACS1 as a left join EHR_ACS4 as b 
on a.state_fips_code=b.state_fips_code and a.county_fips_code=b.county_fips_code and a.household_id=b.household_id and a.agegrp=b.agegrp
order by state_fips_code,county_fips_code,household_id,agegrp,ageyears desc,r3;

/*Assign one person (randomly) in the selected age group in the hh as the householder*/

Data EHR_ACS_HH;
set EHR_ACS_HH0;
householder=0;
if first.agegrp then householder=1;
by state_fips_code county_fips_code household_id agegrp;
if householder_age=0 then householder=0;
drop r3;
run;


/*Knowledge of the age of the children within the household, nb of people and adults in the household*/

Proc SQL; 
create table age_kid as select
state_fips_code,county_fips_code, household_id, sum(ageyears<6) as age_l6,  sum(6<=ageyears and ageyears<=17 ) as age_6to17, 
count(household_id) as nbp_hh,min(sum(ageyears>=18),2) as nb_adults
from EHR_ACS_HH 
group by state_fips_code,county_fips_code, household_id;

Data age_kid;
set age_kid;
if  age_l6>0 and age_6to17>0 then household_childage_cat="Under 6 years and 6 to 17 years";
else if age_l6=0 and age_6to17>0 then household_childage_cat="6 to 17 years only";
else if age_l6>0 and age_6to17=0 then household_childage_cat="Under 6 years only";
run;


Proc SQL;
create table EHR_ACS_HH1 as select
a.*,b.household_childage_cat,c.p_ba,c.ba_g20,min(b.nbp_hh,7) as nbp_hh,b.nb_adults,c.countY_code,c.state_code
from EHR_ACS_HH as a left join age_kid as b 
on a.state_fips_code=b.state_fips_code and a.county_fips_code=b.county_fips_code and a.household_id=b.household_id 
left join ACS_PRE_Out_Household as c on a.county_fips_code=c.County_code and a.state_fips_code=c.state_code
order by state_fips_code,county_fips_code,household_id;


/* Pre-processed file pre-imputation */
Data &EHR_H_PRE_OUT;
set EHR_ACS_HH1;
drop agegrp_pct	householder_age nbp_hh agegrp p_ba;
run;

/*** PROGRAM END ***/