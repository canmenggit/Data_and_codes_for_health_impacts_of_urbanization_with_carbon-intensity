


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

keep if urban_nbs == 0



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

   
    // Step 1: Direct effect
gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.ragender i.year), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logruralgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logruralcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:ruralCI])
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
	
    nlcom (_b[shlta:rural_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logruralgdp <- NUPPdid lnruralpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logruralcarbon <-NUPPdid logruralgdp lnruralpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(ruralCI <- NUPPdid logruralgdp logenvcost logruralcarbon lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(rural_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logruralgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logruralcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[ruralCI:NUPPdid])
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
	
    nlcom (_b[rural_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6
	
	
	
		
	nlcom (_b[logruralcarbon:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[ruralCI:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[ruralCI:logruralcarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[ruralCI:logenvcost])
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
, reps(500) seed(12345) saving(rural) : boot_effects 

estat bootstrap

est sto rural_boot
esttab rural_boot using "rural.csv"


/*
Bootstrap results                                       Number of obs = 45,547
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
          DE |   .0481225   .0154942     3.11   0.002     .0177543    .0784907
          IE |  -.0147851    .003751    -3.94   0.000    -.0221369   -.0074333
          TE |   .0333374   .0153534     2.17   0.030     .0032452    .0634296
       D_gdp |   .0582258   .0259622     2.24   0.025      .007341    .1091107
       D_car |   .1425189   .0177153     8.04   0.000     .1077976    .1772403
        D_ci |   -.243398   .0379811    -6.41   0.000    -.3178397   -.1689564
       D_env |  -.0648473   .0134977    -4.80   0.000    -.0913022   -.0383923
       D_med |  -.0015403   .0003363    -4.58   0.000    -.0021994   -.0008811
       I_gdp |  -.0045406   .0025967    -1.75   0.080    -.0096299    .0005488
       I_car |  -.0734922   .0076422    -9.62   0.000    -.0884708   -.0585137
        I_ci |   .0078821   .0013066     6.03   0.000     .0053212    .0104431
       I_env |   .1585406   .0055327    28.66   0.000     .1476967    .1693846
       I_med |  -5.293044   .2731557   -19.38   0.000    -5.828419   -4.757669
       C_gdp |  -.0683697   .0112781    -6.06   0.000    -.0904744   -.0462651
       S_gdp |  -.4376757   .0048458   -90.32   0.000    -.4471733   -.4281781
       S_car |   .4145362   .0020515   202.06   0.000     .4105152    .4185571
       S_env |  -.0239317   .0014938   -16.02   0.000    -.0268596   -.0210038
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     45,547
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
          DE |    .0481225  -.0004329   .01549424    .0157742   .0795074  (BC)
          IE |  -.01478509  -.0000349   .00375101    -.021934  -.0072338  (BC)
          TE |   .03333741  -.0004677   .01535343    .0023274   .0631656  (BC)
       D_gdp |   .05822584   .0012449   .02596215    .0036925    .104159  (BC)
       D_car |   .14251895  -.0009282   .01771529    .1071275   .1754141  (BC)
        D_ci |  -.24339804   .0016106   .03798113   -.3238702  -.1719987  (BC)
       D_env |  -.06484726   6.36e-06   .01349768    -.091009  -.0398742  (BC)
       D_med |  -.00154028   .0000182   .00033631   -.0022087  -.0008183  (BC)
       I_gdp |  -.00454056    .000057   .00259667   -.0096629   .0004901  (BC)
       I_car |  -.07349224   .0001976   .00764225   -.0861698  -.0565379  (BC)
        I_ci |   .00788214   .0000177   .00130664    .0056056   .0108003  (BC)
       I_env |   .15854065   .0002757   .00553273      .14657    .169002  (BC)
       I_med |   -5.293044   .0196445   .27315572   -5.894139  -4.798183  (BC)
       C_gdp |   -.0683697  -.0005441   .01127809   -.0889744  -.0454204  (BC)
       S_gdp |  -.43767572  -.0000499   .00484579   -.4472888  -.4279853  (BC)
       S_car |   .41453618   5.33e-06   .00205153    .4106497   .4182358  (BC)
       S_env |  -.02393169  -.0000435   .00149385    -.026873  -.0208811  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected

. 



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

keep if urban_nbs == 0



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

   
    // Step 1: Direct effect
gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 1), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logruralgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logruralcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:ruralCI])
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
	
    nlcom (_b[shlta:rural_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logruralgdp <- NUPPdid lnruralpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logruralcarbon <-NUPPdid logruralgdp lnruralpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(ruralCI <- NUPPdid logruralgdp logenvcost logruralcarbon lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(rural_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logruralgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logruralcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[ruralCI:NUPPdid])
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
	
    nlcom (_b[rural_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6
	
		
	nlcom (_b[logruralcarbon:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[ruralCI:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[ruralCI:logruralcarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[ruralCI:logenvcost])
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
, reps(500) seed(12345) saving(rural_male) : boot_effects 

estat bootstrap

est sto ruralmale_boot
esttab ruralmale_boot using "rural_male.csv"



/*

Bootstrap results                                       Number of obs = 45,547
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
          DE |   .0782602   .0229165     3.42   0.001     .0333447    .1231757
          IE |  -.0267413   .0060169    -4.44   0.000    -.0385342   -.0149485
          TE |   .0515189   .0229511     2.24   0.025     .0065356    .0965022
       D_gdp |  -.0141024   .0377459    -0.37   0.709    -.0880831    .0598783
       D_car |   .1756358   .0278152     6.31   0.000      .121119    .2301527
        D_ci |  -.2473077    .054263    -4.56   0.000    -.3536611   -.1409542
       D_env |  -.0941895    .020412    -4.61   0.000    -.1341962   -.0541828
       D_med |  -.0005639     .00055    -1.03   0.305    -.0016419    .0005141
       I_gdp |  -.0045406   .0025967    -1.75   0.080    -.0096299    .0005488
       I_car |  -.0734922   .0076422    -9.62   0.000    -.0884708   -.0585137
        I_ci |   .0078821   .0013066     6.03   0.000     .0053212    .0104431
       I_env |   .1585406   .0055327    28.66   0.000     .1476967    .1693846
       I_med |  -5.293044   .2731557   -19.38   0.000    -5.828419   -4.757669
       C_gdp |  -.0683697   .0112781    -6.06   0.000    -.0904744   -.0462651
       S_gdp |  -.4376757   .0048458   -90.32   0.000    -.4471733   -.4281781
       S_car |   .4145362   .0020515   202.06   0.000     .4105152    .4185571
       S_env |  -.0239317   .0014938   -16.02   0.000    -.0268596   -.0210038
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     45,547
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
          DE |   .07826022  -.0002555   .02291651     .035817   .1235888  (BC)
          IE |  -.02674131  -.0000238   .00601687   -.0393114  -.0152444  (BC)
          TE |   .05151891  -.0002793    .0229511    .0086669   .0935405  (BC)
       D_gdp |  -.01410241  -.0009912   .03774593   -.0896362   .0622533  (BC)
       D_car |   .17563583   .0005115   .02781523    .1220451   .2315813  (BC)
        D_ci |  -.24730767  -.0006256   .05426296   -.3580646   -.142324  (BC)
       D_env |  -.09418949  -.0004747   .02041197   -.1320016  -.0516235  (BC)
       D_med |  -.00056389  -.0000239   .00055001   -.0016332   .0004989  (BC)
       I_gdp |  -.00454056    .000057   .00259667   -.0096629   .0004901  (BC)
       I_car |  -.07349224   .0001976   .00764225   -.0861698  -.0565379  (BC)
        I_ci |   .00788214   .0000177   .00130664    .0056056   .0108003  (BC)
       I_env |   .15854065   .0002757   .00553273      .14657    .169002  (BC)
       I_med |   -5.293044   .0196445   .27315572   -5.894139  -4.798183  (BC)
       C_gdp |   -.0683697  -.0005441   .01127809   -.0889744  -.0454204  (BC)
       S_gdp |  -.43767572  -.0000499   .00484579   -.4472888  -.4279853  (BC)
       S_car |   .41453618   5.33e-06   .00205153    .4106497   .4182358  (BC)
       S_env |  -.02393169  -.0000435   .00149385    -.026873  -.0208811  (BC)
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

keep if urban_nbs == 0



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

   
    // Step 1: Direct effect
gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 2), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logruralgdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logruralcarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:ruralCI])
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
	
    nlcom (_b[shlta:rural_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logruralgdp <- NUPPdid lnruralpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logruralcarbon <-NUPPdid logruralgdp lnruralpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(ruralCI <- NUPPdid logruralgdp logenvcost logruralcarbon lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(rural_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logruralgdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logruralcarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[ruralCI:NUPPdid])
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
	
    nlcom (_b[rural_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6
	
	
		
	nlcom (_b[logruralcarbon:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[ruralCI:logruralgdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[ruralCI:logruralcarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[ruralCI:logenvcost])
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
, reps(500) seed(12345) saving(rural_female) : boot_effects 

estat bootstrap

est sto ruralfemale_boot
esttab ruralfemale_boot using "rural_female.csv"




/*
Bootstrap results                                       Number of obs = 45,547
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
          DE |   .0215594   .0191103     1.13   0.259    -.0158962     .059015
          IE |  -.0041806   .0051556    -0.81   0.417    -.0142854    .0059241
          TE |   .0173787   .0185671     0.94   0.349     -.019012    .0537695
       D_gdp |   .1217488   .0355129     3.43   0.001     .0521448    .1913528
       D_car |   .1144499   .0245794     4.66   0.000     .0662753    .1626246
        D_ci |  -.2419023    .052274    -4.63   0.000    -.3443575   -.1394472
       D_env |  -.0383534   .0186309    -2.06   0.040    -.0748692   -.0018375
       D_med |  -.0024127   .0004857    -4.97   0.000    -.0033648   -.0014607
       I_gdp |  -.0045406   .0025967    -1.75   0.080    -.0096299    .0005488
       I_car |  -.0734922   .0076422    -9.62   0.000    -.0884708   -.0585137
        I_ci |   .0078821   .0013066     6.03   0.000     .0053212    .0104431
       I_env |   .1585406   .0055327    28.66   0.000     .1476967    .1693846
       I_med |  -5.293044   .2731557   -19.38   0.000    -5.828419   -4.757669
       C_gdp |  -.0683697   .0112781    -6.06   0.000    -.0904744   -.0462651
       S_gdp |  -.4376757   .0048458   -90.32   0.000    -.4471733   -.4281781
       S_car |   .4145362   .0020515   202.06   0.000     .4105152    .4185571
       S_env |  -.0239317   .0014938   -16.02   0.000    -.0268596   -.0210038
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     45,547
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
          DE |   .02155936  -.0007539   .01911035   -.0136954   .0638389  (BC)
          IE |  -.00418061  -.0004648   .00515558   -.0137709   .0063935  (BC)
          TE |   .01737875  -.0012187   .01856707   -.0154386   .0589009  (BC)
       D_gdp |   .12174882  -.0010965    .0355129    .0539395   .1950323  (BC)
       D_car |   .11444991   .0004091   .02457935    .0724991   .1694202  (BC)
        D_ci |  -.24190234  -.0030851   .05227398   -.3515959  -.1492703  (BC)
       D_env |  -.03835336  -.0012124   .01863086   -.0720604   .0032797  (BC)
       D_med |  -.00241272   .0000342   .00048574   -.0034274  -.0014428  (BC)
       I_gdp |  -.00454056    .000057   .00259667   -.0096629   .0004901  (BC)
       I_car |  -.07349224   .0001976   .00764225   -.0861698  -.0565379  (BC)
        I_ci |   .00788214   .0000177   .00130664    .0056056   .0108003  (BC)
       I_env |   .15854065   .0002757   .00553273      .14657    .169002  (BC)
       I_med |   -5.293044   .0196445   .27315572   -5.894139  -4.798183  (BC)
       C_gdp |   -.0683697  -.0005441   .01127809   -.0889744  -.0454204  (BC)
       S_gdp |  -.43767572  -.0000499   .00484579   -.4472888  -.4279853  (BC)
       S_car |   .41453618   5.33e-06   .00205153    .4106497   .4182358  (BC)
       S_env |  -.02393169  -.0000435   .00149385    -.026873  -.0208811  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected




*/










