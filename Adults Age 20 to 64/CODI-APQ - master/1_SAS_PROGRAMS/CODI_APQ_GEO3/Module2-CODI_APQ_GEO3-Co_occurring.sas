/*******************************************************************************************/
/***PROGRAM: Module2-CODI_APQ_GEO3.SAS									 				 ***/
/***VERSION: 1.0																		 ***/
/***AUTHOR: SCOTT CAMPBELL (NORC at the University of Chicago)							 ***/
/***MODIFIED BY: DEVI CHELLURI (NORC at the University of Chicago)		 			    ***/
/*******************************************************************************************/
/*@Action: Use weighted USER file to produce prevalence estimates ***/
%Macro Est_Prevalence_WGTCOND(Infile, Outfile, Weight, AgeAdj);
	%Do j=1 %To 3;

		/*@Action: Estimate Crude Rates ***/
		Proc Means Data=&Infile. Noprint;
			Var UndrWgt_Flg;
			Where co_occurring=&j.;
			Output Out=UndrWgt_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var HlthyWgt_Flg;
			Where co_occurring=&j.;
			Output Out=HlthyWgt_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var OvrWgt_Flg;
			Where co_occurring=&j.;
			Output Out=OvrWgt_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var ObstyC123_Flg;
			Where co_occurring=&j.;
			Output Out=ObstyC123_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var ObstyC1_Flg;
			Where co_occurring=&j.;
			Output Out=ObstyC1_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var ObstyC2_Flg;
			Where co_occurring=&j.;
			Output Out=ObstyC2_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;
		Proc Means Data=&Infile. Noprint;
			Var ObstyC3_Flg;
			Where co_occurring=&j.;
			Output Out=ObstyC3_CoOccurCat&j._Crde Mean=Crude_Prev Stderr=Crude_StdErr;

		Data Crude_Prevalence_Estimates&j.(Keep=Wgt_Cat co_occurring Crude_Prev Crude_StdErr);
			Retain Wgt_Cat co_occurring Crude_Prev Crude_StdErr;
			Set UndrWgt_CoOccurCat&j._Crde(In=A) HlthyWgt_CoOccurCat&j._Crde(In=B) OvrWgt_CoOccurCat&j._Crde(In=C) ObstyC123_CoOccurCat&j._Crde(In=D) ObstyC1_CoOccurCat&j._Crde(In=E) ObstyC2_CoOccurCat&j._Crde(In=F) ObstyC3_CoOccurCat&j._Crde(In=G);
				Length Wgt_Cat co_occurring_label $50.;
				If A Then Wgt_Cat="(1) Underweight (BMI<18.5)";
					Else If B Then Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)";
					Else If C Then Wgt_Cat="(3) Overweight (25<=BMI<30)";
					Else If D  Then Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";
					Else If E  Then Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)";
					Else If F  Then Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)";
					Else If G  Then Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
				co_occurring=&j.;
				If co_occurring=1 then co_occurring_label="(2) Prediabetes";
					Else If co_occurring=2 then co_occurring_label="(3) Diabetes";
					Else If co_occurring=3 then co_occurring_label="(1) No Evidence";
		Run;

		%If &j.=1 %Then %Do;
			Data Crude_Prevalence_Estimates;
				Set Crude_Prevalence_Estimates&j.;
			Run;
		%End;
		%Else %Do;
			Data Crude_Prevalence_Estimates;
				Set Crude_Prevalence_Estimates Crude_Prevalence_Estimates&j.;
			Run;
		%End;
	%End;

	Proc Sql Noprint;
		Select Sum(&Weight.) into :Est_Pop From &Infile.;
	quit;

	proc sql;
		Create table Prevalence_Begin0 as
			Select Wgt_Cat, co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where Wgt_Cat^="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" and Wgt_Cat^="(4) Obesity (Class 1) (30<=BMI<35)" and Wgt_Cat^="(5) Obesity (Class 2) (35<=BMI<40)" and Wgt_Cat^="(6) Obesity (Class 3) - Severe Obesity (BMI>=40)"
						Group by Wgt_Cat, co_occurring
							Union
			Select "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Wgt_Cat, co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC123_Flg=1
						Group by co_occurring
							Union
			Select "(4a) Obesity (Class 1) (30<=BMI<35)" as Wgt_Cat, co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC1_Flg=1
						Group by co_occurring
							Union
			Select "(4b) Obesity (Class 2) (35<=BMI<40)" as Wgt_Cat, co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC2_Flg=1
						Group by co_occurring
							Union
			Select "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Wgt_Cat, co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC3_Flg=1
						Group by co_occurring
							Order by Wgt_Cat, co_occurring;
	Quit;

	proc sort data=Prevalence_Begin_shell;
		by wgt_cat co_occurring;
	run;

	data Prevalence_Begin;
		merge Prevalence_Begin_shell Prevalence_Begin0;
			by Wgt_Cat co_occurring;
			array change _numeric_;
				do over change;
					if change=. then change=0;
				end;
	run;

	%Do j=1 %To 3;

		/*@Action: Estimate the variance for prevalence estimates ***/
		Data _NULL_;
			Set Prevalence_Begin;
					If Wgt_Cat="(1) Underweight (BMI<18.5)" and co_occurring=&j. Then Call symput("UW_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)" and co_occurring=&j. Then Call symput("HW_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(3) Overweight (25<=BMI<30)" and co_occurring=&j. Then Call symput("OW_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" and co_occurring=&j. Then Call symput("OBC123_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)" and co_occurring=&j. Then Call symput("OBC1_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)" and co_occurring=&j. Then Call symput("OBC2_CoOccurCat_Prev", Max(Est_Prev, .));
						Else If Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" and co_occurring=&j. Then Call symput("OBC3_CoOccurCat_Prev", Max(Est_Prev, .));
		Run;

		Data USER_W_Prevalence&j.;
			Set &Infile.;
				Where  co_occurring=&j. ;
				/*@Action: Compute variables needed for variance esimation for each prevalence estimate ***/
					If Wgt_Cat="(1) Underweight (BMI<18.5)" Then Z_UnderWeight_CoOccurCat=(&Weight.*(1-&UW_CoOccurCat_Prev.))/&Est_Pop.;
						Else Z_UnderWeight_CoOccurCat=(&Weight.*(0-&UW_CoOccurCat_Prev.))/&Est_Pop.; 
					If Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)" Then Z_HealthyWeight_CoOccurCat=(&Weight.*(1-&HW_CoOccurCat_Prev.))/&Est_Pop.;
						Else Z_HealthyWeight_CoOccurCat=(&Weight.*(0-&HW_CoOccurCat_Prev.))/&Est_Pop.;
					If Wgt_Cat="(3) Overweight (25<=BMI<30)" Then Z_OverWeight_CoOccurCat=(&Weight.*(1-&OW_CoOccurCat_Prev.))/&Est_Pop.;
						Else Z_OverWeight_CoOccurCat=(&Weight.*(0-&OW_CoOccurCat_Prev.))/&Est_Pop.;
					If Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" Then Z_ObeseC123_CoOccurCat=(&Weight.*(1-&OBC123_CoOccurCat_Prev.))/&Est_Pop.;
							Else Z_ObeseC123_CoOccurCat=(&Weight.*(0-&OBC123_CoOccurCat_Prev.))/&Est_Pop.;
					If Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)" Then Z_ObeseC1_CoOccurCat=(&Weight.*(1-&OBC1_CoOccurCat_Prev.))/&Est_Pop.;
							Else Z_ObeseC1_CoOccurCat=(&Weight.*(0-&OBC1_CoOccurCat_Prev.))/&Est_Pop.;
					If Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)" Then Z_ObeseC2_CoOccurCat=(&Weight.*(1-&OBC2_CoOccurCat_Prev.))/&Est_Pop.;
							Else Z_ObeseC2_CoOccurCat=(&Weight.*(0-&OBC2_CoOccurCat_Prev.))/&Est_Pop.;
					If Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" Then Z_ObeseC3_CoOccurCat=(&Weight.*(1-&OBC3_CoOccurCat_Prev.))/&Est_Pop.;
							Else Z_ObeseC3_CoOccurCat=(&Weight.*(0-&OBC3_CoOccurCat_Prev.))/&Est_Pop.;

		Proc Sort Data=USER_W_Prevalence&j.;
			By Geography co_occurring;
				Run;

		Proc Sql;
			Create table USER_Z_Means&j. as
				Select Geography, co_occurring, Avg(Z_UnderWeight_CoOccurCat) as Avg_Z_UnderWeight_CoOccurCat, Avg(Z_HealthyWeight_CoOccurCat) as Avg_Z_HealthyWeight_CoOccurCat, 
					Avg(Z_OverWeight_CoOccurCat) as Avg_Z_OverWeight_CoOccurCat, Avg(Z_ObeseC123_CoOccurCat) as Avg_Z_ObeseC123_CoOccurCat, 
					Avg(Z_ObeseC1_CoOccurCat) as Avg_Z_ObeseC1_CoOccurCat, Avg(Z_ObeseC2_CoOccurCat) as Avg_Z_ObeseC2_CoOccurCat, Avg(Z_ObeseC3_CoOccurCat) as Avg_Z_ObeseC3_CoOccurCat
						From USER_W_Prevalence&j.
							Group by Geography, co_occurring;
		quit;

		Data USER_W_Prevalence&j.;
			Merge USER_W_Prevalence&j. USER_Z_Means&j.;
				By Geography co_occurring;
					SqDiff_UnderWeight_CoOccurCat	 = (Z_UnderWeight_CoOccurCat-Avg_Z_UnderWeight_CoOccurCat)**2;
					SqDiff_HealthyWeight_CoOccurCat = (Z_HealthyWeight_CoOccurCat-Avg_Z_HealthyWeight_CoOccurCat)**2;
					SqDiff_OverWeight_CoOccurCat	 = (Z_OverWeight_CoOccurCat-Avg_Z_OverWeight_CoOccurCat)**2;
					SqDiff_ObeseC123_CoOccurCat 	 = (Z_ObeseC123_CoOccurCat-Avg_Z_ObeseC123_CoOccurCat)**2;
					SqDiff_ObeseC1_CoOccurCat 		 = (Z_ObeseC1_CoOccurCat-Avg_Z_ObeseC1_CoOccurCat)**2;
					SqDiff_ObeseC2_CoOccurCat 		 = (Z_ObeseC2_CoOccurCat-Avg_Z_ObeseC2_CoOccurCat)**2;
					SqDiff_ObeseC3_CoOccurCat 	 	 = (Z_ObeseC3_CoOccurCat-Avg_Z_ObeseC3_CoOccurCat)**2;
		Run;

		Proc Sql;
			Create table USER_Prev_Variance&j. as
				Select Geography, co_occurring, (Count(*)/(Count(*)-1)) as Strata_Adj,
					Calculated Strata_Adj*Sum(SqDiff_UnderWeight_CoOccurCat) as UnderWeight_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_HealthyWeight_CoOccurCat) as HealthyWeight_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_OverWeight_CoOccurCat) as OverWeight_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_ObeseC123_CoOccurCat) as ObeseC123_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_ObeseC1_CoOccurCat) as ObeseC1_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_ObeseC2_CoOccurCat) as ObeseC2_CoOccurCat,
					Calculated Strata_Adj*Sum(SqDiff_ObeseC3_CoOccurCat) as ObeseC3_CoOccurCat
						From USER_W_Prevalence&j.
							Group by Geography, co_occurring;
		Quit;

		Proc Sql;
			Create table Variance_Estimates&j. as
				Select "(1) Underweight (BMI<18.5)" as Wgt_Cat, co_occurring, Sum(UnderWeight_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(2) Healthy Weight (18.5<=BMI<25)" as Wgt_Cat, co_occurring, Sum(HealthyWeight_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(3) Overweight (25<=BMI<30)" as Wgt_Cat, co_occurring, Sum(OverWeight_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Wgt_Cat, co_occurring, Sum(ObeseC123_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(4a) Obesity (Class 1) (30<=BMI<35)" as Wgt_Cat, co_occurring, Sum(ObeseC1_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(4b) Obesity (Class 2) (35<=BMI<40)" as Wgt_Cat, co_occurring, Sum(ObeseC2_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring union
				Select "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Wgt_Cat, co_occurring, Sum(ObeseC3_CoOccurCat) as Var_Est From USER_Prev_Variance&j. Group by co_occurring;
		Quit;

		%If &j.=1 %Then %Do;
			Data Variance_Estimates;
				Set Variance_Estimates&j.;
			Run;
		%End;
		%Else %Do;
			Data Variance_Estimates;
				Set Variance_Estimates Variance_Estimates&j.;
			Run;
		%End;
	%End;

	Proc Sql;
		%If &AgeAdj.=Y %Then %Do;
			Create table &Outfile. as
				Select a.Wgt_Cat as WtCat, a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label,
					a.Est_Pop_Cnt as Pop_n_age_adj, a.Est_Prev*100 as pop_perc_age_adj, Sqrt(b.Var_Est)*100 as std_err_age_adj
						From Prevalence_Begin as a
							left join Variance_Estimates as b
								on a.Wgt_Cat=b.Wgt_Cat and a.co_occurring=b.co_occurring
									order by WtCat, co_occurring;
		%End;
		%Else %Do;
			Create table &Outfile. as
				Select a.Wgt_Cat as WtCat, a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label,
					a.Sample_Cnt as Sample_PT, a.Est_Pop_Cnt as Pop_n,
					c.Crude_Prev*100 as Crude_Prev, c.Crude_StdErr*100 as Crude_StdErr,
					a.Est_Prev*100 as Pop_Perc, b.Var_Est, Sqrt(b.Var_Est)*100 as STD_Err
						From (Prevalence_Begin as a 
							left join Variance_Estimates as b
								on  a.Wgt_Cat=b.Wgt_Cat and a.co_occurring=b.co_occurring) 
							left join Crude_Prevalence_Estimates as c
								on a.Wgt_Cat=c.Wgt_Cat and a.co_occurring=c.co_occurring
							order by WtCat, co_occurring;
		%End;
			Quit;
%Mend;

%Macro Run_Est_Prevalence_WGTCOND;
	%Est_Prevalence_WGTCOND(Infile=Weighted_USER_File, Outfile=USER_Prev_Ests, Weight=RakeWgt, AgeAdj=);

	%If &AGE_ADJ.=Y %THEN %DO;
		%Est_Prevalence_WGTCOND(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ.);

		Data USER_Prev_Ests;
			Merge USER_Prev_Ests Age_Adj_Prev;
				By WtCat co_occurring;
					Run;
	%End;
%Mend;

%Run_Est_Prevalence_WGTCOND;

%Suppress(fileinest=USER_Prev_Ests, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp);

%Macro Est_Prevalence_WGT(Infile, Outfile, Weight, AgeAdj);
	/*@Action: Estimate Crude Rates ***/
	Proc Means Data=&Infile. Noprint;
		Var UndrWgt_Flg;
		Output Out=UndrWgt_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var HlthyWgt_Flg;
		Output Out=HlthyWgt_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var OvrWgt_Flg;
		Output Out=OvrWgt_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var ObstyC123_Flg;
		Output Out=ObstyC123_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var ObstyC1_Flg;
		Output Out=ObstyC1_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var ObstyC2_Flg;
		Output Out=ObstyC2_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var ObstyC3_Flg;
		Output Out=ObstyC3_Crde_wgt Mean=Crude_Prev Stderr=Crude_StdErr;
	Run;

	Data Crude_Prevalence_Estimates_wgt(Keep=Wgt_Cat Crude_Prev Crude_StdErr);
		Retain Wgt_Cat Crude_Prev Crude_StdErr;
		Set UndrWgt_Crde_wgt(In=A) HlthyWgt_Crde_wgt(In=B) OvrWgt_Crde_wgt(In=C) ObstyC123_Crde_wgt(In=D) ObstyC1_Crde_wgt(In=E) ObstyC2_Crde_wgt(In=F) ObstyC3_Crde_wgt(In=G);
			Length Wgt_Cat $50.;
			If A Then Wgt_Cat="(1) Underweight (BMI<18.5)";
				Else If B Then Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)";
				Else If C Then Wgt_Cat="(3) Overweight (25<=BMI<30)";
				Else If D Then Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)";
				Else If E Then Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)";
				Else If F Then Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)";
				Else If G Then Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)";
	Run;

	Proc Sql Noprint;
		Select Sum(&Weight.) into :Est_Pop From &Infile.;

	proc sql;
		Create table Prevalence_Begin_wgt0 as
			Select Wgt_Cat, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where Wgt_Cat^="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" and Wgt_Cat^="(4) Obesity (Class 1) (30<=BMI<35)" and Wgt_Cat^="(5) Obesity (Class 2) (35<=BMI<40)" and Wgt_Cat^="(6) Obesity (Class 3) - Severe Obesity (BMI>=40)"
						Group by Wgt_Cat
							Union
			Select "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Wgt_Cat, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC123_Flg=1
							Union
			Select "(4a) Obesity (Class 1) (30<=BMI<35)" as Wgt_Cat, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC1_Flg=1
							Union
			Select "(4b) Obesity (Class 2) (35<=BMI<40)" as Wgt_Cat, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC2_Flg=1
							Union
			Select "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Wgt_Cat, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Where ObstyC3_Flg=1
						Order by Wgt_Cat;
	Quit;

	proc sql;
		create table Prevalence_Begin_shell_wgt as 
			select distinct wgt_cat
				, Sample_Cnt
				, Est_Pop_Cnt
				, Est_Prev	
			from Prevalence_Begin_shell;
	quit;

	proc sort data=Prevalence_Begin_shell_wgt;
		by wgt_cat;
	run;

	data Prevalence_Begin_wgt;
		merge Prevalence_Begin_shell_wgt Prevalence_Begin_wgt0;
			by Wgt_Cat;
			array change _numeric_;
				do over change;
					if change=. then change=0;
				end;
	run;

	/*@Action: Estimate the variance for prevalence estimates ***/
	Data _NULL_;
		Set Prevalence_Begin_wgt;
			If Wgt_Cat="(1) Underweight (BMI<18.5)" Then Call symput("UW_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)" Then Call symput("HW_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(3) Overweight (25<=BMI<30)" Then Call symput("OW_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" Then Call symput("OBC123_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)" Then Call symput("OBC1_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)" Then Call symput("OBC2_Prev", Max(Est_Prev, .));
				Else If Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" Then Call symput("OBC3_Prev", Max(Est_Prev, .));
	Data USER_W_Prevalence_wgt;
		Set &Infile.;
			/*@Action: Compute variables needed for variance esimation for each prevalence estimate ***/
			If Wgt_Cat="(1) Underweight (BMI<18.5)" Then Z_UnderWeight=(&Weight.*(1-&UW_Prev.))/&Est_Pop.;
				Else Z_UnderWeight=(&Weight.*(0-&UW_Prev.))/&Est_Pop.;
			If Wgt_Cat="(2) Healthy Weight (18.5<=BMI<25)" Then Z_HealthyWeight=(&Weight.*(1-&HW_Prev.))/&Est_Pop.;
				Else Z_HealthyWeight=(&Weight.*(0-&HW_Prev.))/&Est_Pop.;
			If Wgt_Cat="(3) Overweight (25<=BMI<30)" Then Z_OverWeight=(&Weight.*(1-&OW_Prev.))/&Est_Pop.;
				Else Z_OverWeight=(&Weight.*(0-&OW_Prev.))/&Est_Pop.;
			If Wgt_Cat="(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" Then Z_ObeseC123=(&Weight.*(1-&OBC123_Prev.))/&Est_Pop.;
					Else Z_ObeseC123=(&Weight.*(0-&OBC123_Prev.))/&Est_Pop.;
			If Wgt_Cat="(4a) Obesity (Class 1) (30<=BMI<35)" Then Z_ObeseC1=(&Weight.*(1-&OBC1_Prev.))/&Est_Pop.;
					Else Z_ObeseC1=(&Weight.*(0-&OBC1_Prev.))/&Est_Pop.;
			If Wgt_Cat="(4b) Obesity (Class 2) (35<=BMI<40)" Then Z_ObeseC2=(&Weight.*(1-&OBC2_Prev.))/&Est_Pop.;
					Else Z_ObeseC2=(&Weight.*(0-&OBC2_Prev.))/&Est_Pop.;
			If Wgt_Cat="(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" Then Z_ObeseC3=(&Weight.*(1-&OBC3_Prev.))/&Est_Pop.;
					Else Z_ObeseC3=(&Weight.*(0-&OBC3_Prev.))/&Est_Pop.;
	Proc Sort Data=USER_W_Prevalence_wgt;
		By Geography;
			Run;

	Proc Sql;
		Create table USER_Z_Means_wgt as
			Select Geography, Avg(Z_UnderWeight) as Avg_Z_UnderWeight, Avg(Z_HealthyWeight) as Avg_Z_HealthyWeight, 
				Avg(Z_OverWeight) as Avg_Z_OverWeight, Avg(Z_ObeseC123) as Avg_Z_ObeseC123, 
				Avg(Z_ObeseC1) as Avg_Z_ObeseC1, Avg(Z_ObeseC2) as Avg_Z_ObeseC2, Avg(Z_ObeseC3) as Avg_Z_ObeseC3
					From USER_W_Prevalence_wgt
						Group by Geography;
	quit;

	Data USER_W_Prevalence_wgt;
		Merge USER_W_Prevalence_wgt USER_Z_Means_wgt;
			By Geography;
				SqDiff_UnderWeight	 = (Z_UnderWeight-Avg_Z_UnderWeight)**2;
				SqDiff_HealthyWeight = (Z_HealthyWeight-Avg_Z_HealthyWeight)**2;
				SqDiff_OverWeight	 = (Z_OverWeight-Avg_Z_OverWeight)**2;
				SqDiff_ObeseC123 	 = (Z_ObeseC123-Avg_Z_ObeseC123)**2;
				SqDiff_ObeseC1 	 	 = (Z_ObeseC1-Avg_Z_ObeseC1)**2;
				SqDiff_ObeseC2 	 	 = (Z_ObeseC2-Avg_Z_ObeseC2)**2;
				SqDiff_ObeseC3 		 = (Z_ObeseC3-Avg_Z_ObeseC3)**2;
	Run;

	Proc Sql;
		Create table USER_Prev_Variance_wgt as
			Select Geography, (Count(*)/(Count(*)-1)) as Strata_Adj,
				Calculated Strata_Adj*Sum(SqDiff_UnderWeight) as UnderWeight,
				Calculated Strata_Adj*Sum(SqDiff_HealthyWeight) as HealthyWeight,
				Calculated Strata_Adj*Sum(SqDiff_OverWeight) as OverWeight,
				Calculated Strata_Adj*Sum(SqDiff_ObeseC123) as ObeseC123,
				Calculated Strata_Adj*Sum(SqDiff_ObeseC1) as ObeseC1,
				Calculated Strata_Adj*Sum(SqDiff_ObeseC2) as ObeseC2,
				Calculated Strata_Adj*Sum(SqDiff_ObeseC3) as ObeseC3
					From USER_W_Prevalence_wgt
						Group by Geography;

		Create table Variance_Estimates_wgt as
			Select "(1) Underweight (BMI<18.5)" as Wgt_Cat, Sum(UnderWeight) as Var_Est From USER_Prev_Variance_wgt union
			Select "(2) Healthy Weight (18.5<=BMI<25)" as Wgt_Cat, Sum(HealthyWeight) as Var_Est From USER_Prev_Variance_wgt union
			Select "(3) Overweight (25<=BMI<30)" as Wgt_Cat, Sum(OverWeight) as Var_Est From USER_Prev_Variance_wgt union
			Select "(4) Obesity (Classes 1, 2, and 3) (BMI 30+)" as Wgt_Cat, Sum(ObeseC123) as Var_Est From USER_Prev_Variance_wgt union
			Select "(4a) Obesity (Class 1) (30<=BMI<35)" as Wgt_Cat, Sum(ObeseC1) as Var_Est From USER_Prev_Variance_wgt union
			Select "(4b) Obesity (Class 2) (35<=BMI<40)" as Wgt_Cat, Sum(ObeseC2) as Var_Est From USER_Prev_Variance_wgt union
			Select "(4c) Obesity (Class 3) - Severe Obesity (BMI 40+)" as Wgt_Cat, Sum(ObeseC3) as Var_Est From USER_Prev_Variance_wgt;

		%If &AgeAdj.=Y %Then %Do;
			Create table &Outfile. as
				Select a.Wgt_Cat as WtCat, a.Est_Pop_Cnt as Pop_n_age_adj, a.Est_Prev*100 as pop_perc_age_adj, Sqrt(b.Var_Est)*100 as std_err_age_adj
						From Prevalence_Begin_wgt as a, Variance_Estimates_wgt as b
							where a.Wgt_Cat=b.Wgt_Cat
								order by WtCat;
		%End;
		%Else %Do;
			Create table &Outfile. as
				Select a.Wgt_Cat as WtCat, a.Sample_Cnt as Sample_PT, a.Est_Pop_Cnt as Pop_n,
					c.Crude_Prev*100 as Crude_Prev, c.Crude_StdErr*100 as Crude_StdErr,
					a.Est_Prev*100 as Pop_Perc, b.Var_Est, Sqrt(b.Var_Est)*100 as STD_Err
						From Prevalence_Begin_wgt as a, Variance_Estimates_wgt as b, Crude_Prevalence_Estimates_wgt as c
							where a.Wgt_Cat=b.Wgt_Cat and a.Wgt_Cat=c.Wgt_Cat
								order by WtCat;
		%End;
			Quit;
%Mend;

%Macro Run_Est_Prevalence_WGT;
	%Est_Prevalence_WGT(Infile=Weighted_USER_File, Outfile=USER_Prev_Ests_wgt, Weight=RakeWgt, AgeAdj=);

	%If &AGE_ADJ.=Y %THEN %DO;
		%Est_Prevalence_WGT(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_wgt, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ.);

		Data USER_Prev_Ests_wgt;
			Merge USER_Prev_Ests_wgt Age_Adj_Prev_wgt;
				By WtCat;
						Run;
	%End;
%Mend;

%Run_Est_Prevalence_WGT;

%Suppress_wgt(fileinest=USER_Prev_Ests_wgt, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_wgt);

/*@Action: Use weighted USER file to produce prevalence estimates for co-occuring condition***/
%Macro Est_Prevalence_COND(Infile, Outfile, Weight, AgeAdj);
	/*@Action: Estimate Crude Rates ***/
	Proc Means Data=&Infile. Noprint;
		Var cooccur1;
		Output Out=CoOccurCat1_Crde Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var cooccur2;
		Output Out=CoOccurCat2_Crde Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var cooccur3;
		Output Out=CoOccurCat3_Crde Mean=Crude_Prev Stderr=Crude_StdErr;

	Data Crude_Prev_Est_cooccur (Keep=co_occurring Crude_Prev Crude_StdErr);
		Retain co_occurring Crude_Prev Crude_StdErr;
		Set CoOccurCat1_Crde (in=a) CoOccurCat2_Crde (in=b) CoOccurCat3_Crde (in=c);
		Length co_occurring_label $50.;
		If a then co_occurring=1;
			Else If b then co_occurring=2;
			Else If c then co_occurring=3;
		If c then co_occurring_label="(1) No Evidence";
			Else If a then co_occurring_label="(2) Prediabetes";
			Else If b then co_occurring_label="(3) Diabetes";
	Run;

	Proc Sql Noprint;
		Select Sum(&Weight.) into :Est_Pop From &Infile.;

		Create table Prevalence_Begin_cooccur0 as
			Select co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					Group by co_occurring
						Order by co_occurring;
	Quit;

	proc sql;
		create table Prevalence_Begin_shell_cooccur as 
			select distinct co_occurring
				, Sample_Cnt
				, Est_Pop_Cnt
				, Est_Prev	
			from Prevalence_Begin_shell;
	quit;

	proc sort data=Prevalence_Begin_shell_cooccur;
		by co_occurring;
	run;

	data Prevalence_Begin_cooccur;
		merge Prevalence_Begin_shell_cooccur Prevalence_Begin_cooccur0;
			by co_occurring;
			array change _numeric_;
				do over change;
					if change=. then change=0;
				end;
	run;

	/*@Action: Estimate the variance for prevalence estimates ***/
	Data _NULL_;
		Set Prevalence_Begin_cooccur;
			If co_occurring=3 Then Call symput("Noevid_Prev", Max(Est_Prev, .));
				Else If co_occurring=1Then Call symput("Prediab_Prev", Max(Est_Prev, .));
				Else If co_occurring=2 Then Call symput("Diab_Prev", Max(Est_Prev, .));
	Run;

	Data USER_W_Prevalence_cooccur;
		Set &Infile.;
			/*@Action: Compute variables needed for variance esimation for each prevalence estimate ***/
			If co_occurring=3 Then Z_NoEvidence=(&Weight.*(1-&Noevid_Prev.))/&Est_Pop.;
				Else Z_NoEvidence=(&Weight.*(0-&Noevid_Prev.))/&Est_Pop.;
			If co_occurring=1 Then Z_Prediabetes=(&Weight.*(1-&Prediab_Prev.))/&Est_Pop.;
				Else Z_Prediabetes=(&Weight.*(0-&Prediab_Prev.))/&Est_Pop.;
			If co_occurring=2 Then Z_Diabetes=(&Weight.*(1-&Diab_Prev.))/&Est_Pop.;
				Else Z_Diabetes=(&Weight.*(0-&Diab_Prev.))/&Est_Pop.;

		Proc Sort Data=USER_W_Prevalence_cooccur;
			By Geography;
				Run;

		Proc Sql;
			Create table USER_Z_Means_cooccur as
				Select Geography, Avg(Z_Prediabetes) as Avg_Z_Prediabetes, Avg(Z_Diabetes) as Avg_Z_Diabetes, Avg(Z_NoEvidence) as Avg_Z_NoEvidence
					From USER_W_Prevalence_cooccur
						Group by Geography;
		quit;

		Data USER_W_Prevalence_cooccur;
			Merge USER_W_Prevalence_cooccur USER_Z_Means_cooccur;
				By Geography;
					SqDiff_NoEvidence	 = (Z_NoEvidence-Avg_Z_NoEvidence)**2;
					SqDiff_Prediabetes	 = (Z_Prediabetes-Avg_Z_Prediabetes)**2;
					SqDiff_Diabetes = (Z_Diabetes-Avg_Z_Diabetes)**2;
		Run;

		Proc Sql;
			Create table USER_Prev_Variance_cooccur as
				Select Geography, (Count(*)/(Count(*)-1)) as Strata_Adj,
					Calculated Strata_Adj*Sum(SqDiff_NoEvidence) as NoEvidence,
					Calculated Strata_Adj*Sum(SqDiff_Prediabetes) as Prediabetes,
					Calculated Strata_Adj*Sum(SqDiff_Diabetes) as Diabetes
						From USER_W_Prevalence_cooccur
							Group by Geography;
		Quit;

		Proc Sql;
			Create table Variance_Estimates_cooccur as
				Select 3 as co_occurring, Sum(NoEvidence) as Var_Est From USER_Prev_Variance_cooccur union
				Select 1 as co_occurring, Sum(Prediabetes) as Var_Est From USER_Prev_Variance_cooccur union
				Select 2 as co_occurring, Sum(Diabetes) as Var_Est From USER_Prev_Variance_cooccur;
		Quit;

	Proc Sql;
		%If &AgeAdj.=Y %Then %Do;
			Create table &Outfile. as
				Select a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label, a.Est_Pop_Cnt as Pop_n_age_adj, a.Est_Prev*100 as pop_perc_age_adj, Sqrt(b.Var_Est)*100 as std_err_age_adj
						From Prevalence_Begin_cooccur as a, Variance_Estimates_cooccur as b
							where a.co_occurring=b.co_occurring
								order by co_occurring;
		%End;
		%Else %Do;
			Create table &Outfile. as
				Select a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label, a.Sample_Cnt as Sample_PT, a.Est_Pop_Cnt as Pop_n,
					c.Crude_Prev*100 as Crude_Prev, c.Crude_StdErr*100 as Crude_StdErr,
					a.Est_Prev*100 as Pop_Perc, b.Var_Est, Sqrt(b.Var_Est)*100 as STD_Err
						From Prevalence_Begin_cooccur as a, Variance_Estimates_cooccur as b, Crude_Prev_Est_cooccur as c
							where a.co_occurring=b.co_occurring and a.co_occurring=c.co_occurring
								order by co_occurring;
		%End;
			Quit;
%Mend;

%Macro Run_Est_Prevalence_COND;
	%Est_Prevalence_COND(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur, Weight=RakeWgt, AgeAdj=);

	%If &AGE_ADJ.=Y %THEN %DO;
		%Est_Prevalence_COND(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ.);

		Data USER_Prev_Est_CoOccur;
			Merge USER_Prev_Est_CoOccur Age_Adj_Prev_CoOccur;
				By co_occurring;
					Run;
	%End;
%Mend;

%Run_Est_Prevalence_COND;

%Suppress_cond(fileinest=USER_Prev_Est_CoOccur, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur, subset=all);

/*@Action: Use weighted USER file to produce prevalence estimates for co-occuring condition***/
%Macro Est_Prevalence_COND_bywgt(Infile, Outfile, Weight, AgeAdj, wtcatvar);
	/*@Action: Estimate Crude Rates ***/
	Proc Means Data=&Infile. Noprint;
		Var cooccur1;
		where &wtcatvar.=1;
		Output Out=CoOccurCat1_Crde Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var cooccur2;
		where &wtcatvar.=1;
		Output Out=CoOccurCat2_Crde Mean=Crude_Prev Stderr=Crude_StdErr;
	Proc Means Data=&Infile. Noprint;
		Var cooccur3;
		where &wtcatvar.=1;
		Output Out=CoOccurCat3_Crde Mean=Crude_Prev Stderr=Crude_StdErr;

	Data Crude_Prev_Est_bywgt (Keep=co_occurring Crude_Prev Crude_StdErr);
		Retain co_occurring Crude_Prev Crude_StdErr;
		Set CoOccurCat1_Crde (in=a) CoOccurCat2_Crde (in=b) CoOccurCat3_Crde (in=c);
		Length co_occurring_label $50.;
		If a then co_occurring=1;
			Else If b then co_occurring=2;
			Else If c then co_occurring=3;
		If c then co_occurring_label="(1) No Evidence";
			Else If a then co_occurring_label="(2) Prediabetes";
			Else If b then co_occurring_label="(3) Diabetes";
	Run;

	Proc Sql Noprint;
		Select Sum(&Weight.) into :Est_Pop From &Infile. where &wtcatvar.=1;

		Create table Prevalence_Begin_bywgt0 as
			Select co_occurring, Count(*) as Sample_Cnt, Sum(&Weight.) as Est_Pop_Cnt, (Calculated Est_Pop_Cnt/&Est_Pop.) as Est_Prev
				From &Infile.
					where &wtcatvar.=1
						Group by co_occurring
							Order by co_occurring;
	Quit;

	proc sql;
		create table Prevalence_Begin_shell_bywgt as 
			select distinct co_occurring
				, Sample_Cnt
				, Est_Pop_Cnt
				, Est_Prev	
			from Prevalence_Begin_shell;
	quit;

	proc sort data=Prevalence_Begin_shell_bywgt;
		by co_occurring;
	run;

	data Prevalence_Begin_bywgt;
		merge Prevalence_Begin_shell_bywgt Prevalence_Begin_bywgt0;
			by co_occurring;
			array change _numeric_;
				do over change;
					if change=. then change=0;
				end;
	run;

	/*@Action: Estimate the variance for prevalence estimates ***/
	Data _NULL_;
		Set Prevalence_Begin_bywgt;
			If co_occurring=3 Then Call symput("Noevid_Prev", Max(Est_Prev, .));
				Else If co_occurring=1Then Call symput("Prediab_Prev", Max(Est_Prev, .));
				Else If co_occurring=2 Then Call symput("Diab_Prev", Max(Est_Prev, .));
	Run;

	Data USER_W_Prevalence_bywgt;
		Set &Infile.;
			where  &wtcatvar.=1;
			/*@Action: Compute variables needed for variance esimation for each prevalence estimate ***/
			If co_occurring=3 Then Z_NoEvidence=(&Weight.*(1-&Noevid_Prev.))/&Est_Pop.;
				Else Z_NoEvidence=(&Weight.*(0-&Noevid_Prev.))/&Est_Pop.;
			If co_occurring=1 Then Z_Prediabetes=(&Weight.*(1-&Prediab_Prev.))/&Est_Pop.;
				Else Z_Prediabetes=(&Weight.*(0-&Prediab_Prev.))/&Est_Pop.;
			If co_occurring=2 Then Z_Diabetes=(&Weight.*(1-&Diab_Prev.))/&Est_Pop.;
				Else Z_Diabetes=(&Weight.*(0-&Diab_Prev.))/&Est_Pop.;

		Proc Sort Data=USER_W_Prevalence_bywgt;
			By Geography;
				Run;

		Proc Sql;
			Create table USER_Z_Means_bywgt as
				Select Geography, Avg(Z_Prediabetes) as Avg_Z_Prediabetes, Avg(Z_Diabetes) as Avg_Z_Diabetes, Avg(Z_NoEvidence) as Avg_Z_NoEvidence
					From USER_W_Prevalence_bywgt
						Group by Geography;
		quit;

		Data USER_W_Prevalence_bywgt;
			Merge USER_W_Prevalence_bywgt USER_Z_Means_bywgt;
				By Geography;
					SqDiff_NoEvidence	 = (Z_NoEvidence-Avg_Z_NoEvidence)**2;
					SqDiff_Prediabetes	 = (Z_Prediabetes-Avg_Z_Prediabetes)**2;
					SqDiff_Diabetes = (Z_Diabetes-Avg_Z_Diabetes)**2;
		Run;

		Proc Sql;
			Create table USER_Prev_Variance_bywgt as
				Select Geography, (Count(*)/(Count(*)-1)) as Strata_Adj,
					Calculated Strata_Adj*Sum(SqDiff_NoEvidence) as NoEvidence,
					Calculated Strata_Adj*Sum(SqDiff_Prediabetes) as Prediabetes,
					Calculated Strata_Adj*Sum(SqDiff_Diabetes) as Diabetes
						From USER_W_Prevalence_bywgt
							Group by Geography;
		Quit;

		Proc Sql;
			Create table Variance_Estimates_bywgt as
				Select 3 as co_occurring, Sum(NoEvidence) as Var_Est From USER_Prev_Variance_bywgt union
				Select 1 as co_occurring, Sum(Prediabetes) as Var_Est From USER_Prev_Variance_bywgt union
				Select 2 as co_occurring, Sum(Diabetes) as Var_Est From USER_Prev_Variance_bywgt;
		Quit;

	Proc Sql;
		%If &AgeAdj.=Y %Then %Do;
			Create table &Outfile. as
				Select a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label, a.Est_Pop_Cnt as Pop_n_age_adj, a.Est_Prev*100 as pop_perc_age_adj, Sqrt(b.Var_Est)*100 as std_err_age_adj
						From Prevalence_Begin_bywgt as a, Variance_Estimates_bywgt as b
							where a.co_occurring=b.co_occurring
								order by co_occurring;
		%End;
		%Else %Do;
			Create table &Outfile. as
				Select a.co_occurring as co_occurring, 
					case when a.co_occurring=1 then "(2) Prediabetes" 
						when a.co_occurring=2 then "(3) Diabetes" 
						else "(1) No Evidence"
					end as co_occurring_label, a.Sample_Cnt as Sample_PT, a.Est_Pop_Cnt as Pop_n,
					c.Crude_Prev*100 as Crude_Prev, c.Crude_StdErr*100 as Crude_StdErr,
					a.Est_Prev*100 as Pop_Perc, b.Var_Est, Sqrt(b.Var_Est)*100 as STD_Err
						From Prevalence_Begin_bywgt as a, Variance_Estimates_bywgt as b, Crude_Prev_Est_bywgt as c
							where a.co_occurring=b.co_occurring and a.co_occurring=c.co_occurring
								order by co_occurring;
		%End;
			Quit;
%Mend;

%Macro Run_Est_Prevalence_COND_bywgt;
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_UW, Weight=RakeWgt, AgeAdj=, wtcatvar=UndrWgt_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_HW, Weight=RakeWgt, AgeAdj=, wtcatvar=HlthyWgt_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_OW, Weight=RakeWgt, AgeAdj=, wtcatvar=OvrWgt_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_OB123, Weight=RakeWgt, AgeAdj=, wtcatvar=ObstyC123_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_OB1, Weight=RakeWgt, AgeAdj=, wtcatvar=ObstyC1_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_OB2, Weight=RakeWgt, AgeAdj=, wtcatvar=ObstyC2_Flg);
	%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=USER_Prev_Est_CoOccur_OB3, Weight=RakeWgt, AgeAdj=, wtcatvar=ObstyC3_Flg);

	%If &AGE_ADJ.=Y %THEN %DO;
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_UW, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=UndrWgt_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_HW, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=HlthyWgt_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_OW, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=OvrWgt_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_OB123, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=ObstyC123_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_OB1, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=ObstyC1_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_OB2, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=ObstyC2_Flg);
		%Est_Prevalence_COND_bywgt(Infile=Weighted_USER_File, Outfile=Age_Adj_Prev_CoOccur_OB3, Weight=AgeAdjWgt, AgeAdj=&AGE_ADJ., wtcatvar=ObstyC3_Flg);

		Data USER_Prev_Est_CoOccur_UW;
			Merge USER_Prev_Est_CoOccur_UW Age_Adj_Prev_CoOccur_UW;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_HW;
			Merge USER_Prev_Est_CoOccur_HW Age_Adj_Prev_CoOccur_HW;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_OW;
			Merge USER_Prev_Est_CoOccur_OW Age_Adj_Prev_CoOccur_OW;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_OB123;
			Merge USER_Prev_Est_CoOccur_OB123 Age_Adj_Prev_CoOccur_OB123;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_OB1;
			Merge USER_Prev_Est_CoOccur_OB1 Age_Adj_Prev_CoOccur_OB1;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_OB2;
			Merge USER_Prev_Est_CoOccur_OB2 Age_Adj_Prev_CoOccur_OB2;
				By co_occurring;
					Run;
		Data USER_Prev_Est_CoOccur_OB3;
			Merge USER_Prev_Est_CoOccur_OB3 Age_Adj_Prev_CoOccur_OB3;
				By co_occurring;
					Run;
	%End;
%Mend;

%Run_Est_Prevalence_COND_bywgt;

%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_UW, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_UW, subset=UW);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_HW, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_HW, subset=HW);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_OW, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_OW, subset=OW);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_OB123, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_OB123, subset=OB123);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_OB1, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_OB1, subset=OB1);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_OB2, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_OB2, subset=OB2);
%Suppress_cond(fileinest=USER_Prev_Est_CoOccur_OB3, fileinwgt=Weighted_USER_File, fileout=USER_Prev_Supp_CoOccur_OB3, subset=OB3);

