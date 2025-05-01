/*********************************************************************************************/
/***PROGRAM: Macro3-CODI_APQ_GEO3.SAS									 				   ***/
/***VERSION: 1.0																		   ***/
/***AUTHOR: DEVI CHELLURI (NORC at the University of Chicago)		 			    ***/
/*********************************************************************************************/
%macro Suppress(fileinest= /*output file with prevelance estimates*/, fileinwgt= /*final weighted file*/, fileout= /*suppression algorithm output*/);
	data est;
		set &fileinest.;
	run;

	data raw_occur;
		set &fileinwgt.;

		array wgt_flg 5 UndrWgt_Flg HlthyWgt_Flg OvrWgt_Flg ObstyC123_Flg ObstyC1_Flg ObstyC2_Flg ObstyC3_Flg;
			do i=1 to 5;
				if wgt_flg[i]=0 then wgt_flg[i]=2;
			end;
	run;

	proc sort data=raw_occur;
		by co_occurring;
	run;

	proc freq data=raw_occur;
		table UndrWgt_Flg HlthyWgt_Flg OvrWgt_Flg ObstyC123_Flg ObstyC1_Flg ObstyC2_Flg ObstyC3_Flg;
		by co_occurring;
	run;

	%macro asecalc(var=);
		%Do j=1 %To 3;
			proc freq data=raw_occur;
				table &var./list missing binomial;
					where co_occurring=&j.;
					exact binomial;
					output out=&var.&j. Binomial;
			run;
		%end;
	%mend;

	%asecalc(var=UndrWgt_Flg);
	%asecalc(var=HlthyWgt_Flg);
	%asecalc(var=OvrWgt_Flg);
	%asecalc(var=ObstyC123_Flg);
	%asecalc(var=ObstyC1_Flg);
	%asecalc(var=ObstyC2_Flg);
	%asecalc(var=ObstyC3_Flg);

	%macro asefile();
		%Do j=1 %To 3;
		
			data ASE_file&j. (rename=(e_bin=ASE));
				length wtcat $50.;
				set UndrWgt_Flg&j. (in=a) HlthyWgt_Flg&j. (in=b) OvrWgt_Flg&j. (in=c) ObstyC123_Flg&j. (in=d) ObstyC1_Flg&j. (in=e) ObstyC2_Flg&j. (in=f) ObstyC3_Flg&j. (in=g);

				if a then
					WtCat="(1) Underweight (BMI<18.5)";

				else if b then
					WtCat="(2) Healthy Weight (18.5<=BMI<25)";

				else if c then
					WtCat="(3) Overweight (25<=BMI<30)";

				else if d then
					WtCat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";

				else if e then
					WtCat="(4a) Obesity (Class 1) (30<=BMI<35)";

				else if f then
					WtCat="(4b) Obesity (Class 2) (35<=BMI<40)";

				else if g then
					WtCat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";

				co_occurring=&j.;
				keep e_bin wtcat co_occurring;
			run;

			%if &j=1 %then %do;
				data ASE_file;
					set ASE_file&j.;
				run;
			%end;
			%else %do;
				data ASE_file;
					set ASE_file ASE_file&j.;
				run;
			%end;
		%end;
	%mend;

	%asefile();

	proc sort data=est;
		by wtcat co_occurring;
	run;

	proc sort data=ASE_file;
		by wtcat co_occurring;
	run;

	data est_ase;
		merge est ASE_file;
		by wtcat co_occurring;
	run;

	data  f1;
		set est_ase;

		/*p and its standard error should be decimal numbers between 0 and 1 ***/
		p=Crude_Prev/100;
		sep=ase;
		q=1-p;
		nsum=sample_pt;

		/* set df to sample(nsum) - 1 ***/
		df_flag=0;
		df=nsum-1;
		/*df=&dfin.;*/

		if df<8 then
			df_flag=1;

		/*Effective sample size: compute n effective ***/
		/*@note: for proportions from vital data files where SE=(p*q)/N, n_eff will equal to N ***/
		if (0<p<1) then n_eff=(p*(1-p))/(sep**2);
			else n_eff=nsum;

		if (n_eff=. or n_eff>nsum) then n_eff=nsum;

		/*Ratio of ts: adjustment to sample size suggested by Korn and Graubard for complex survey data ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equation below: 1-0.025 = 0.975 ***/
		if df > 0 then rat_squ=(tinv(0.975,nsum-1)/tinv(0.975,df))**2;
			else rat_squ=0;

		/*limit case: set to zero, df-adjusted effective sample size (can be no greater than the sample size) ***/
		if p > 0 then n_eff_df=min(nsum,rat_squ*n_eff);
			else n_eff_df=nsum;

		/*limit case: set to sample size, Parameters for beta confidence limits ***/
		x=n_eff_df*p;
		v1=x;
		if (n_eff_df-x+1)<0 then v2=0;
			else v2=n_eff_df-x;
		v3=x+1;
		if (n_eff_df-x)<0 then v4=0;
			else v4=n_eff_df-x;

		/*lower and upper confidence limits for Korn and Graubard interval ***/
		/*Note: Using inverse beta instead of ratio of Fs for numerical efficiency ***/
		/*if (0<p<1), otherwise set lower limit to 0 when p=0 and upper limit to 1 when p=1 ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equations below: 0.025 and 0.975 ***/
		if (v1=0) then kg_l=0;
			else kg_l=betainv(.025,v1,v2);

		if (v4=0) then kg_u=1;
			else kg_u=betainv(.975,v3,v4);

		/*Korn and Graubard CI absolute width ***/
		kg_wdth=kg_u - kg_l;

		/*Korn and Graubard CI relative width for p ***/
		if (p>0) then kg_relw_p=100*(kg_wdth/p);
			else kg_relw_p=.;

		/*Korn and Graubard CI relative width for q ***/
		if (q>0) then kg_relw_q=100*(kg_wdth/q);
			else kg_relw_q=.;

		/*Proportions with CI width <= 0.05 are reliable, unless ***/
		p_reliable=1;

		/*Update P Reliable: Effective sample size is less than 30 ***/
		if n_eff < 30 or nsum < 30 then p_reliable=0;

			/*Absolute CI width is greater than or equal 0.30 ***/
			else if kg_wdth ge 0.30 then p_reliable=0;

			/*Relative CI width is greater than 130% ***/
			else if (kg_relw_p > 130 and kg_wdth > 0.05) then p_reliable=0;

		/*Determine if estimate should be flagged as having an unreliable complement ***/
		if (p_reliable=1) then do;
			/*Complementary proportions are reliable, unless ***/
			q_reliable=1;

			/*Relative CI width is greater than 130% ***/
			if (kg_relw_q > 130 and kg_wdth > 0.05) then q_reliable=0;
		end;

		p_statistical=0;

		if p_reliable=1 then do;
			/*Estimates with df < 8 or percents = 0 or 100 or unreliable complement are flagged for clerical or ADS review ***/
			if df_flag=1 or p=0 or p=1 or q_reliable=0 then p_statistical =1;
		end;

	run;

	proc freq data=f1;
		table p_reliable*q_reliable*p_statistical/list missing;
			run;

	%Global Suppress_Error;
	%Let Suppress_Error=None;
	data &fileout.(keep=wtcat co_occurring co_occurring_label sample_pt pop_n Pop_n_age_adj crude_prev crude_stderr pop_perc std_err pop_perc_age_adj std_err_age_adj);
		set f1;

		if p_reliable=0 or q_reliable in (.,0) or p_statistical=1 then do;
			sample_pt=.;
			pop_n=.;
			Pop_n_age_adj=.;
			crude_prev=.;
			crude_stderr=.;
			pop_perc=.;
			std_err=.;
			pop_perc_age_adj=.;
			std_err_age_adj=.;
			call symput("Suppress_Error","One or more rows has suppressed results. Percentages are not available for all results due to suppression constraints.");
		end;
	run;
