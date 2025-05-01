/*******************************************************************************************/
/***PROGRAM: Module3-Pre-Processing_CODI_HPQ.SAS						 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: Shalima Zalsha (NORC at the University of Chicago)		
/*** DESCRIPTION: Race Imputation 															 ***/		
/*** STEP 2: Assign race based on Hispanic racial distribution by state-county. 		 ***/ 
/*** Impute unknown race for Hispanic													 ***/
/*******************************************************************************************/
  
Data Unknown_Hispanic;
	Set &EHR_PRE_Out._hh2;
		if Race in ("Hispanic");
Run;  

Data ACS1;
set SASOut.acs_county;
pop_hisp_white=LAT_WHITE;
pop_hisp_black=LAT_BLACK;
pop_hisp_asian=LAT_ASIAN;
pop_hisp_other=LAT_GE2R+LAT_AIAN+LAT_NHPI+LAT_OTHER;

pop_nhisp=TOTAL_NON_LATX;
pop_hisp=total_lat;

if total_lat>0 then do;
 pop_hisp_white_cpct=(LAT_WHITE)/total_lat;
 pop_hisp_black_cpct=(LAT_WHITE+LAT_BLACK)/total_lat;
 pop_hisp_asian_cpct=(LAT_WHITE+LAT_BLACK+LAT_ASIAN)/total_lat;
 pop_hisp_other_cpct=(LAT_WHITE+LAT_BLACK+LAT_ASIAN+LAT_GE2R+LAT_AIAN+LAT_NHPI+LAT_OTHER)/total_lat;
end;

else do;
 pop_hisp_white_cpct=0;
 pop_hisp_black_cpct=0;
 pop_hisp_asian_cpct=0;
 pop_hisp_other_cpct=0;
end;

keep geography state_code county_code pop_nhisp
pop_hisp_white pop_hisp_black pop_hisp_asian pop_hisp_other pop_hisp 
pop_hisp_white_cpct pop_hisp_black_cpct pop_hisp_asian_cpct pop_hisp_other_cpct;
run;

Proc SQL;
create table Unknown_Hispanic2(drop=geography2) as
select a.*, b.*
from Unknown_Hispanic as a left join ACS1(drop= state_code county_code rename=geography=geography2) as b 
on a.geography=b.geography2
where householder=1;

Data Unknown_Hispanic2_zero;
set Unknown_Hispanic2;
if pop_hisp=0;
run;  

Data Hispanic_unknownrace0;
set Unknown_Hispanic2;
where race="Hispanic";
if pop_hisp>0;

call streaminit(124987651);
rand1=rand("Uniform");
run;


data Hispanic_unknownrace;
set Hispanic_unknownrace0;
array Impute_Race1_(&M) $;

call streaminit(124987652);
do i = 1 to &M;
   r = rand("Uniform");  
	if r<=pop_hisp_white_cpct then Impute_Race1_(i)="White  ";
	else if pop_hisp_white_cpct<r and r<=pop_hisp_black_cpct then Impute_Race1_(i)="Black";
	else if pop_hisp_black_cpct<r and r<=pop_hisp_asian_cpct then Impute_Race1_(i)="Asian";
	else if pop_hisp_asian_cpct<r then Impute_Race1_(i)="Other";
end;
keep geography household_id Impute_Race1_:;
run;

/*End of program*/
