/*---------------------------------------------------------
* Topic: Carbon emissions disproportionately erode urbanization’s health benefits for urban and rural aging populations
* Date: 20251106
* Update: 20251106

- Base models : Figures 3, Table 2, and Supplementary Information Figures S1 and S2

- Effects of the NUP under different preexisting GDP and carbon intensity levels: Tables 3-5, Extended Data Tables 1-4, and Supplementary Information Tables S3-12

- GSEM : Figure 4, Table 6, Supplementary Information Table S13-14, and Figures S6–S34
	
- GSEM bootstrap : Extended Data Figure 2

**********************
*** 0. Clean and Merge ***
**********************

do $dof/Others/1_RasterCalculation_forGDP&TiF/1_Calculate_GDPTiFByUrbanRural.ipynb
do $dof/Others/1_RasterCalculation_forGDP&TiF/2_MergeReshape
		** ==> 城乡Shapefile/SavedData/M3_2010Built_GDPCarbon.dta
		
do $dof/Others/1_RasterCalculation_forGDP&TiF/3_MergeClean
		** ==> $svd/1_Nupp_CarbonGDP_event.dta
		** ==> $svd/2_Nupp_CarbonGDP_charls_merged.dta


**********************
*** 1. Baseline model ***
**********************

do $dof/1_Nupp_CarbonIntensity_health.do

	/*
	- Merge datasets
	- Create indicators
	- Baesline DiD regression and eventplot
	- Descriptive Statistics
	*/
	
********************************************************************************************************
***       2. Effects of the NUP under different preexisting GDP and carbon intensity levels             ***
********************************************************************************************************


do $dof/2_EffectsByPreexistingConditions_bygender.do
do $dof/2_EffectsByPreexistingConditions_byEnvCost&MedSer.do


***********************
***      3. GSEM       ***
***********************

do $dof/3_1GSEM_total.do
do $dof/3_2GSEM_urban.do
do $dof/3_3GSEM_rural.do
do $dof/3_4GSEM_bydisease.do



**********************************
***    4. Bootstrap of GSEM       ***
**********************************
do $dof/4_1total_boot.do
do $dof/4_2urban_boot.do
do $dof/4_3rural_boot.do

do $dof/4_4Boot_total_disease.do