%Macro Check_SAS_Err_CO_OCCURRING2;
	Proc Sql NOPRINT;
		Select NOBS into :Error6 Trimmed From Dictionary.Tables where Libname='WORK' and upcase(Memname) contains 'USER_PREV_SUPP';
	Quit;

	%IF &Error6.=0 %Then %Do;
		%Let FailureCode=9;
		%Goto Exit;
	%End;
	%Else %Do;
		/*@Action: Execute Generate Report Macro (Success) ***/
		%Generate_Prev_Report_CoOccur(Infile1=USER_Prev_Supp, Infile2=USER_Prev_Supp_CoOccur, Infile3=USER_Prev_Supp_wgt, Infile4=USER_Prev_Supp_CoOccur_UW, Infile5=USER_Prev_Supp_CoOccur_HW, Infile6=USER_Prev_Supp_CoOccur_OW, Infile7=USER_Prev_Supp_CoOccur_OB123, Infile8=USER_Prev_Supp_CoOccur_OB1, Infile9=USER_Prev_Supp_CoOccur_OB2, Infile10=USER_Prev_Supp_CoOccur_OB3, Pass=Y, FailCode=);
	%End;

	%Exit: 
		%If &FailureCode. ne %Then %Do;
			%Generate_Prev_Report_CoOccur(Infile1=, Infile2=, Infile3=, Infile4=, Infile5=, Infile6=, Infile7=, Infile8=, Infile9=, Infile10=, Pass=N, FailCode=&FailureCode.);
		%End;
%Mend;

/*@Action: Execute Check SAS error 2 Macro ***/
%Check_SAS_Err_CO_OCCURRING2;