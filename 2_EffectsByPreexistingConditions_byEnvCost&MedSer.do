/*---------------------------------------------------------
* Topic: Effects of the NUP under different preexisting GDP and carbon intensity levels
* Date: 20251018
* Update: 20251020
*---------------------------------------------------------
*/

clear all


global path [YOUR PATH]

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables
global grp $path/Graphs

*===== Group indicator for cities based on median in 2011 ======*


use $svd/2_Nupp_CarbonGDP_charls_merged.dta,replace


keep rgdp_def est_urbanGDP est_ruralGDP totalCI urbanCI ruralCI gov_env_cost env_finance_ratio rural_medbed urban_medbed total_medbed year city
rename rgdp_def totalGDP
rename est_urbanGDP urbanGDP
rename est_ruralGDP ruralGDP
duplicates drop


foreach v in totalGDP totalCI total_medbed rural_medbed urban_medbed{

bysort year: egen std_`v' = std(`v')	
summarize std_`v' if year ==2011, detail
local med = r(p50)

gen `v'_g = (std_`v' >= `med') if !missing(std_`v')
}


foreach v in env_finance_ratio{

bysort year: egen std_`v' = std(`v')	
summarize std_`v' if year ==2011, detail
local med = r(p50)

gen `v'_g = (std_`v' >= `med') if !missing(std_`v')
}

rename env_finance_ratio_g gov_env_cost_g

gen ruralGDP_g = totalGDP_g
gen urbanGDP_g = totalGDP_g
gen urbanCI_g = totalCI_g
gen ruralCI_g = totalCI_g


keep year city totalGDP_g ruralGDP_g urbanGDP_g totalCI_g urbanCI_g ruralCI_g gov_env_cost_g rural_medbed_g urban_medbed_g total_medbed_g

save $wrk/city_group1.dta, replace

use $raw/2_Nupp_CarbonGDP_charls_merged.dta,replace
gen ruralGDP = TotalGDP - urbanGDP
	
merge m:1 city year using $wrk/city_group1.dta
drop _merge




********************************************  gov_env_cost  ******************************************** 


*==================================================================
* -----------------------------1. ALL------------------------------
*==================================================================

	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & gov_env_cost_g == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & gov_env_cost_g == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{


quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & gov_env_cost_g == 1,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & gov_env_cost_g == 0, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	

*==================================================================
* -----------------------------2. URBAN ---------------------------
*==================================================================


	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & gov_env_cost_g == 1 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)

outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)



capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & gov_env_cost_g == 0 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)

outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{


quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & gov_env_cost_g == 1 & urban_nbs==1, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
	


quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & gov_env_cost_g == 0 & urban_nbs==1, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	
*==================================================================
* -----------------------------3. RURAL ---------------------------
*==================================================================


	
	
	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & gov_env_cost_g == 1 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & gov_env_cost_g == 0 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{



quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & gov_env_cost_g == 1 & urban_nbs==0,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & gov_env_cost_g == 0 & urban_nbs==0, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0cost_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}


********************************************  med ser ******************************************** 


*==================================================================
* -----------------------------1. ALL------------------------------
*==================================================================


	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & total_medbed_g == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & total_medbed_g == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{


quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & total_medbed_g == 1,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & total_medbed_g == 0, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	

*==================================================================
* -----------------------------2. URBAN ---------------------------
*==================================================================

	
	
	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & urban_medbed_g == 1 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & urban_medbed_g == 0 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{


quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & urban_medbed_g == 1 & urban_nbs==1,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & urban_medbed_g == 0 & urban_nbs==1, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	
*==================================================================
* -----------------------------3. RURAL ---------------------------
*==================================================================

	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & rural_medbed_g == 1 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & rural_medbed_g == 0 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_aahealth) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & rural_medbed_g == 1 & urban_nbs==0,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_1med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & rural_medbed_g == 0 & urban_nbs==0, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_0med_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