%mend;

%macro Suppress_cond(fileinest= /*output file with prevelance estimates*/, fileinwgt= /*final weighted file*/, fileout= /*suppression algorithm output*/, subset=);
	data est_occur_&subset.;
		set &fileinest.;
	run;

	data raw_occur_&subset.;
		set &fileinwgt.;

		array cooccur 3 cooccur1 cooccur2 cooccur3;
			do i=1 to 3;
				if cooccur[i]=0 then cooccur[i]=2;
			end;
	run;

	proc sort data=raw_occur_&subset.;
		by co_occurring;
	run;

	proc freq data=raw_occur_&subset.;
		table cooccur1 cooccur2 cooccur3;
	run;

	%macro asecalc(var=);
		proc freq data=raw_occur_&subset.;
			table &var./list missing binomial;
				exact binomial;
				output out=&var._&subset. Binomial;
			run;
	%mend;

	%asecalc(var=cooccur1);
	%asecalc(var=cooccur2);
	%asecalc(var=cooccur3);
		
	data ASE_file_occur_&subset. (rename=(e_bin=ASE));
		length co_occurring_label $50.;
		set cooccur1_&subset. (in=a) cooccur2_&subset. (in=b) cooccur3_&subset. (in=c);

		if c then
			co_occurring_label="(1) No Evidence";

		else if a then
			co_occurring_label="(2) Prediabetes";

		else if b then
			co_occurring_label="(3) Diabetes";
		keep e_bin co_occurring_label;
	run;

	proc sort data=est_occur_&subset.;
		by co_occurring_label;
	run;

	proc sort data=ASE_file_occur_&subset.;
		by co_occurring_label;
	run;

	data est_ase_occur_&subset.;
		merge est_occur_&subset. ASE_file_occur_&subset.;
		by co_occurring_label;
	run;

	data  f1_occur_&subset.;
		set est_ase_occur_&subset.;

		/*p and its standard error should be decimal numbers between 0 and 1 ***/
		p=Crude_Prev/100;
		sep=ase;
		q=1-p;
		nsum=sample_pt;

		/* set df to sample(nsum) - 1 ***/
		df_flag=0;
		df=nsum-1;
		/*df=&dfin.;*/

		if df<8 then
			df_flag=1;

		/*Effective sample size: compute n effective ***/
		/*@note: for proportions from vital data files where SE=(p*q)/N, n_eff will equal to N ***/
		if (0<p<1) then n_eff=(p*(1-p))/(sep**2);
			else n_eff=nsum;

		if (n_eff=. or n_eff>nsum) then n_eff=nsum;

		/*Ratio of ts: adjustment to sample size suggested by Korn and Graubard for complex survey data ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equation below: 1-0.025 = 0.975 ***/
		if df > 0 then rat_squ=(tinv(0.975,nsum-1)/tinv(0.975,df))**2;
			else rat_squ=0;

		/*limit case: set to zero, df-adjusted effective sample size (can be no greater than the sample size) ***/
		if p > 0 then n_eff_df=min(nsum,rat_squ*n_eff);
			else n_eff_df=nsum;

		/*limit case: set to sample size, Parameters for beta confidence limits ***/
		x=n_eff_df*p;
		v1=x;
		if (n_eff_df-x+1)<0 then v2=0;
			else v2=n_eff_df-x;
		v3=x+1;
		if (n_eff_df-x)<0 then v4=0;
			else v4=n_eff_df-x;

		/*lower and upper confidence limits for Korn and Graubard interval ***/
		/*Note: Using inverse beta instead of ratio of Fs for numerical efficiency ***/
		/*if (0<p<1), otherwise set lower limit to 0 when p=0 and upper limit to 1 when p=1 ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equations below: 0.025 and 0.975 ***/
		if (v1=0) then kg_l=0;
			else kg_l=betainv(.025,v1,v2);

		if (v4=0) then kg_u=1;
			else kg_u=betainv(.975,v3,v4);

		/*Korn and Graubard CI absolute width ***/
		kg_wdth=kg_u - kg_l;

		/*Korn and Graubard CI relative width for p ***/
		if (p>0) then kg_relw_p=100*(kg_wdth/p);
			else kg_relw_p=.;

		/*Korn and Graubard CI relative width for q ***/
		if (q>0) then kg_relw_q=100*(kg_wdth/q);
			else kg_relw_q=.;

		/*Proportions with CI width <= 0.05 are reliable, unless ***/
		p_reliable=1;

		/*Update P Reliable: Effective sample size is less than 30 ***/
		if n_eff < 30 or nsum < 30 then p_reliable=0;

			/*Absolute CI width is greater than or equal 0.30 ***/
			else if kg_wdth ge 0.30 then p_reliable=0;

			/*Relative CI width is greater than 130% ***/
			else if (kg_relw_p > 130 and kg_wdth > 0.05) then p_reliable=0;

		/*Determine if estimate should be flagged as having an unreliable complement ***/
		if (p_reliable=1) then do;
			/*Complementary proportions are reliable, unless ***/
			q_reliable=1;

			/*Relative CI width is greater than 130% ***/
			if (kg_relw_q > 130 and kg_wdth > 0.05) then q_reliable=0;
		end;

		p_statistical=0;

		if p_reliable=1 then do;
			/*Estimates with df < 8 or percents = 0 or 100 or unreliable complement are flagged for clerical or ADS review ***/
			if df_flag=1 or p=0 or p=1 or q_reliable=0 then p_statistical =1;
		end;

	run;

	proc freq data=f1_occur_&subset.;
		table p_reliable*q_reliable*p_statistical/list missing;
			run;

	%Global Suppress_Error_occur_&subset.;
	%Let Suppress_Error_occur_&subset.=None;
	data &fileout.(keep=co_occurring co_occurring_label sample_pt pop_n Pop_n_age_adj crude_prev crude_stderr pop_perc std_err pop_perc_age_adj std_err_age_adj);
		set f1_occur_&subset.;

		if p_reliable=0 or q_reliable in (.,0) or p_statistical=1 then do;
			sample_pt=.;
			pop_n=.;
			Pop_n_age_adj=.;
			crude_prev=.;
			crude_stderr=.;
			pop_perc=.;
			std_err=.;
			pop_perc_age_adj=.;
			std_err_age_adj=.;
			call symput("Suppress_Error_occur_&subset.","One or more rows has suppressed results. Percentages are not available for all results due to suppression constraints.");
		end;
	run;
