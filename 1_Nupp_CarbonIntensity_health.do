/*---------------------------------------------------------
* Topic: NUPP and Carbon intensity analysis
* Date: 20250416
* Update: 20250416
* Note : GDP3 - 建成区GDP(以2010年建成区边界为准）


*/
*---------------------------------------------------------

clear all

global path [YOUR PATH]

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables
global grp $path/Graphs





use $svd/1_Nupp_CarbonGDP_event.dta, replace




* ------------1 NUPP and Carbon/GDP DiD regression------------




** Emission **
reghdfe totalCarbon NUPPdid lnpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) replace label ctitle(Total_emission) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe urbanCarbon NUPPdid lnurbanpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Urban_emission) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe ruralCarbon NUPPdid lnruralpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Rural_emission) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

** GDP **
reghdfe gdp NUPPdid lnpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(total_GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe est_urbanGDP NUPPdid lnurbanpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(urban_GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe est_ruralGDP NUPPdid lnruralpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(rural_GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

** Intensity **
reghdfe totalCI NUPPdid totalCarbon lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Totalemission/gdp) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe urbanCI NUPPdid urbanCarbon lnurbanpop logurbangdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Urbanemission/gdp) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe ruralCI NUPPdid ruralCarbon lnruralpop logruralgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Ruralemission/gdp) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)


** Medical Condition - bed ** 

reghdfe total_medbed NUPPdid lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Total_MedicalBed) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe urban_medbed NUPPdid lnurbanpop logurbangdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Urban_MedicalBed) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe rural_medbed NUPPdid lnruralpop logruralgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Rural_MedicalBed) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)


** Environment cost ** 

reghdfe gov_env_cost NUPPdid lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
outreg2 using "$tbls/1_NUPP_carbon_gdp_city.doc", keep(NUPPdid) append label ctitle(Total_Env_cost) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)



/* For Number of Sample Standard Deviation & proportion of sample mean

gen logtotalCarbon = log(totalCarbon)
gen logurbanCarbon = log(urbanCarbon)
gen logruralCarbon = log(ruralCarbon)

gen logtotal_medbed =log(total_medbed)
gen logurban_medbed =log(urban_medbed)
gen logrural_medbed =log(rural_medbed)

gen loggov_env_cost = log(gov_env_cost)





** Emission **
reghdfe totalCarbon NUPPdid lnpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "totalCarbon"
est sto CarbonTotal



reghdfe urbanCarbon NUPPdid lnurbanpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)


quietly estadd local type "urbanCarbon"
est sto CarbonUrban


reghdfe ruralCarbon NUPPdid lnruralpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "ruralCarbon"
est sto CarbonRural



** GDP **
reghdfe totalgdp NUPPdid lnpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "totalGDP"
est sto GDPTotal


reghdfe urbangdp NUPPdid lnurbanpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)


quietly estadd local type "urbanGDP"
est sto GDPUrban


reghdfe ruralgdp NUPPdid lnruralpop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)


quietly estadd local type "ruralGDP"
est sto GDPRural

** Intensity **
reghdfe totalCI NUPPdid totalCarbon lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "totalCI"
est sto CITotal


reghdfe urbanCI NUPPdid urbanCarbon lnurbanpop logurbangdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "urbanCI"
est sto CIUrban


reghdfe ruralCI NUPPdid ruralCarbon lnruralpop logruralgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "ruralCI"
est sto CIRural


** Medical Condition - bed ** 

reghdfe total_medbed NUPPdid lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "totalMed"
est sto MedTotal


reghdfe urban_medbed NUPPdid lnurbanpop logurbangdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "urbanMed"
est sto MedUrban




reghdfe rural_medbed NUPPdid lnruralpop logruralgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)


quietly estadd local type "ruralMed"
est sto MedRural





** Environment cost ** 

reghdfe gov_env_cost NUPPdid lnpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio, absorb(citycode year) resid vce(cluster citycode)
quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar Mean = r(mean)
quietly estadd scalar SD = r(sd)

quietly estadd local type "Envcost"
est sto Envcost


esttab  ///
Carbon* GDP* CI* Med* Envcost using $tbls/1_NUPP_carbon_gdp_city.csv, replace se    ///
stats(N r2 Mean SD type,fmt(%12.3f) labels("Obs." "R-squred" "Mean DV" "SD" "type")) compress nogap



*/




* ------------1.1 NUPP and Carbon/GDP Event Plot------------


clear
use $svd/1_Nupp_CarbonGDP_event.dta, replace
rename lnpop lntotalpop


