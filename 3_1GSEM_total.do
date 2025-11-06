
clear all

global path [YOUR PATH]

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables/0509SEM
global grp $path/Graphs


use $svd/2_Nupp_CarbonGDP_charls_merged.dta


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

*------------------------------------------------------------------------------------------------------------
*-------------------------------------Method 2 : Combined the result from two steps -------------------------
*-------------------------------------------------------------------------------------------------------------


*---------------------------------- Total ----------------------------------- 



* Step 1: calculate the individual effect
	// encode city,gen (city_id) - not concave at individual level

gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.urban_nbs i.year), nocapslatent

est store model_total_DE
estadd local type "total"

nlcom (_b[shlta:NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]
scalar DE_var = sqrt(V_d_1[1,1])


scalar ci95_u = DE+1.96*std_err
scalar ci95_l = DE-1.96*std_err


estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue
estadd scalar DE_sd std_err
estadd scalar DE_ciu ci95_u
estadd scalar DE_cil ci95_l

nlcom (_b[shlta:logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



*  Step2 : calculate the city-level effects, so applied frequency weight


// generate total weight (by year and by city)
bysort year city: gen city_year_sample = _N

gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
(logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
(totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
(logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
(total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



est store model_total_IE

nlcom (_b[logtotalgdp:NUPPdid])
matrix b_i_2 = r(b)
matrix V_i_2 = r(V)

nlcom (_b[logtotalcarbon:NUPPdid])
matrix b_i_3 = r(b)
matrix V_i_3 = r(V)

nlcom (_b[totalCI:NUPPdid])
matrix b_i_4 = r(b)
matrix V_i_4 = r(V)

nlcom (_b[logenvcost:NUPPdid])
matrix b_i_5 = r(b)
matrix V_i_5 = r(V)

nlcom (_b[total_medbed_per:NUPPdid])
matrix b_i_6 = r(b)
matrix V_i_6 = r(V)


*****************
*indirect effect*
*****************

scalar TIE =    ///
b_d_2[1,1] * b_i_2[1,1] +    ///
b_d_3[1,1] * b_i_3[1,1] +    ///
b_d_4[1,1] * b_i_4[1,1] +    ///
b_d_5[1,1] * b_i_5[1,1] +    ///
b_d_6[1,1] * b_i_6[1,1] 



scalar TIE_var =      ///
V_d_2[1,1] * b_i_2[1,1] * b_i_2[1,1]  +   V_i_2[1,1] * b_d_2[1,1] * b_d_2[1,1] +   ///
V_d_3[1,1] * b_i_3[1,1] * b_i_3[1,1]  +   V_i_3[1,1] * b_d_3[1,1] * b_d_3[1,1] +  ///
V_d_4[1,1] * b_i_4[1,1] * b_i_4[1,1]  +   V_i_4[1,1] * b_d_4[1,1] * b_d_4[1,1] +   ///
V_d_5[1,1] * b_i_5[1,1] * b_i_5[1,1]  +   V_i_5[1,1] * b_d_5[1,1] * b_d_5[1,1] +  ///
V_d_6[1,1] * b_i_6[1,1] * b_i_6[1,1]  +   V_i_6[1,1] * b_d_6[1,1] * b_d_6[1,1] 

scalar std_err = sqrt(TIE_var)


scalar z = TIE/std_err
scalar pvalue = 2 * normal(-abs(z))

scalar ci95_u = TIE+(1.96*std_err)
scalar ci95_l = TIE-(1.96*std_err)


estadd scalar IE = TIE
estadd scalar IE_p pvalue
estadd scalar IE_sd std_err
estadd scalar IE_ciu ci95_u
estadd scalar IE_cil ci95_l

*****************
*total effect*
*****************

scalar TE = TIE+DE
scalar TE_var = TIE_var + DE_var

scalar std_err = sqrt(TE_var)
scalar z = TE/std_err
scalar pvalue = 2 * normal(-abs(z))
scalar ci95_u = TE+1.96*std_err
scalar ci95_l = TE-1.96*std_err


estadd scalar TE = TE
estadd scalar TE_p pvalue
estadd scalar TE_sd std_err
estadd scalar TE_ciu ci95_u
estadd scalar TE_cil ci95_l

estadd local prop = TIE/TE

* esttab model_total* using $tbls/SEM_total.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
* stats(type aic bic N IE IE_p DE DE_p TE TE_p prop, labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "P for IE" "Direct Effect" "P for DE" "Total Effect" "P for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logtotalcarbon totalCI logtotalgdp total_medbed_per arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke)


*----------------------------------- Male ----------------------------------
* ！ City-level effect does not varied between genders, so coefficients from NUPPdid-> logtotalgdp, logtotalcarbon, totalCI, logenvoces, and total_medbed_per are the same for male and female subsample.


* Step 1: calculate the individual effect

gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 1), nocapslatent

est store model_male_DE
estadd local type "male"

nlcom (_b[shlta:NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))



scalar DE = r(b)[1,1]
scalar DE_var = sqrt(V_d_1[1,1])


scalar ci95_u = DE+1.96*std_err
scalar ci95_l = DE-1.96*std_err


estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue
estadd scalar DE_sd std_err
estadd scalar DE_ciu ci95_u
estadd scalar DE_cil ci95_l

nlcom (_b[shlta:logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)

* Step 2 : combined the effect

*****************
*indirect effect*
*****************

scalar TIE =    ///
b_d_2[1,1] * b_i_2[1,1] +    ///
b_d_3[1,1] * b_i_3[1,1] +    ///
b_d_4[1,1] * b_i_4[1,1] +    ///
b_d_5[1,1] * b_i_5[1,1] +    ///
b_d_6[1,1] * b_i_6[1,1] 



scalar TIE_var =      ///
V_d_2[1,1] * b_i_2[1,1] * b_i_2[1,1]  +   V_i_2[1,1] * b_d_2[1,1] * b_d_2[1,1] +   ///
V_d_3[1,1] * b_i_3[1,1] * b_i_3[1,1]  +   V_i_3[1,1] * b_d_3[1,1] * b_d_3[1,1] +  ///
V_d_4[1,1] * b_i_4[1,1] * b_i_4[1,1]  +   V_i_4[1,1] * b_d_4[1,1] * b_d_4[1,1] +   ///
V_d_5[1,1] * b_i_5[1,1] * b_i_5[1,1]  +   V_i_5[1,1] * b_d_5[1,1] * b_d_5[1,1] +  ///
V_d_6[1,1] * b_i_6[1,1] * b_i_6[1,1]  +   V_i_6[1,1] * b_d_6[1,1] * b_d_6[1,1] 

scalar std_err = sqrt(TIE_var)


scalar z = TIE/std_err
scalar pvalue = 2 * normal(-abs(z))

scalar ci95_u = TIE+(1.96*std_err)
scalar ci95_l = TIE-(1.96*std_err)


estadd scalar IE = TIE
estadd scalar IE_p pvalue
estadd scalar IE_sd std_err
estadd scalar IE_ciu ci95_u
estadd scalar IE_cil ci95_l

*****************
*total effect*
*****************

scalar TE = TIE+DE
scalar TE_var = TIE_var + DE_var

scalar std_err = sqrt(TE_var)
scalar z = TE/std_err
scalar pvalue = 2 * normal(-abs(z))
scalar ci95_u = TE+1.96*std_err
scalar ci95_l = TE-1.96*std_err


estadd scalar TE = TE
estadd scalar TE_p pvalue
estadd scalar TE_sd std_err
estadd scalar TE_ciu ci95_u
estadd scalar TE_cil ci95_l

estadd local prop = TIE/TE


* ----------------------------- female ---------------------------------------

* Step 1: calculate the individual effect

gsem (shlta <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 2), nocapslatent

est store model_female_DE
estadd local type "female"

nlcom (_b[shlta:NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))



scalar DE = r(b)[1,1]
scalar DE_var = sqrt(V_d_1[1,1])


scalar ci95_u = DE+1.96*std_err
scalar ci95_l = DE-1.96*std_err


estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue
estadd scalar DE_sd std_err
estadd scalar DE_ciu ci95_u
estadd scalar DE_cil ci95_l

nlcom (_b[shlta:logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)

* Step 2 : combined the effect

*****************
*indirect effect*
*****************

scalar TIE =    ///
b_d_2[1,1] * b_i_2[1,1] +    ///
b_d_3[1,1] * b_i_3[1,1] +    ///
b_d_4[1,1] * b_i_4[1,1] +    ///
b_d_5[1,1] * b_i_5[1,1] +    ///
b_d_6[1,1] * b_i_6[1,1] 



scalar TIE_var =      ///
V_d_2[1,1] * b_i_2[1,1] * b_i_2[1,1]  +   V_i_2[1,1] * b_d_2[1,1] * b_d_2[1,1] +   ///
V_d_3[1,1] * b_i_3[1,1] * b_i_3[1,1]  +   V_i_3[1,1] * b_d_3[1,1] * b_d_3[1,1] +  ///
V_d_4[1,1] * b_i_4[1,1] * b_i_4[1,1]  +   V_i_4[1,1] * b_d_4[1,1] * b_d_4[1,1] +   ///
V_d_5[1,1] * b_i_5[1,1] * b_i_5[1,1]  +   V_i_5[1,1] * b_d_5[1,1] * b_d_5[1,1] +  ///
V_d_6[1,1] * b_i_6[1,1] * b_i_6[1,1]  +   V_i_6[1,1] * b_d_6[1,1] * b_d_6[1,1] 

scalar std_err = sqrt(TIE_var)


scalar z = TIE/std_err
scalar pvalue = 2 * normal(-abs(z))

scalar ci95_u = TIE+(1.96*std_err)
scalar ci95_l = TIE-(1.96*std_err)


estadd scalar IE = TIE
estadd scalar IE_p pvalue
estadd scalar IE_sd std_err
estadd scalar IE_ciu ci95_u
estadd scalar IE_cil ci95_l

*****************
*total effect*
*****************

scalar TE = TIE+DE
scalar TE_var = TIE_var + DE_var

scalar std_err = sqrt(TE_var)
scalar z = TE/std_err
scalar pvalue = 2 * normal(-abs(z))
scalar ci95_u = TE+1.96*std_err
scalar ci95_l = TE-1.96*std_err


estadd scalar TE = TE
estadd scalar TE_p pvalue
estadd scalar TE_sd std_err
estadd scalar TE_ciu ci95_u
estadd scalar TE_cil ci95_l

estadd local prop = TIE/TE
esttab model_total* model_male* model_female* using $tbls/SEM_total.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
stats(type aic bic N IE IE_p IE_cil IE_ciu DE DE_p DE_cil DE_ciu TE TE_p TE_cil TE_ciu prop,  fmt(%9s %9.0f %9.0f %9.0f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f) labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "P for IE" "lowerCI for IE" "upperCI for IE" "Direct Effect" "P for DE" "lowerCI for DE" "upperCI for DE" "Total Effect" "P for TE" "lowerCI for TE" "upperCI for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logtotalcarbon totalCI logtotalgdp total_medbed_per)




*---------------------------------- Total DDD ----------------------------------- 

//gender
gen male = (ragender == 1)
gen NUPPdid_male = NUPPdid*male



gsem (shlta <- NUPPdid_male logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year), nocapslatent

est store model_male_ddd
estadd local type "total_gender_ddd"

//rural-urban
gen urban = (urban_nbs == 1)
gen NUPPdid_urban = NUPPdid*urban


gsem (shlta <- NUPPdid_urban logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.year), nocapslatent

est store model_urban_ddd
estadd local type "total_urban_ddd"


esttab model_male_ddd model_urban_ddd using $tbls/SEM_total_ddd.csv, replace se label star(* 0.1 ** 0.05 *** 0.01)  stats(N aic bic type,fmt(%9.0f %9.0f %9.0f %9s)) keep(NUPPdid_* logenvcost logtotalcarbon totalCI logtotalgdp total_medbed_per)
