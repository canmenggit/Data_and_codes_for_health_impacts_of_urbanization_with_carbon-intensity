/*---------------------------------------------------------
* Topic: Effects of the NUP under different preexisting GDP and carbon intensity levels
* Date: 20251018
*/
*---------------------------------------------------------

clear all


global path [YOUR PATH]

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables
global grp $path/Graphs

*===== Group indicator for cities based on median in 2011 ======*


use $svd/2_Nupp_CarbonGDP_charls_merged.dta,replace

* GDP
keep rgdp_def est_urbanGDP est_ruralGDP totalCI urbanCI ruralCI year city
rename rgdp_def totalGDP
rename est_urbanGDP urbanGDP
rename est_ruralGDP ruralGDP
duplicates drop


foreach v in totalGDP totalCI{

bysort year: egen std_`v' = std(`v')	
summarize std_`v' if year ==2011, detail
local med = r(p50)

gen `v'_g = (std_`v' >= `med') if !missing(std_`v')
}

gen ruralGDP_g = totalGDP_g
gen urbanGDP_g = totalGDP_g
gen urbanCI_g = totalCI_g
gen ruralCI_g = totalCI_g


keep year city totalGDP_g ruralGDP_g urbanGDP_g totalCI_g urbanCI_g ruralCI_g

save $wrk/city_group.dta.dta, replace

use $raw/2_Nupp_CarbonGDP_charls_merged.dta,replace
gen ruralGDP = TotalGDP - urbanGDP
	
merge m:1 city year using $wrk/city_group.dta
drop _merge


*==================================================================
* -----------------------------1. ALL------------------------------
*==================================================================

*** Baseline

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl if totalGDP_g==1 & totalCI_g==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) replace label ctitle(1CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & high GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl if totalGDP_g == 0 & totalCI_g == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(1CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & low GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl if totalGDP_g == 1 & totalCI_g == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(0CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & high GDP 
	
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl if totalGDP_g == 0 & totalCI_g == 0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(0CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & low GDP 

	
	
	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & ragender == 1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl if totalGDP_g == `i' & totalCI_g == `j' & ragender == 2, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j',vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & ragender == 1,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnpop totalCarbon logtotalgdp lngovspend lnmedppl i.year i.citycode if totalGDP_g == `i' & totalCI_g == `j' & ragender == 2, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_all.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnpop totalCarbon ragender logtotalgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	

*==================================================================
* -----------------------------2. URBAN ---------------------------
*==================================================================


*** Baseline

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl if urbanGDP_g==1 & urbanCI_g==1 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) replace label ctitle(1CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & high GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl if urbanGDP_g == 0 & urbanCI_g == 1 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(1CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & low GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl if urbanGDP_g == 1 & urbanCI_g == 0 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(0CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & high GDP 
	
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl if urbanGDP_g == 0 & urbanCI_g == 0 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(0CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & low GDP 

	
	
	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & ragender == 1 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl if urbanGDP_g == `i' & urbanCI_g == `j' & ragender == 2 & urban_nbs==1, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & urban_nbs==1,vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & ragender == 1 & urban_nbs==1,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon logurbangdp lngovspend lnmedppl i.year i.citycode if urbanGDP_g == `i' & urbanCI_g == `j' & ragender == 2 & urban_nbs==1, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_urban.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnurbanpop urbanCarbon ragender logurbangdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
	
	
*==================================================================
* -----------------------------3. RURAL ---------------------------
*==================================================================

*** Baseline

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl if ruralGDP_g==1 & ruralCI_g==1 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) replace label ctitle(1CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & high GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl if ruralGDP_g == 0 & ruralCI_g == 1 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(1CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//high CI & low GDP 
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl if ruralGDP_g == 1 & ruralCI_g == 0 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(0CI_1GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & high GDP 
	
	
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl if ruralGDP_g == 0 & ruralCI_g == 0 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(0CI_0GDP) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)
	//low CI & low GDP 

	
	
	
	
*** Loop

forvalues i = 0(1)1{
	
	forvalues j = 0(1)1{
		
quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & ragender == 1 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

quietly capture reghdfe shlta NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl if ruralGDP_g == `i' & ruralCI_g == `j' & ragender == 2 & urban_nbs==0, absorb(citycode year) vce(cluster citycode)
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female) addtext(Control, YES, Year FE, YES, City FE, YES) dec(3)

	}
	
}


**Other disease

foreach yvar in psyche hibpe diabe arthre dyslipe livere kidneye digeste asthmae cancre lunge memrye hearte stroke{

	forvalues i = 0(1)1{
	
		forvalues j = 0(1)1{

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & urban_nbs==0,vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & ragender == 1 & urban_nbs==0,  vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_male_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)

quietly capture logit `yvar' NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon logruralgdp lngovspend lnmedppl i.year i.citycode if ruralGDP_g == `i' & ruralCI_g == `j' & ragender == 2 & urban_nbs==0, vce(cluster citycode)
			scalar chi2_wald = e(chi2)
			scalar p_overall = e(p)

			if missing(chi2_wald) scalar chi2_wald = 99
			if missing(p_overall) scalar p_overall = 99
outreg2 using "$tbls/1_CI&GDP_subgroup_rural.xls", eform keep(NUPPdid raeducl age rahltcom hukou lnruralpop ruralCarbon ragender logruralgdp lngovspend lnmedppl) append label ctitle(`j'CI_`i'GDP_female_`yvar') addtext(Control, YES, Year FE, YES, City FE, YES) dec(3) addstat("Wald chi2", chi2_wald, "Prob > chi2", p_overall)
			
		}
	}
}