*** Carbon Emission ***
foreach v in total urban rural{
	
reghdfe `v'Carbon prior* post* ln`v'pop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar SMean = r(mean)
quietly estadd scalar SD = r(sd)

***remove mean
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local mean = r(mean)
estadd local Mean `mean'

est sto emission_`v'
drop coef b_*

}

rename gdp est_totalGDP

*** GDP ***
foreach v in total urban rural{
	
reghdfe est_`v'GDP prior* post* ln`v'pop lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar SMean = r(mean)
quietly estadd scalar SD = r(sd)

***remove mean
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local mean = r(mean)
estadd local Mean `mean'
est sto gdp_`v'

drop coef b_*
}



*** carbon emission to GDP ***
foreach v in total urban rural{
	
reghdfe `v'CI prior* post* `v'Carbon ln`v'pop log`v'gdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar SMean = r(mean)
quietly estadd scalar SD = r(sd)

***remove mean
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local mean = r(mean)
estadd local Mean `mean'
est sto ratio_`v'
drop coef b_*
}



*** Medical Condition - bed ***

foreach v in total urban rural{
	
reghdfe `v'_medbed prior* post* ln`v'pop log`v'gdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio env_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar SMean = r(mean)
quietly estadd scalar SD = r(sd)

***remove mean
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local mean = r(mean)
estadd local Mean `mean'
est sto medi_`v'
drop coef b_*
}


*** Environment cost ratio ***


reghdfe gov_env_cost prior* post* lntotalpop logtotalgdp lngovspend lnmedppl tech_finance_ratio edu_finance_ratio, absorb(citycode year) resid vce(cluster citycode)

quietly summarize `e(depvar)' if e(sample)

quietly estadd scalar SMean = r(mean)
quietly estadd scalar SD = r(sd)

***remove mean
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local mean = r(mean)
estadd local Mean `mean'
est sto env_total
drop coef b_*



rename lntotalpop  lnpop
rename est_totalGDP gdp

esttab  ///
emission* gdp* ratio* medi* env* using $tbls/2_NUPP_eventplot.csv, replace label se  ///
keep(prior* post*) stats(N  r2_a Mean SMean SD) star(* 0.1 ** 0.05 *** 0.01) compress nogap

estimates clear





*==================================================================
* --------------------2. NUPP and Health-----------------------
*==================================================================



use $svd/2_Nupp_CarbonGDP_charls_merged.dta,replace

rename lntotalpop lnpop 

// *** regression ***\\


** total **
eststo reg:reghdfe shlta NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd scalar SD = r(sd)

	est sto total_shlta

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd scalar SD = r(sd)
	
	est sto total_`yvar'

}

esttab  ///
total_* using $tbls/3_NUP_totalhealth.csv, replace  se keep(NUPPdid)   ///
stats(N r2 Mean SD,fmt(%12.3f) labels("Obs." "R-squred" "Mean DV")) compress nogap

estimates clear

** urban **
eststo reg:reghdfe shlta NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if urban_nbs==1, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar SD = r(sd)
	quietly estadd scalar Mean = r(mean)

	est sto urban_shlta

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==1, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar SD = r(sd)
	quietly estadd scalar Mean = r(mean)
	est sto urban_`yvar'

}

esttab  ///
urban_* using $tbls/3_NUP_urbanhealth.csv, replace  se keep(NUPPdid)   ///
stats(N r2 Mean SD,fmt(%12.3f) labels("Obs." "R-squred" "Mean DV")) compress nogap

estimates clear

** rural **
eststo reg:reghdfe shlta NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if urban_nbs==0, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd scalar SD = r(sd)

	est sto rural_shlta

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' NUPPdid ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==0, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd scalar SD = r(sd)
	est sto rural_`yvar'

}

esttab  ///
rural_* using $tbls/3_NUP_ruralhealth.csv, replace  se keep(NUPPdid)    ///
stats(N r2 Mean SD,fmt(%12.3f) labels("Obs." "R-squred" "Mean DV")) compress nogap



* ------------2.1 NUPP and Health Event Plot------------



** total **
eststo reg:reghdfe shlta prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "total"

forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'
	
	est sto total_shlta

drop b_* coef	
	
	
foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "total"
	forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'

	est sto total_`yvar'
	drop b_* coef
}


** urban **
eststo reg:reghdfe shlta prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if urban_nbs==1, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "urban"
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'
	
	est sto urban_shlta

drop b_* coef	
	
	
foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==1, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "urban"
	forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'

	est sto urban_`yvar'
	drop b_* coef
}


** rural **
eststo reg:reghdfe shlta prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if urban_nbs==0, absorb(citycode year) vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "rural"
forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'
	
	est sto rural_shlta

