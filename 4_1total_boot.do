
// TOTAL

use C:\Users\X\OneDrive\桌面\NUP_bootstrap\2_Nupp_CarbonGDP_charls_merged.dta, replace
cd "C:\Users\X\OneDrive\桌面\NUP_bootstrap\result"

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
gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.urban_nbs i.year), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logtotalgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logtotalcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:totalCI])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_4 = bmat[1,1]
	scalar V_d_4 = Vmat[1,1]
	
	return scalar d_ci = b_d_4

    nlcom (_b[shlta:logenvcost])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_5 = bmat[1,1]
	scalar V_d_5 = Vmat[1,1]
	
	return scalar d_env = b_d_5
	
    nlcom (_b[shlta:total_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logtotalgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logtotalcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[totalCI:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_4 = bmat[1,1]
    scalar V_i_4 = Vmat[1,1]
	
	return scalar i_ci = b_i_4
	
    nlcom (_b[logenvcost:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_5 = bmat[1,1]
    scalar V_i_5 = Vmat[1,1]	
	
	return scalar i_env = b_i_5
	
    nlcom (_b[total_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

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
	
    // Compute indirect effect
    scalar TIE = b_d_2 * b_i_2 + b_d_3 * b_i_3 + b_d_4 * b_i_4 + b_d_5 * b_i_5 + b_d_6 * b_i_6
    return scalar IE = TIE

    // Total effect
    scalar TE = TIE + b_d_1
    return scalar TE = TE

end


bootstrap DE=r(DE) IE=r(IE) TE=r(TE)   ///
D_gdp = r(d_gdp) D_car = r(d_car) D_ci = r(d_ci) D_env = r(d_env) D_med = r(d_med)    ///
I_gdp = r(i_gdp) I_car = r(i_car) I_ci = r(i_ci) I_env = r(i_env) I_med = r(i_med)   ///
C_gdp = r(c_gdp)    ///
S_gdp = r(s_gdp) S_car = r(s_car) S_env = r(s_env)      ///
, reps(500) seed(12345) saving(total) : boot_effects 

estat bootstrap

est sto total_boot
esttab total_boot using "total.csv", replace


/*

Bootstrap results                                       Number of obs = 85,756
                                                        Replications  =    500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             | coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .0530609   .0117481     4.52   0.000     .0300351    .0760868
          IE |  -.0038285   .0019775    -1.94   0.053    -.0077044    .0000474
          TE |   .0492324   .0114405     4.30   0.000     .0268094    .0716554
       D_gdp |   .1347934   .0202097     6.67   0.000     .0951832    .1744036
       D_car |   .1264962   .0143714     8.80   0.000     .0983287    .1546637
        D_ci |  -.1583418   .0265068    -5.97   0.000    -.2102941   -.1063895
       D_env |   -.052498   .0090211    -5.82   0.000     -.070179   -.0348171
       D_med |  -.0042955   .0004717    -9.11   0.000      -.00522    -.003371
       I_gdp |    .018644   .0024403     7.64   0.000     .0138611    .0234269
       I_car |   .0784442   .0057047    13.75   0.000     .0672632    .0896252
        I_ci |    .069106   .0015216    45.42   0.000     .0661237    .0720883
       I_env |   .1329138    .004363    30.46   0.000     .1243626     .141465
       I_med |  -.3854205   .0848236    -4.54   0.000    -.5516718   -.2191693
       C_gdp |   .5076709   .0073595    68.98   0.000     .4932465    .5220953
       S_gdp |  -.5542818   .0029314  -189.09   0.000    -.5600272   -.5485364
       S_car |   .4931374   .0021673   227.54   0.000     .4888896    .4973852
       S_env |  -.0534587   .0014492   -36.89   0.000     -.056299   -.0506183
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     85,756
                                                Replications      =        500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |    Observed               Bootstrap
             | coefficient       Bias    std. err.  [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .05306094   .0005234   .01174811    .0295424   .0745156  (BC)
          IE |  -.00382853   .0000374   .00197754   -.0074501   .0002023  (BC)
          TE |   .04923241   .0005608   .01144053    .0272215    .070266  (BC)
       D_gdp |   .13479342   .0007129   .02020966    .0985092   .1766519  (BC)
       D_car |   .12649621  -.0009532   .01437143    .0957088   .1524364  (BC)
        D_ci |  -.15834183   .0021511   .02650677   -.2109065  -.1099403  (BC)
       D_env |  -.05249804  -.0003417   .00902106   -.0691423  -.0337386  (BC)
       D_med |   -.0042955  -.0000207   .00047171   -.0051486  -.0032119  (BC)
       I_gdp |   .01864398   7.66e-06   .00244029    .0139663   .0233684  (BC)
       I_car |   .07844423   -.000087    .0057047     .066953   .0893965  (BC)
        I_ci |     .069106    .000026   .00152163    .0664449   .0720157  (BC)
       I_env |   .13291379  -.0001906   .00436296     .124884   .1419813  (BC)
       I_med |  -.38542053   .0009371   .08482364   -.5385063  -.2124918  (BC)
       C_gdp |   .50767087   .0001477   .00735952    .4925588   .5221672  (BC)
       S_gdp |   -.5542818    .000058   .00293138   -.5600266  -.5490382  (BC)
       S_car |    .4931374   .0000133    .0021673    .4888167   .4972451  (BC)
       S_env |  -.05345865    .000043   .00144917   -.0561272  -.0504392  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected


*/





// MALE

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
gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 1), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logtotalgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logtotalcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:totalCI])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_4 = bmat[1,1]
	scalar V_d_4 = Vmat[1,1]
	
	return scalar d_ci = b_d_4

    nlcom (_b[shlta:logenvcost])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_5 = bmat[1,1]
	scalar V_d_5 = Vmat[1,1]
	
	return scalar d_env = b_d_5
	
    nlcom (_b[shlta:total_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logtotalgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logtotalcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[totalCI:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_4 = bmat[1,1]
    scalar V_i_4 = Vmat[1,1]
	
	return scalar i_ci = b_i_4
	
    nlcom (_b[logenvcost:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_5 = bmat[1,1]
    scalar V_i_5 = Vmat[1,1]	
	
	return scalar i_env = b_i_5
	
    nlcom (_b[total_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

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
	
	
    // Compute indirect effect
    scalar TIE = b_d_2 * b_i_2 + b_d_3 * b_i_3 + b_d_4 * b_i_4 + b_d_5 * b_i_5 + b_d_6 * b_i_6
    return scalar IE = TIE

    // Total effect
    scalar TE = TIE + b_d_1
    return scalar TE = TE

end


bootstrap DE=r(DE) IE=r(IE) TE=r(TE)   ///
D_gdp = r(d_gdp) D_car = r(d_car) D_ci = r(d_ci) D_env = r(d_env) D_med = r(d_med)    ///
I_gdp = r(i_gdp) I_car = r(i_car) I_ci = r(i_ci) I_env = r(i_env) I_med = r(i_med)   ///
C_gdp = r(c_gdp)    ///
S_gdp = r(s_gdp) S_car = r(s_car) S_env = r(s_env)      ///
, reps(500) seed(12345) saving(male) : boot_effects 

estat bootstrap

est sto male_boot
esttab male_boot using "male.csv", replace



/*

Bootstrap results                                       Number of obs = 85,756
                                                        Replications  =    500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             | coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .0752349   .0174801     4.30   0.000     .0409745    .1094952
          IE |  -.0055539     .00283    -1.96   0.050    -.0111006   -7.26e-06
          TE |    .069681   .0173342     4.02   0.000     .0357066    .1036553
       D_gdp |   .0768816    .029022     2.65   0.008     .0199995    .1337636
       D_car |   .1727542   .0203709     8.48   0.000     .1328279    .2126805
        D_ci |  -.1901286   .0380081    -5.00   0.000     -.264623   -.1156342
       D_env |  -.0665444   .0139975    -4.75   0.000    -.0939789   -.0391099
       D_med |  -.0037487   .0006147    -6.10   0.000    -.0049535   -.0025439
       I_gdp |    .018644   .0024403     7.64   0.000     .0138611    .0234269
       I_car |   .0784442   .0057047    13.75   0.000     .0672632    .0896252
        I_ci |    .069106   .0015216    45.42   0.000     .0661237    .0720883
       I_env |   .1329138    .004363    30.46   0.000     .1243626     .141465
       I_med |  -.3854205   .0848236    -4.54   0.000    -.5516718   -.2191693
       C_gdp |   .5076709   .0073595    68.98   0.000     .4932465    .5220953
       S_gdp |  -.5542818   .0029314  -189.09   0.000    -.5600272   -.5485364
       S_car |   .4931374   .0021673   227.54   0.000     .4888896    .4973852
       S_env |  -.0534587   .0014492   -36.89   0.000     -.056299   -.0506183
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     85,756
                                                Replications      =        500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |    Observed               Bootstrap
             | coefficient       Bias    std. err.  [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .07523489   .0004535   .01748009    .0416048   .1081495  (BC)
          IE |  -.00555391  -.0001334   .00282998   -.0107303    .000755  (BC)
          TE |   .06968098   .0003201   .01733417    .0378358   .1025095  (BC)
       D_gdp |   .07688157  -.0010068   .02902198    .0223492   .1355014  (BC)
       D_car |   .17275425  -.0001924   .02037093    .1342686   .2136021  (BC)
        D_ci |   -.1901286  -.0014035   .03800805   -.2595683  -.1130824  (BC)
       D_env |  -.06654438   .0000418   .01399746   -.0943182  -.0395265  (BC)
       D_med |  -.00374871  -.0000349   .00061471   -.0048684  -.0024574  (BC)
       I_gdp |   .01864398   7.66e-06   .00244029    .0139663   .0233684  (BC)
       I_car |   .07844423   -.000087    .0057047     .066953   .0893965  (BC)
        I_ci |     .069106    .000026   .00152163    .0664449   .0720157  (BC)
       I_env |   .13291379  -.0001906   .00436296     .124884   .1419813  (BC)
       I_med |  -.38542053   .0009371   .08482364   -.5385063  -.2124918  (BC)
       C_gdp |   .50767087   .0001477   .00735952    .4925588   .5221672  (BC)
       S_gdp |   -.5542818    .000058   .00293138   -.5600266  -.5490382  (BC)
       S_car |    .4931374   .0000133    .0021673    .4888167   .4972451  (BC)
       S_env |  -.05345865    .000043   .00144917   -.0561272  -.0504392  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected


*/







// FEMALE

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
gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 2), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logtotalgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logtotalcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:totalCI])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_4 = bmat[1,1]
	scalar V_d_4 = Vmat[1,1]
	
	return scalar d_ci = b_d_4

    nlcom (_b[shlta:logenvcost])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_5 = bmat[1,1]
	scalar V_d_5 = Vmat[1,1]
	
	return scalar d_env = b_d_5
	
    nlcom (_b[shlta:total_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logtotalgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logtotalcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[totalCI:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_4 = bmat[1,1]
    scalar V_i_4 = Vmat[1,1]
	
	return scalar i_ci = b_i_4
	
    nlcom (_b[logenvcost:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_5 = bmat[1,1]
    scalar V_i_5 = Vmat[1,1]	
	
	return scalar i_env = b_i_5
	
    nlcom (_b[total_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

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
	
	
    // Compute indirect effect
    scalar TIE = b_d_2 * b_i_2 + b_d_3 * b_i_3 + b_d_4 * b_i_4 + b_d_5 * b_i_5 + b_d_6 * b_i_6
    return scalar IE = TIE

    // Total effect
    scalar TE = TIE + b_d_1
    return scalar TE = TE

end


bootstrap DE=r(DE) IE=r(IE) TE=r(TE)   ///
D_gdp = r(d_gdp) D_car = r(d_car) D_ci = r(d_ci) D_env = r(d_env) D_med = r(d_med)    ///
I_gdp = r(i_gdp) I_car = r(i_car) I_ci = r(i_ci) I_env = r(i_env) I_med = r(i_med)   ///
C_gdp = r(c_gdp)    ///
S_gdp = r(s_gdp) S_car = r(s_car) S_env = r(s_env)      ///
, reps(500) seed(12345) saving(female) : boot_effects 

estat bootstrap

est sto female_boot
esttab female_boot using "female.csv", replace


/*
Bootstrap results                                       Number of obs = 85,756
                                                        Replications  =    500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             | coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .0340087   .0151731     2.24   0.025     .0042699    .0637474
          IE |  -.0022596    .002388    -0.95   0.344    -.0069401    .0024208
          TE |    .031749   .0146854     2.16   0.031     .0029661     .060532
       D_gdp |   .1851503   .0256314     7.22   0.000     .1349138    .2353869
       D_car |   .0862679   .0196358     4.39   0.000     .0477824    .1247533
        D_ci |  -.1294375   .0356719    -3.63   0.000    -.1993531    -.059522
       D_env |  -.0404701   .0127225    -3.18   0.001    -.0654057   -.0155346
       D_med |  -.0047874    .000595    -8.05   0.000    -.0059536   -.0036211
       I_gdp |    .018644   .0024403     7.64   0.000     .0138611    .0234269
       I_car |   .0784442   .0057047    13.75   0.000     .0672632    .0896252
        I_ci |    .069106   .0015216    45.42   0.000     .0661237    .0720883
       I_env |   .1329138    .004363    30.46   0.000     .1243626     .141465
       I_med |  -.3854205   .0848236    -4.54   0.000    -.5516718   -.2191693
       C_gdp |   .5076709   .0073595    68.98   0.000     .4932465    .5220953
       S_gdp |  -.5542818   .0029314  -189.09   0.000    -.5600272   -.5485364
       S_car |   .4931374   .0021673   227.54   0.000     .4888896    .4973852
       S_env |  -.0534587   .0014492   -36.89   0.000     -.056299   -.0506183
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     85,756
                                                Replications      =        500

      Command: boot_effects
           DE: r(DE)
           IE: r(IE)
           TE: r(TE)
        D_gdp: r(d_gdp)
        D_car: r(d_car)
         D_ci: r(d_ci)
        D_env: r(d_env)
        D_med: r(d_med)
        I_gdp: r(i_gdp)
        I_car: r(i_car)
         I_ci: r(i_ci)
        I_env: r(i_env)
        I_med: r(i_med)
        C_gdp: r(c_gdp)
        S_gdp: r(s_gdp)
        S_car: r(s_car)
        S_env: r(s_env)

------------------------------------------------------------------------------
             |    Observed               Bootstrap
             | coefficient       Bias    std. err.  [95% conf. interval]
-------------+----------------------------------------------------------------
          DE |   .03400867   .0003861   .01517312    .0066041   .0652066  (BC)
          IE |  -.00225965    .000129   .00238804   -.0069906   .0023588  (BC)
          TE |   .03174902   .0005152   .01468544    .0052979    .063475  (BC)
       D_gdp |   .18515032   .0012108   .02563136    .1336987   .2332278  (BC)
       D_car |   .08626786  -.0019185    .0196358    .0530363   .1319548  (BC)
        D_ci |  -.12943755   .0028828   .03567186   -.2064251  -.0687156  (BC)
       D_env |  -.04047015   .0005819   .01272245    -.066499   -.016236  (BC)
       D_med |  -.00478736   .0000148   .00059504   -.0059657  -.0037037  (BC)
       I_gdp |   .01864398   7.66e-06   .00244029    .0139663   .0233684  (BC)
       I_car |   .07844423   -.000087    .0057047     .066953   .0893965  (BC)
        I_ci |     .069106    .000026   .00152163    .0664449   .0720157  (BC)
       I_env |   .13291379  -.0001906   .00436296     .124884   .1419813  (BC)
       I_med |  -.38542053   .0009371   .08482364   -.5385063  -.2124918  (BC)
       C_gdp |   .50767087   .0001477   .00735952    .4925588   .5221672  (BC)
       S_gdp |   -.5542818    .000058   .00293138   -.5600266  -.5490382  (BC)
       S_car |    .4931374   .0000133    .0021673    .4888167   .4972451  (BC)
       S_env |  -.05345865    .000043   .00144917   -.0561272  -.0504392  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected



*/


