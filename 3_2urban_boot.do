


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

keep if urban_nbs == 1



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

    // Step 1: Direct effect
gsem (shlta <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.ragender i.year), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logurbangdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logurbancarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:urbanCI])
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
	
    nlcom (_b[shlta:urban_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logurbangdp <- NUPPdid lnurbanpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logurbancarbon <-NUPPdid logurbangdp lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(urbanCI <- NUPPdid logurbangdp logenvcost logurbancarbon lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(urban_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logurbangdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logurbancarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[urbanCI:NUPPdid])
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
	
    nlcom (_b[urban_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6
	
	
	nlcom (_b[logurbancarbon:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[urbanCI:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[urbanCI:logurbancarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[urbanCI:logenvcost])
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
, reps(500) seed(12345) saving(urban) : boot_effects 

estat bootstrap

est sto urban_boot
esttab urban_boot using "urban.csv"

/*
Bootstrap results                                       Number of obs = 31,529
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
          DE |   .0655884   .0208301     3.15   0.002     .0247623    .1064146
          IE |   .0364849   .0078441     4.65   0.000     .0211107     .051859
          TE |   .1020733   .0215788     4.73   0.000     .0597797    .1443669
       D_gdp |   .0535951   .0200002     2.68   0.007     .0143954    .0927949
       D_car |   .0047972   .0139574     0.34   0.731    -.0225587    .0321532
        D_ci |  -.0237514   .0101635    -2.34   0.019    -.0436715   -.0038312
       D_env |   .0183605   .0146651     1.25   0.211    -.0103827    .0471036
       D_med |   .0000241   .0003087     0.08   0.938    -.0005809    .0006291
       I_gdp |   .6540885   .0160696    40.70   0.000     .6225926    .6855843
       I_car |   .4597168   .0129785    35.42   0.000     .4342794    .4851541
        I_ci |   .0628614   .0076496     8.22   0.000     .0478686    .0778543
       I_env |   .0278492   .0072439     3.84   0.000     .0136515     .042047
       I_med |   8.517342   .4148409    20.53   0.000     7.704269    9.330415
       C_gdp |   1.419549   .0036936   384.33   0.000      1.41231    1.426788
       S_gdp |  -1.162942   .0190024   -61.20   0.000    -1.200186   -1.125698
       S_car |   .8879438   .0123798    71.73   0.000     .8636798    .9122078
       S_env |   -.015072   .0053404    -2.82   0.005    -.0255389   -.0046051
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     31,529
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
          DE |   .06558841  -5.45e-06   .02083005    .0269903   .1088664  (BC)
          IE |   .03648486   .0000212    .0078441    .0221633   .0515687  (BC)
          TE |   .10207328   .0000158   .02157877    .0597945   .1467783  (BC)
       D_gdp |   .05359512   .0009533   .02000025    .0132406   .0897235  (BC)
       D_car |   .00479725  -.0008236   .01395736   -.0198518    .034543  (BC)
        D_ci |  -.02375136   .0003839   .01016354   -.0457074   -.005477  (BC)
       D_env |   .01836047  -.0012166   .01466513   -.0066265   .0468496  (BC)
       D_med |    .0000241  -.0000255   .00030869    -.000487   .0006919  (BC)
       I_gdp |   .65408846  -.0000341    .0160696    .6264837    .687405  (BC)
       I_car |   .45971677   .0005322   .01297846     .434495   .4840612  (BC)
        I_ci |   .06286143  -.0000216   .00764957    .0487388   .0782568  (BC)
       I_env |   .02784924   .0002282   .00724388    .0135727   .0409087  (BC)
       I_med |   8.5173421  -.0007139   .41484093     7.66546   9.311409  (BC)
       C_gdp |    1.419549  -.0003143   .00369358    1.412916   1.427464  (BC)
       S_gdp |  -1.1629419  -.0001396   .01900241   -1.200435  -1.124201  (BC)
       S_car |   .88794379   .0001289   .01237983    .8631595    .913038  (BC)
       S_env |    -.015072  -.0001281   .00534036    -.026524  -.0054472  (BC)
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

keep if urban_nbs == 1



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

    // Step 1: Direct effect
gsem (shlta <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.year if ragender == 1), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logurbangdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logurbancarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:urbanCI])
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
	
    nlcom (_b[shlta:urban_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logurbangdp <- NUPPdid lnurbanpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logurbancarbon <-NUPPdid logurbangdp lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(urbanCI <- NUPPdid logurbangdp logenvcost logurbancarbon lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(urban_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logurbangdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logurbancarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[urbanCI:NUPPdid])
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
	
    nlcom (_b[urban_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6
	
	
	nlcom (_b[logurbancarbon:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[urbanCI:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[urbanCI:logurbancarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[urbanCI:logenvcost])
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
, reps(500) seed(12345) saving(urban_male) : boot_effects 

estat bootstrap

est sto urbanmale_boot
esttab urbanmale_boot using "urban_male.csv"


/*
Bootstrap results                                       Number of obs = 31,529
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
          DE |   .0705206    .031879     2.21   0.027     .0080389    .1330024
          IE |   .0248866   .0117775     2.11   0.035      .001803    .0479701
          TE |   .0954072   .0322974     2.95   0.003     .0321055    .1587089
       D_gdp |   .0133384   .0291174     0.46   0.647    -.0437307    .0704075
       D_car |   .0376728   .0202754     1.86   0.063    -.0020663    .0774118
        D_ci |  -.0425399   .0161927    -2.63   0.009    -.0742769   -.0108029
       D_env |    .022249   .0226338     0.98   0.326    -.0221124    .0666103
       D_med |   .0001054   .0004506     0.23   0.815    -.0007778    .0009886
       I_gdp |   .6540885   .0160696    40.70   0.000     .6225926    .6855843
       I_car |   .4597168   .0129785    35.42   0.000     .4342794    .4851541
        I_ci |   .0628614   .0076496     8.22   0.000     .0478686    .0778543
       I_env |   .0278492   .0072439     3.84   0.000     .0136515     .042047
       I_med |   8.517342   .4148409    20.53   0.000     7.704269    9.330415
       C_gdp |   1.419549   .0036936   384.33   0.000      1.41231    1.426788
       S_gdp |  -1.162942   .0190024   -61.20   0.000    -1.200186   -1.125698
       S_car |   .8879438   .0123798    71.73   0.000     .8636798    .9122078
       S_env |   -.015072   .0053404    -2.82   0.005    -.0255389   -.0046051
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     31,529
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
          DE |   .07052065  -.0014036   .03187901    .0124616   .1305978  (BC)
          IE |   .02488657  -.0009591   .01177754    .0013916   .0466674  (BC)
          TE |   .09540721  -.0023627   .03229738     .038672   .1621973  (BC)
       D_gdp |   .01333843  -.0021956   .02911743   -.0450632   .0697344  (BC)
       D_car |   .03767276   .0014686   .02027539   -.0019534   .0754694  (BC)
        D_ci |   -.0425399  -.0002798   .01619267   -.0720524   -.010644  (BC)
       D_env |   .02224896  -.0001637   .02263376   -.0229775   .0721744  (BC)
       D_med |    .0001054   -.000025   .00045063   -.0008306   .0010104  (BC)
       I_gdp |   .65408846  -.0000341    .0160696    .6264837    .687405  (BC)
       I_car |   .45971677   .0005322   .01297846     .434495   .4840612  (BC)
        I_ci |   .06286143  -.0000216   .00764957    .0487388   .0782568  (BC)
       I_env |   .02784924   .0002282   .00724388    .0135727   .0409087  (BC)
       I_med |   8.5173421  -.0007139   .41484093     7.66546   9.311409  (BC)
       C_gdp |    1.419549  -.0003143   .00369358    1.412916   1.427464  (BC)
       S_gdp |  -1.1629419  -.0001396   .01900241   -1.200435  -1.124201  (BC)
       S_car |   .88794379   .0001289   .01237983    .8631595    .913038  (BC)
       S_env |    -.015072  -.0001281   .00534036    -.026524  -.0054472  (BC)
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

keep if urban_nbs == 1



bysort year city: gen city_year_sample = _N



capture program drop boot_effects
program define boot_effects, rclass

    version 16.0

    // Step 1: Direct effect
gsem (shlta <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.year if ragender == 2), nocapslatent

    // Store direct effect and paths
    nlcom (_b[shlta:NUPPdid])
    
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_1 = bmat[1,1]
	scalar V_d_1 = Vmat[1,1]
	
	return scalar DE = b_d_1

    // Estimate coefficients of the mediators
    nlcom (_b[shlta:logurbangdp])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_2 = bmat[1,1]
	scalar V_d_2 = Vmat[1,1]
	
	return scalar d_gdp = b_d_2

    nlcom (_b[shlta:logurbancarbon])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_3 = bmat[1,1]
	scalar V_d_3 = Vmat[1,1]

	return scalar d_car = b_d_3
	
    nlcom (_b[shlta:urbanCI])
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
	
    nlcom (_b[shlta:urban_medbed_per])
    matrix bmat = r(b)
    matrix Vmat = r(V)
	scalar b_d_6 = bmat[1,1]
	scalar V_d_6 = Vmat[1,1]	
	
	return scalar d_med = b_d_6

    // Step 2: Mediator models with weights
	gsem (logurbangdp <- NUPPdid lnurbanpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
	(logurbancarbon <-NUPPdid logurbangdp lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
	(urbanCI <- NUPPdid logurbangdp logenvcost logurbancarbon lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
	(logenvcost <- NUPPdid lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
	(urban_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
	, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



    nlcom (_b[logurbangdp:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_2 = bmat[1,1]
    scalar V_i_2 = Vmat[1,1]

	return scalar i_gdp = b_i_2
	
    nlcom (_b[logurbancarbon:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_3 = bmat[1,1]
    scalar V_i_3 = Vmat[1,1]

	return scalar i_car = b_i_3
	
    nlcom (_b[urbanCI:NUPPdid])
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
	
    nlcom (_b[urban_medbed_per:NUPPdid])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_i_6 = bmat[1,1]
    scalar V_i_6 = Vmat[1,1]

	return scalar i_med = b_i_6

	
		
	nlcom (_b[logurbancarbon:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_c_1 = bmat[1,1]
    scalar V_c_1 = Vmat[1,1]
	
	return scalar c_gdp = b_c_1
	
	nlcom (_b[urbanCI:logurbangdp])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_1 = bmat[1,1]
    scalar V_s_1 = Vmat[1,1]
	
	return scalar s_gdp = b_s_1
	
	nlcom (_b[urbanCI:logurbancarbon])
	matrix bmat = r(b)
    matrix Vmat = r(V)
    scalar b_s_2 = bmat[1,1]
    scalar V_s_2 = Vmat[1,1]
	
	return scalar s_car = b_s_2
	
	nlcom (_b[urbanCI:logenvcost])
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
, reps(500) seed(12345) saving(urban_female) : boot_effects 

estat bootstrap

est sto urbanfemale_boot
esttab urbanfemale_boot using "urban_female.csv"



/*
Bootstrap results                                       Number of obs = 31,529
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
          DE |   .0605582   .0279308     2.17   0.030     .0058149    .1153016
          IE |   .0451929   .0105132     4.30   0.000     .0245875    .0657983
          TE |   .1057511   .0293633     3.60   0.000     .0482001    .1633021
       D_gdp |   .0839341   .0262777     3.19   0.001     .0324308    .1354374
       D_car |  -.0214974   .0182582    -1.18   0.239    -.0572828    .0142881
        D_ci |  -.0092489   .0132248    -0.70   0.484     -.035169    .0166711
       D_env |   .0143132   .0198858     0.72   0.472    -.0246623    .0532887
       D_med |    .000042   .0004017     0.10   0.917    -.0007452    .0008293
       I_gdp |   .6540885   .0160696    40.70   0.000     .6225926    .6855843
       I_car |   .4597168   .0129785    35.42   0.000     .4342794    .4851541
        I_ci |   .0628614   .0076496     8.22   0.000     .0478686    .0778543
       I_env |   .0278492   .0072439     3.84   0.000     .0136515     .042047
       I_med |   8.517342   .4148409    20.53   0.000     7.704269    9.330415
       C_gdp |   1.419549   .0036936   384.33   0.000      1.41231    1.426788
       S_gdp |  -1.162942   .0190024   -61.20   0.000    -1.200186   -1.125698
       S_car |   .8879438   .0123798    71.73   0.000     .8636798    .9122078
       S_env |   -.015072   .0053404    -2.82   0.005    -.0255389   -.0046051
------------------------------------------------------------------------------

. 
. estat bootstrap

Bootstrap results                               Number of obs     =     31,529
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
          DE |   .06055823  -.0012319    .0279308    .0049166   .1133384  (BC)
          IE |   .04519286   .0002311   .01051315    .0228115   .0643264  (BC)
          TE |   .10575109  -.0010009    .0293633    .0428928   .1605065  (BC)
       D_gdp |   .08393408   .0003638   .02627769    .0262518   .1322056  (BC)
       D_car |  -.02149738   .0002156   .01825821   -.0573811   .0142833  (BC)
        D_ci |  -.00924892   .0000921   .01322476   -.0350621   .0166174  (BC)
       D_env |   .01431316  -.0014948   .01988582   -.0250895    .053319  (BC)
       D_med |   .00004204  -7.67e-06   .00040166   -.0007734   .0007326  (BC)
       I_gdp |   .65408846  -.0000341    .0160696    .6264837    .687405  (BC)
       I_car |   .45971677   .0005322   .01297846     .434495   .4840612  (BC)
        I_ci |   .06286143  -.0000216   .00764957    .0487388   .0782568  (BC)
       I_env |   .02784924   .0002282   .00724388    .0135727   .0409087  (BC)
       I_med |   8.5173421  -.0007139   .41484093     7.66546   9.311409  (BC)
       C_gdp |    1.419549  -.0003143   .00369358    1.412916   1.427464  (BC)
       S_gdp |  -1.1629419  -.0001396   .01900241   -1.200435  -1.124201  (BC)
       S_car |   .88794379   .0001289   .01237983    .8631595    .913038  (BC)
       S_env |    -.015072  -.0001281   .00534036    -.026524  -.0054472  (BC)
------------------------------------------------------------------------------
Key: BC: Bias-corrected



*/