drop b_* coef	
	
	
foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
eststo reg: logit `yvar' prior* post* ragender raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==0, vce(cluster citycode)

	quietly summarize `e(depvar)' if e(sample)
	quietly estadd scalar Mean = r(mean)
	quietly estadd local type "rural"
	
	forvalues i=6(-1)2{
	gen b_`i'= _b[prior`i']
}
gen coef=(b_2+b_3+b_4+b_5+b_6)/5

sum coef
local demean=r(mean)
	estadd local demean `demean'

	est sto rural_`yvar'
	drop b_* coef
}


esttab  ///
total_* urban_* rural_* using $tbls/3_NUP_healthEvent.csv, replace  se keep(prior* post*)    ///
stats(N r2 Mean demean type,fmt(%12.0f %9.3f) labels("Obs." "R-squred" "Mean DV" "Mean Cofficient" "Area")) compress nogap




*==================================================================
* --------------------3. Moderating Effect on Health--------------
*==================================================================



clear 
use $svd/2_Nupp_CarbonGDP_charls_merged.dta


global tbls $path/Tables/0515ModerEffect


*** Carbon Intensity levels classification (Meidan) ***




gen rural_nbs = 1 if urban_nbs == 0

/*****************************
pre:
	urbanmedian = .5339959 
	ruralmedian = .3308473
	 
	total medibed = 14338.5
	env_cost = 62439.35

post:
	urbanmedian = .4250138
	ruralmedian = .2157255
	 
	total medibed = 23816.5 
	env_cost = 139017.2 

total:
	urbanmedian = .5137485  
	ruralmedian = .3088462 
	 
	total medibed = 15511.5
	env_cost = 68768.54 

********************************/


global urbanmedian = .5137485   
display $urbanmedian

global ruralmedian = .3088462 
display $ruralmedian

*** Medical Bed
gen total_medlevel = .

replace total_medlevel = 1 if total_medbed >= 15511.5  //high medical condition 
replace total_medlevel = 0 if total_medbed < 15511.5  //low medical condition

*** Envioment Cost
gen env_cost_level = .

replace env_cost_level = 1 if gov_env_cost >= 68768.54   //high cost
replace env_cost_level = 0 if gov_env_cost < 68768.54    //low cost



********************
*      Baseline    *
********************
*urban: low , high
*rural: low , high

***shlta***

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian , absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) replace label ctitle(urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian , absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian , absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian , absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)



***other disease***

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{
	
	
quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.citycode i.year if urban_nbs==1 & urbanCI>= $urbanmedian ,  vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.citycode i.year if urban_nbs==1 & urbanCI< $urbanmedian ,  vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==0 & ruralCI>= $ruralmedian ,  vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.citycode i.year if urban_nbs==0 & ruralCI< $ruralmedian ,  vce(cluster citycode)
outreg2 using "$tbls/4(1)_NUPPmoder_health_baseline.xls", keep(NUPPdid) append label ctitle(rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
	
}




















**********************
*      Gender    *
**********************




***shlta***
**male
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & ragender == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) replace label ctitle(male_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & ragender == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & ragender == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & ragender == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**female
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & ragender == 2, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & ragender == 2, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & ragender == 2, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & ragender == 2, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{



**male
quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & ragender == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & ragender == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & ragender == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & ragender == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(male_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**female
quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & ragender == 2, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & ragender == 2, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & ragender == 2, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & ragender == 2, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_gender.xls", keep(NUPPdid) append label ctitle(female_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)





}





























**********************
*      Moderating    *
**********************



// *** Medical Condition (Bed) *** \\


***Shlta
**High medical condition

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) replace label ctitle(1_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**Low medical condition

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)


*** Other Disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

**High medical condition

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**Low medical condition

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

}



// *** Environment Cost *** \\


***Shlta
**High Environment Cost

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) replace label ctitle(1_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**Low Environment Cost

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 0,  absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & env_cost_level == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)


*** Other Disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

**High Environment Cost

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & env_cost_level == 1, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

**Low Environment Cost

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_urban_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_urban_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_rural_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if urban_nbs==0 & ruralCI< $ruralmedian & env_cost_level == 0, vce(cluster citycode)
outreg2 using "$tbls/4(2)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0_rural_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

}



