%mend;

%macro Suppress_wgt(fileinest= /*output file with prevelance estimates*/, fileinwgt= /*final weighted file*/, fileout= /*suppression algorithm output*/);
	data est_wgt;
		set &fileinest.;
	run;

	data raw_wgt;
		set &fileinwgt.;

		array wgt_flg 5 UndrWgt_Flg HlthyWgt_Flg OvrWgt_Flg ObstyC123_Flg ObstyC1_Flg ObstyC2_Flg ObstyC3_Flg;
			do i=1 to 5;
				if wgt_flg[i]=0 then wgt_flg[i]=2;
			end;
	run;

	proc freq data=raw_wgt;
		table UndrWgt_Flg HlthyWgt_Flg OvrWgt_Flg ObstyC123_Flg ObstyC1_Flg ObstyC2_Flg ObstyC3_Flg;
	run;

	%macro asecalc(var=);
		proc freq data=raw_wgt;
			table &var./list missing binomial;
				exact binomial;
				output out=&var._wgt Binomial;
		run;
	%mend;

	%asecalc(var=UndrWgt_Flg);
	%asecalc(var=HlthyWgt_Flg);
	%asecalc(var=OvrWgt_Flg);
	%asecalc(var=ObstyC123_Flg);
	%asecalc(var=ObstyC1_Flg);
	%asecalc(var=ObstyC2_Flg);
	%asecalc(var=ObstyC3_Flg);

	data ASE_file_wgt (rename=(e_bin=ASE));
		length wtcat $50.;
		set UndrWgt_Flg_wgt (in=a) HlthyWgt_Flg_wgt (in=b) OvrWgt_Flg_wgt (in=c) ObstyC123_Flg_wgt (in=d) ObstyC1_Flg_wgt (in=e) ObstyC2_Flg_wgt (in=f) ObstyC3_Flg_wgt (in=g);

		if a then
			WtCat="(1) Underweight (BMI<18.5)";

		else if b then
			WtCat="(2) Healthy Weight (18.5<=BMI<25)";

		else if c then
			WtCat="(3) Overweight (25<=BMI<30)";

		else if d then
			WtCat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";

		else if e then
			WtCat="(4a) Obesity (Class 1) (30<=BMI<35)";

		else if f then
			WtCat="(4b) Obesity (Class 2) (35<=BMI<40)";

		else if g then
			WtCat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
		keep e_bin wtcat;
	run;

	proc sort data=est_wgt;
		by wtcat;
	run;

	proc sort data=ASE_file_wgt;
		by wtcat;
	run;

	data est_ase_wgt;
		merge est_wgt ASE_file_wgt;
		by wtcat;
	run;

	data  f1_wgt;
		set est_ase_wgt;

		/*p and its standard error should be decimal numbers between 0 and 1 ***/
		p=Crude_Prev/100;
		sep=ase;
		q=1-p;
		nsum=sample_pt;

		/* set df to sample(nsum) - 1 ***/
		df_flag=0;
		df=nsum-1;
		/*df=&dfin.;*/

		if df<8 then
			df_flag=1;

		/*Effective sample size: compute n effective ***/
		/*@note: for proportions from vital data files where SE=(p*q)/N, n_eff will equal to N ***/
		if (0<p<1) then n_eff=(p*(1-p))/(sep**2);
			else n_eff=nsum;

		if (n_eff=. or n_eff>nsum) then n_eff=nsum;

		/*Ratio of ts: adjustment to sample size suggested by Korn and Graubard for complex survey data ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equation below: 1-0.025 = 0.975 ***/
		if df > 0 then rat_squ=(tinv(0.975,nsum-1)/tinv(0.975,df))**2;
			else rat_squ=0;

		/*limit case: set to zero, df-adjusted effective sample size (can be no greater than the sample size) ***/
		if p > 0 then n_eff_df=min(nsum,rat_squ*n_eff);
			else n_eff_df=nsum;

		/*limit case: set to sample size, Parameters for beta confidence limits ***/
		x=n_eff_df*p;
		v1=x;
		if (n_eff_df-x+1)<0 then v2=0;
			else v2=n_eff_df-x;
		v3=x+1;
		if (n_eff_df-x)<0 then v4=0;
			else v4=n_eff_df-x;

		/*lower and upper confidence limits for Korn and Graubard interval ***/
		/*Note: Using inverse beta instead of ratio of Fs for numerical efficiency ***/
		/*if (0<p<1), otherwise set lower limit to 0 when p=0 and upper limit to 1 when p=1 ***/
		/*A two-sided alpha (0.05/2 or 0.025) is used in the equations below: 0.025 and 0.975 ***/
		if (v1=0) then kg_l=0;
			else kg_l=betainv(.025,v1,v2);

		if (v4=0) then kg_u=1;
			else kg_u=betainv(.975,v3,v4);

		/*Korn and Graubard CI absolute width ***/
		kg_wdth=kg_u - kg_l;

		/*Korn and Graubard CI relative width for p ***/
		if (p>0) then kg_relw_p=100*(kg_wdth/p);
			else kg_relw_p=.;

		/*Korn and Graubard CI relative width for q ***/
		if (q>0) then kg_relw_q=100*(kg_wdth/q);
			else kg_relw_q=.;

		/*Proportions with CI width <= 0.05 are reliable, unless ***/
		p_reliable=1;

		/*Update P Reliable: Effective sample size is less than 30 ***/
		if n_eff < 30 or nsum < 30 then p_reliable=0;

			/*Absolute CI width is greater than or equal 0.30 ***/
			else if kg_wdth ge 0.30 then p_reliable=0;

			/*Relative CI width is greater than 130% ***/
			else if (kg_relw_p > 130 and kg_wdth > 0.05) then p_reliable=0;

		/*Determine if estimate should be flagged as having an unreliable complement ***/
		if (p_reliable=1) then do;
			/*Complementary proportions are reliable, unless ***/
			q_reliable=1;

			/*Relative CI width is greater than 130% ***/
			if (kg_relw_q > 130 and kg_wdth > 0.05) then q_reliable=0;
		end;

		p_statistical=0;

		if p_reliable=1 then do;
			/*Estimates with df < 8 or percents = 0 or 100 or unreliable complement are flagged for clerical or ADS review ***/
			if df_flag=1 or p=0 or p=1 or q_reliable=0 then p_statistical =1;
		end;

	run;

	proc freq data=f1_wgt;
		table p_reliable*q_reliable*p_statistical/list missing;
			run;

	%Global Suppress_Error_wgt;
	%Let Suppress_Error_wgt=None;
	data &fileout.(keep=wtcat sample_pt pop_n Pop_n_age_adj crude_prev crude_stderr pop_perc std_err pop_perc_age_adj std_err_age_adj);
		set f1_wgt;

		if p_reliable=0 or q_reliable in (.,0) or p_statistical=1 then do;
			sample_pt=.;
			pop_n=.;
			Pop_n_age_adj=.;
			crude_prev=.;
			crude_stderr=.;
			pop_perc=.;
			std_err=.;
			pop_perc_age_adj=.;
			std_err_age_adj=.;
			call symput("Suppress_Error_wgt","One or more rows has suppressed results. Percentages are not available for all results due to suppression constraints.");
		end;
	run;
%mend;