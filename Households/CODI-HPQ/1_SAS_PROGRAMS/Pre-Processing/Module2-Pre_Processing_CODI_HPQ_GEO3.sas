/*******************************************************************************************/
/***PROGRAM: Module2-Pre-Processing_CODI_HPQ.SAS						 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)															 ***/
/***DESCRIPTION: Impute race based on person in the same household. Impute from a random     ***/
/*** household member if missing and make race the same for all household members		 ***/
/*******************************************************************************************/

/* "Step 1: Race imputation using race of other household members : 1. adult's race, 2. teen's/youth's race" */
   
  
 
Proc SQL;
create table HH_race as select
Geography,county_fips_code,household_id,householder,race_eth_missing,age_cat,RANUNI(12356768) as random ,Race as Householder_Race
from &EHR_PRE_Out._hh(where=(Race^="Unknown"))
order by Geography,county_fips_code,household_id,householder desc,race_eth_missing,random;

Proc sort data=HH_race nodupkey out=HH_race;
by geography county_fips_code household_id;
run;

Proc SQL;
create table &EHR_PRE_Out._hh2 as select
a.*,coalesce(b.Householder_Race,"Unknown") as Race
from &EHR_PRE_Out._hh(rename=race=Race0) as a left join HH_race as b 
on a.geography=b.geography and a.household_id=b.household_id ;
