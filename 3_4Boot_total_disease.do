
// TOTAL

use C:\Users\X\OneDrive\桌面\NUP_bootstrap\2_Nupp_CarbonGDP_charls_merged.dta, replace
cd "C:\Users\X\OneDrive\桌面\NUP_bootstrap"

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


bysort year city: gen city_year_sample = _N


capture program drop boot_effects
program define boot_effects, rclass
    version 16.0

    // Step 1: Direct effect
    gsem ($dis <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.urban_nbs i.year, logit), nocapslatent

    // Store direct effect and paths
    nlcom (_b[$dis:NUPPdid])
    matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_d_1 = bmat[1,1]
    scalar V_d_1 = Vmat[1,1]
    return scalar DE = b_d_1

    nlcom (_b[$dis:logtotalgdp])
    matrix bmat = r(b)
    scalar b_d_2 = bmat[1,1]
    return scalar d_gdp = b_d_2

    nlcom (_b[$dis:logtotalcarbon])
    matrix bmat = r(b)
    scalar b_d_3 = bmat[1,1]
    return scalar d_car = b_d_3

    nlcom (_b[$dis:totalCI])
    matrix bmat = r(b)
    scalar b_d_4 = bmat[1,1]
    return scalar d_ci = b_d_4

    nlcom (_b[$dis:logenvcost])
    matrix bmat = r(b)
    scalar b_d_5 = bmat[1,1]
    return scalar d_env = b_d_5

    nlcom (_b[$dis:total_medbed_per])
    matrix bmat = r(b)
    scalar b_d_6 = bmat[1,1]
    return scalar d_med = b_d_6

    // Step 2: Mediator models
    gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio) ///
        (logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year) ///
        (totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio) ///
        (logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio) ///
        (total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio), ///
        covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent

    nlcom (_b[logtotalgdp:NUPPdid])
    matrix bmat = r(b)
    scalar b_i_2 = bmat[1,1]
    return scalar i_gdp = b_i_2

    nlcom (_b[logtotalcarbon:NUPPdid])
    matrix bmat = r(b)
    scalar b_i_3 = bmat[1,1]
    return scalar i_car = b_i_3

    nlcom (_b[totalCI:NUPPdid])
    matrix bmat = r(b)
    scalar b_i_4 = bmat[1,1]
    return scalar i_ci = b_i_4

    nlcom (_b[logenvcost:NUPPdid])
    matrix bmat = r(b)
    scalar b_i_5 = bmat[1,1]
    return scalar i_env = b_i_5

    nlcom (_b[total_medbed_per:NUPPdid])
    matrix bmat = r(b)
    scalar b_i_6 = bmat[1,1]
    return scalar i_med = b_i_6
	
	nlcom (_b[logtotalcarbon:logtotalgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[totalCI:logtotalgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[totalCI:logtotalcarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[totalCI:logenvcost])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_3 = bmat[1,1]
    scalar V_s_3 = Vmat[1,1]
	
	return scalar s_env = b_s_3	
	
	
	
	
	

    // Compute indirect and total effects
    scalar TIE = b_d_2 * b_i_2 + b_d_3 * b_i_3 + b_d_4 * b_i_4 + b_d_5 * b_i_5 + b_d_6 * b_i_6
    return scalar IE = TIE

    scalar TE = TIE + b_d_1
    return scalar TE = TE

end

// Loop through disease variables
foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke {
    
    // Assign current disease to global macro
    global dis `dis'
    
    bootstrap DE=r(DE) IE=r(IE) TE=r(TE) ///
        D_gdp = r(d_gdp) D_car = r(d_car) D_ci = r(d_ci) D_env = r(d_env) D_med = r(d_med) ///
        I_gdp = r(i_gdp) I_car = r(i_car) I_ci = r(i_ci) I_env = r(i_env) I_med = r(i_med), ///
		C_gdp = r(c_gdp)    ///
		S_gdp = r(s_gdp) S_car = r(s_car) S_env = r(s_env)      ///
        reps(500) seed(12345) saving(`dis'_total): boot_effects

    estat bootstrap
    eststo total_`dis'
    estadd local type "`dis'"
}

// Export all results
esttab total_* using "total_disease.csv", replace stats(type N)











