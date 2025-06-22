
*arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke

*******************************************************************************************
*                                       Total                                             *
*******************************************************************************************


clear all

global path [YOUR PATH]

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables/0511SEM_bydisease
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

*-------------------------------------------------------------------------
*----------------------------- City-level --------------------------------
*-------------------------------------------------------------------------


// generate total weight (by year and by city)
bysort year city: gen city_year_sample = _N

gsem (logtotalgdp <- NUPPdid lntotalpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
(logtotalcarbon <-NUPPdid logtotalgdp lntotalpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
(totalCI <- NUPPdid logtotalgdp logenvcost logtotalcarbon lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
(logenvcost <- NUPPdid lntotalpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
(total_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



est store total_IE

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


*-------------------------------------------------------------------------
*----------------------- Individual-level --------------------------------
*-------------------------------------------------------------------------


// TOTAL

foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	
	

gsem (`dis' <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.urban_nbs i.year, logit), nocapslatent

est store total_DE_`dis'
estadd local type "total_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE



// Male


gsem (`dis' <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 1, logit), nocapslatent


est store male_DE_`dis'
estadd local type "male_`dis'"



nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE




// Female




gsem (`dis' <- NUPPdid logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year if ragender == 2, logit), nocapslatent


est store female_DE_`dis'
estadd local type "female_`dis'"



nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logtotalgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logtotalcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':totalCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':total_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE



}

esttab total_IE total_DE* male_DE* female_DE* using $tbls/SEM_total.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
stats(type aic bic N IE IE_p DE DE_p TE TE_p prop,  fmt(%9s %9.0f %9.0f %9.0f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f) labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "P for IE" "Direct Effect" "P for DE" "Total Effect" "P for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logtotalcarbon totalCI logtotalgdp total_medbed_per)

estimates clear


*---------------------------------- Total DDD ----------------------------------- 

//gender
gen male = (ragender == 1)
gen NUPPdid_male = NUPPdid*male

gen urban = (urban_nbs == 1)
gen NUPPdid_urban = NUPPdid*urban


foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	
	
gsem (`dis' <- NUPPdid_male logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.urban_nbs i.year, logit), nocapslatent

est store model_male_`dis'
estadd local type "gender_`dis'"

//rural-urban


gsem (`dis' <- NUPPdid_urban logtotalgdp logtotalcarbon totalCI logenvcost total_medbed_per raeducl age rahltcom hukou lngovspend lntotalpop lnmedppl i.ragender i.year, logit), nocapslatent

est store model_urban_`dis'
estadd local type "urban_`dis'"
}

esttab model_male* model_urban* using $tbls/SEM_total_ddd.csv, replace se label star(* 0.1 ** 0.05 *** 0.01)  stats(N aic bic type,fmt(%9.0f %9.0f %9.0f %9s)) keep(NUPPdid_* logenvcost logtotalcarbon totalCI logtotalgdp total_medbed_per)













*******************************************************************************************
*                                       Urban                                             *
*******************************************************************************************


clear all

global path /Users/yuxinyuan/Desktop/DING/0403NupCarbon

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables/0511SEM_bydisease
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

keep if urban_nbs == 1


*-------------------------------------------------------------------------
*----------------------------- City-level --------------------------------
*-------------------------------------------------------------------------


// generate urban weight (by year and by city)
bysort year city: gen city_year_sample = _N

gsem (logurbangdp <- NUPPdid lnurbanpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
(logurbancarbon <-NUPPdid logurbangdp lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
(urbanCI <- NUPPdid logurbangdp logenvcost logurbancarbon lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
(logenvcost <- NUPPdid lnurbanpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
(urban_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



est store urban_IE

nlcom (_b[logurbangdp:NUPPdid])
matrix b_i_2 = r(b)
matrix V_i_2 = r(V)

nlcom (_b[logurbancarbon:NUPPdid])
matrix b_i_3 = r(b)
matrix V_i_3 = r(V)

nlcom (_b[urbanCI:NUPPdid])
matrix b_i_4 = r(b)
matrix V_i_4 = r(V)

nlcom (_b[logenvcost:NUPPdid])
matrix b_i_5 = r(b)
matrix V_i_5 = r(V)

nlcom (_b[urban_medbed_per:NUPPdid])
matrix b_i_6 = r(b)
matrix V_i_6 = r(V)


*-------------------------------------------------------------------------
*----------------------- Individual-level --------------------------------
*-------------------------------------------------------------------------


// TOTAL

foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	
	
gsem (`dis' <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.ragender i.year, logit), nocapslatent

est store urban_DE_`dis'
estadd local type "urban_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logurbangdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logurbancarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':urbanCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':urban_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE


//male


gsem (`dis' <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.year if ragender == 1, logit), nocapslatent

est store male_DE_`dis'
estadd local type "male_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logurbangdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logurbancarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':urbanCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':urban_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE




//female


gsem (`dis' <- NUPPdid logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.year if ragender == 2, logit), nocapslatent

est store female_DE_`dis'
estadd local type "female_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logurbangdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logurbancarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':urbanCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':urban_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE
}




esttab urban_IE urban_DE* male_DE* female_DE* using $tbls/SEM_urban.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
stats(type aic bic N IE IE_p DE DE_p TE TE_p prop,  fmt(%9s %9.0f %9.0f %9.0f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f) labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "P for IE" "Direct Effect" "P for DE" "Total Effect" "P for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logurbancarbon urbanCI logurbangdp urban_medbed_per)

estimates clear


*---------------------------------- URBAN DDD ----------------------------------- 

//gender
gen male = (ragender == 1)
gen NUPPdid_male = NUPPdid*male

foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	

gsem (`dis' <- NUPPdid_male logurbangdp logurbancarbon urbanCI logenvcost urban_medbed_per raeducl age rahltcom hukou lngovspend lnurbanpop lnmedppl i.year, logit), nocapslatent

est store model_male_`dis'
estadd local type "gender_`dis'"

}

esttab model_male* using $tbls/SEM_urban_ddd.csv, replace se label star(* 0.1 ** 0.05 *** 0.01)  stats(N aic bic type,fmt(%9.0f %9.0f %9.0f %9s)) keep(NUPPdid_male logenvcost logurbancarbon urbanCI logurbangdp urban_medbed_per)













*******************************************************************************************
*                                       Rural                                             *
*******************************************************************************************


clear all

global path /Users/yuxinyuan/Desktop/DING/0403NupCarbon

global raw $path/RawData
global wrk $path/WorkData
global svd $path/SaveData


global tbls $path/Tables/0511SEM_bydisease
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

keep if urban_nbs == 0






*-------------------------------------------------------------------------
*----------------------------- City-level --------------------------------
*-------------------------------------------------------------------------


// generate weight (by year and by city)
bysort year city: gen city_year_sample = _N

gsem (logruralgdp <- NUPPdid lnruralpop lngovspen lnmedppl tech_ratio edu_ratio)    ///
(logruralcarbon <-NUPPdid logruralgdp lnruralpop lngovspend lnmedppl tech_ratio edu_ratio i.year)     ///
(ruralCI <- NUPPdid logruralgdp logenvcost logruralcarbon lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)       ///
(logenvcost <- NUPPdid lnruralpop lngovspend lnmedppl tech_ratio edu_ratio)   ////
(rural_medbed_per <- NUPPdid lngovspend lnmedppl tech_ratio edu_ratio)    ///
, covstruct(_lexogenous, diagonal) fweight(city_year_sample) nocapslatent



est store rural_IE

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



*-------------------------------------------------------------------------
*----------------------- Individual-level --------------------------------
*-------------------------------------------------------------------------


// TOTAL

foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	
	
gsem (`dis' <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.ragender i.year, logit), nocapslatent

est store rural_DE_`dis'
estadd local type "rural_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':rural_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE

//MALE

gsem (`dis' <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 1, logit), nocapslatent

est store male_DE_`dis'
estadd local type "male_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':rural_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE



//FEMALE

gsem (`dis' <- NUPPdid logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year if ragender == 2, logit), nocapslatent

est store female_DE_`dis'
estadd local type "female_`dis'"

nlcom (_b[`dis':NUPPdid])
matrix b_d_1 = r(b)
matrix V_d_1 = r(V)
scalar std_err = sqrt(V_d_1[1,1])
scalar z = b_d_1[1,1]/std_err
scalar pvalue = 2 * normal(-abs(z))


scalar DE = r(b)[1,1]

estadd scalar DE = r(b)[1,1]
estadd scalar DE_p pvalue


nlcom (_b[`dis':logruralgdp])
matrix b_d_2 = r(b)
matrix V_d_2 = r(V)

nlcom (_b[`dis':logruralcarbon])
matrix b_d_3 = r(b)
matrix V_d_3 = r(V)

nlcom (_b[`dis':ruralCI])
matrix b_d_4 = r(b)
matrix V_d_4 = r(V)

nlcom (_b[`dis':logenvcost])
matrix b_d_5 = r(b)
matrix V_d_5 = r(V)

nlcom (_b[`dis':rural_medbed_per])
matrix b_d_6 = r(b)
matrix V_d_6 = r(V)



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

scalar TID_sd = sqrt(TIE_var)


matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar IE = TIE
estadd scalar IE_p pvalue

*****************
*total effect*
*****************

scalar TE = TIE+DE
matrix b = r(b)
matrix v = r(V)
scalar std_err = sqrt(v)
scalar z = b/std_err
scalar pvalue = 2 * normal(-abs(z))

estadd scalar TE = TE
estadd scalar TE_p pvalue



estadd local prop = TIE/TE

}


esttab rural_IE rural_DE* male_DE* female_DE* using $tbls/SEM_rural.csv, replace se label star(* 0.1 ** 0.05 *** 0.01) b(%9.5f) scalar(%9.3f)     ///
stats(type aic bic N IE IE_p DE DE_p TE TE_p prop,  fmt(%9s %9.0f %9.0f %9.0f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f) labels("Subsample" "AIC" "BIC" "Observation" "Indirect Effect" "P for IE" "Direct Effect" "P for DE" "Total Effect" "P for TE" "Proportion of Mediation")) keep(NUPPdid logenvcost logruralcarbon ruralCI logruralgdp rural_medbed_per)

estimates clear


*---------------------------------- RURAL DDD ----------------------------------- 

//gender
gen male = (ragender == 1)
gen NUPPdid_male = NUPPdid*male

foreach dis in arthre asthmae cancre diabe digeste dyslipe hearte hibpe kidneye livere lunge memrye psyche stroke{
	

gsem (`dis' <- NUPPdid_male logruralgdp logruralcarbon ruralCI logenvcost rural_medbed_per raeducl age rahltcom hukou lngovspend lnruralpop lnmedppl i.year, logit), nocapslatent

est store model_male_`dis'
estadd local type "gender_`dis'"

}

esttab model_male* using $tbls/SEM_rural_ddd.csv, replace se label star(* 0.1 ** 0.05 *** 0.01)  stats(N aic bic type,fmt(%9.0f %9.0f %9.0f %9s)) keep(NUPPdid_male logenvcost logruralcarbon ruralCI logruralgdp rural_medbed_per)