/*

***********************************
*      Moderating  with gender    *
***********************************



// *** Medical Condition (Bed) *** \\



***Shlta
**Hight medical condition
*male
 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) replace label ctitle(1male_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1male_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1male_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1male_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

*female
 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & total_medlevel == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1female_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & total_medlevel == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1female_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & total_medlevel == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1female_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

 reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & total_medlevel == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(1female_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)



*Low meical condition

foreach i in urban rural{
	
	 reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI >= $`i'median & total_medlevel == 0 & ragender == 1,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0male_`i'_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	 reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI < $`i'median & total_medlevel == 0 & ragender == 1,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0male_`i'_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	 reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI >= $`i'median & total_medlevel == 0 & ragender == 2,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0female_`i'_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	 reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI < $`i'median & total_medlevel == 0 & ragender == 2,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(0female_`i'_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke {

	forvalues g = 1(-1)0 {
		
		foreach i in urban rural {

			* 1. Male - high emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl   if `i'_nbs==1 & `i'CI >= $`i'median & total_medlevel==`g' & ragender == 1, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - male - `i' - high emission - medlevel `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - male - `i' - high emission - medlevel `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(`g'male_`i'_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 2. Male - low emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl   if `i'_nbs==1 & `i'CI < $`i'median & total_medlevel==`g' & ragender == 1, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - male - `i' - low emission - medlevel `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - male - `i' - low emission - medlevel `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(`g'male_`i'_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 3. Female - high emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl   if `i'_nbs==1 & `i'CI >= $`i'median & total_medlevel==`g' & ragender == 2, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - female - `i' - high emission - medlevel `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - female - `i' - high emission - medlevel `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(`g'female_`i'_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 4. Female - low emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl   if `i'_nbs==1 & `i'CI < $`i'median & total_medlevel==`g' & ragender == 2, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - female - `i' - low emission - medlevel `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - female - `i' - low emission - medlevel `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_medi.xls", keep(NUPPdid) append label ctitle(`g'female_`i'_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

		}	
	}
}



// *** Environment Cost *** \\


*** Shlta
**High environment cost
*male
reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) replace label ctitle(1male_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1male_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1male_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & env_cost_level == 1 & ragender == 1,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1male_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

*female
reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI>= $urbanmedian & env_cost_level == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1female_urban_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urban_nbs==1 & urbanCI< $urbanmedian & env_cost_level == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1female_urban_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI>= $ruralmedian & env_cost_level == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1female_rural_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if urban_nbs==0 & ruralCI< $ruralmedian & env_cost_level == 1 & ragender == 2,  vce(cluster citycode)
outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(1female_rural_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)



*Low environment cost

foreach i in urban rural{
	reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI >= $`i'median & env_cost_level == 0 & ragender == 1,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0male_`i'_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI < $`i'median & env_cost_level == 0 & ragender == 1,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0male_`i'_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI >= $`i'median & env_cost_level == 0 & ragender == 2,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0female_`i'_high_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	reghdfe shlta NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl if `i'_nbs==1 & `i'CI < $`i'median & env_cost_level == 0 & ragender == 2,  vce(cluster citycode)
	outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ctitle(0female_`i'_low_emission_shlta) addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)

	
	
}

**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke {

	forvalues g = 1(-1)0 {
		
		foreach i in urban rural {

			* 1. Male - high emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl  ///
				if `i'_nbs==1 & `i'CI >= $`i'median & env_cost_level==`g' & ragender == 1, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - male - `i' - high emission - env_cost_level `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - male - `i' - high emission - env_cost_level `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ///
					ctitle(`g'male_`i'_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 2. Male - low emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl  ///
				if `i'_nbs==1 & `i'CI < $`i'median & env_cost_level==`g' & ragender == 1, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - male - `i' - low emission - env_cost_level `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - male - `i' - low emission - env_cost_level `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ///
					ctitle(`g'male_`i'_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 3. Female - high emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl  ///
				if `i'_nbs==1 & `i'CI >= $`i'median & env_cost_level==`g' & ragender == 2, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - female - `i' - high emission - env_cost_level `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - female - `i' - high emission - env_cost_level `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ///
					ctitle(`g'female_`i'_high_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}

			* 4. Female - low emission
			 logit `yvar' NUPPdid raeducl age rahltcom hukou ln`i'pop `i'Carbon log`i'gdp lngovspend lnmedppl  ///
				if `i'_nbs==1 & `i'CI < $`i'median & env_cost_level==`g' & ragender == 2, vce(cluster citycode)
			if _rc == 430 {
				di as error "Non-concave: `yvar' - female - `i' - low emission - env_cost_level `g'"
			}
			else if _rc != 0 {
				di as error "Other error (code `_rc') for `yvar' - female - `i' - low emission - env_cost_level `g'"
			}
			else {
				outreg2 using "$tbls/4(3)_NUPPmoder_health_envcost.xls", keep(NUPPdid) append label ///
					ctitle(`g'female_`i'_low_emission_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(4)
			}
		
		}
	}
}




*/
