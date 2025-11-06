/*---------------------------------------------------------
* Topic: NUPP and Carbon intensity analysis
* Date: 20250416
* Update: 20251106
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


* ------------2.2 Descriptive Statistics------------


use $svd/2_Nupp_CarbonGDP_charls_merged.dta, replace


* Log transformation of gdp and carbon
gen logtotalcarbon = log(totalCarbon)
gen logenvcost = log(gov_env_cost)

gen logurbancarbon = log(urbanCarbon)
gen logruralcarbon = log(ruralCarbon)



* Calculate the medical bed/ population
gen total_medbed_per = total_medbed/常住人口数万人
gen urban_medbed_per = urban_medbed/城镇常住人口数万人
gen rural_medbed_per = rural_medbed/(常住人口数万人-城镇常住人口数万人)


rename lnpop lntotalpop

rename tech_finance_ratio tech_ratio
label var tech_ratio "tech ratio"
rename edu_finance_ratio edu_ratio
label var edu_ratio "edu ratio"



*** individual level ***
	// characteristics: raeducl age rahltcom hukou
	// Health: shlta psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke
tab hukou	

*by urban/ruralCarbon

local cont raeducl age rahltcom shlta psyche hibpe diabe arthre dyslipe livere kidneye digeste asthma cancre lunge memrye hearte stroke

tabstat `cont', by(urban_nbs) stats(count mean sd min max) columns(statistics) format(%9.3f)

estpost tabstat `cont', by(urban_nbs) stats(count mean sd min max) columns(statistics)
esttab using $tbls/1_total_individual_region.csv, ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3))") replace

	
bys urban_nbs: tab hukou	
	
*by male/female

local cont raeducl age rahltcom shlta psyche hibpe diabe arthre dyslipe livere kidneye digeste asthma cancre lunge memrye hearte stroke

tabstat `cont', by(ragender) stats(count mean sd min max) columns(statistics) format(%9.3f)

estpost tabstat `cont', by(ragender) stats(count mean sd min max) columns(statistics)
esttab using $tbls/1_total_individual_gender.csv, ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3))") replace

	
bys ragender: tab hukou	
	


*** city level ***

* total
estpost summarize logtotalgdp logtotalcarbon totalCI total_medbed_per lntotalpop, detail
esttab using $tbls/1_total_city.csv, cells("count mean sd min max") replace

*urban
estpost summarize logurbangdp logurbancarbon urbanCI urban_medbed_per lnurbanpop, detail
esttab using $tbls/1_urban_city.csv, cells("count mean sd min max") replace


*rural
estpost summarize logruralgdp logruralcarbon ruralCI rural_medbed_per lnruralpop, detail
esttab using $tbls/1_rural_city.csv, cells("count mean sd min max") replace



*all 
estpost summarize lngovspend lnmedppl logenvcost tech_ratio edu_ratio, detail
esttab using $tbls/1_all_city.csv, cells("count mean sd min max") replace
