
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

keep if urban_nbs == 0

*---------------------------------- Rural Total ----------------------------------- 



* Step 1: calculate the individual effect
	// encode city,gen (city_id) - not concave at individual level

gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.ragender i.year), nocapslatent

est store model_rural_DE
estadd local type "rural"

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

nlcom (_b[shlta:logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:rural_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)


*  Step2 : calculate the city-level effects, so applied frequency weight


// generate urban weight (by year and by city)
bysort year city: gen city_year_sample = _N

gsem (logruralgdp <- NUPPdid lnruralpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
(logruralcarbon <-NUPPdid logruralgdp lnruralpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
(ruralCI <- NUPPdid logruralgdp logruralcarbon logenvcost lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
(logenvcost <- NUPPdid lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
(rural_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



est store model_rural_IE

nlcom (_b[logruralgdp:NUPPdid])
matrix b_i_2 = r(b)
matrix V_i_2 = r(V)

nlcom (_b[logruralcarbon:NUPPdid])
matrix b_i_3 = r(b)
matrix V_i_3 = r(V)

nlcom (_b[ruralCI:NUPPdid])
matrix b_i_4 = r(b)
matrix V_i_4 = r(V)

nlcom (_b[logenvcost:NUPPdid])
matrix b_i_5 = r(b)
matrix V_i_5 = r(V)

nlcom (_b[rural_medbed_per:NUPPdid])
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

*----------------------------------- Male ----------------------------------

* Step 1: calculate the individual effect


gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 1), nocapslatent

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

nlcom (_b[shlta:logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:rural_medbed_per])
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

gsem (shlta <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 2), nocapslatent

est store model_female_DE
estadd local type "female"

nlcom (_b[shlta:NUPPdid])
matrix b_d_1 = r(b)
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


nlcom (_b[shlta:logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[shlta:logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[shlta:ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[shlta:logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[shlta:rural_medbed_per])
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

esttab model_rural* model_male* model_female* using $tbls/SEM_rural.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
stats(type aic bic N IE IE_sd IE_p IE_cil IE_ciu DE DE_sd DE_p DE_cil DE_ciu TE TE_sd TE_p TE_cil TE_ciu prop,  fmt(%9s %9.0f %9.0f %9.0f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f  %9.3f %9.3f %9.3f) labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "IE sd" "P for IE" "lowerCI for IE" "upperCI for IE" "Direct Effect" "DE sd" "P for DE" "lowerCI for DE" "upperCI for DE" "Total Effect" "TE sd" "P for TE" "lowerCI for TE" "upperCI for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logruralcarbon ruralCI logruralgdp rural_medbed_per)





*---------------------------------- rural DDD ----------------------------------- 

//gender
gen male = (ragender == 1)
gen NUPPdid_male = NUPPdid*male



gsem (shlta <- NUPPdid_male logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year), nocapslatent

est store model_male_ddd
estadd local type "rural_gender_ddd"



esttab model_male_ddd using $tbls/SEM_rural_ddd.csv, replace se label star(* 0.1 ** 0.05 *** 0.01)  stats(N aic bic type,fmt(%9.0f %9.0f %9.0f %9s)) keep(NUPPdid_male logenvcost logruralcarbon ruralCI logruralgdp rural_medbed_per)

