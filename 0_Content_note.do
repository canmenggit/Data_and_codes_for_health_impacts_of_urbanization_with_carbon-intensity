/*---------------------------------------------------------
* Topic: NUPP and Carbon intensity analysis
* Date: 20250509
* Update: 20250509
* Note : GDP3 - 建成区GDP(以2010年建成区边界为准）




- Data clean : 
	城乡Shapefile/1_Calculate_GDPTiFByUrbanRural.ipynb
	2_MergeReshape   -- 得到 ：【】

- Base models : 0515Nupp_CarbonIntensity_health

- SEM : 
	0509SEM_total
	0509SEM_urban
	0509SEM_rural
	
- SEM bootstrap
	0509_bootstrap
		
		
*/


*---------------------------------------------------------
*JUST A NOTE RECORDING STEPS
* !!! can not run directly !!!
*---------------------------------------------------------


/* [> START FROM BASE MODEL<] */ 

global path [PATH]

*** 目录


global dof $path/code


**********************
*** Clean and Merge ***
**********************

do $dof/Others/1_RasterCalculation_forGDP&TiF/1_Calculate_GDPTiFByUrbanRural.ipynb
do $dof/Others/1_RasterCalculation_forGDP&TiF/2_MergeReshape
		** ==> 城乡Shapefile/SavedData/M3_2010Built_GDPCarbon.dta
		
do $dof/Others/1_RasterCalculation_forGDP&TiF/3_MergeClean
		** ==> $svd/1_Nupp_CarbonGDP_event.dta
		** ==> $svd/2_Nupp_CarbonGDP_charls_merged.dta


**********************
*** Baseline model ***
**********************

do $dof/1_Nupp_CarbonIntensity_health.do

	/*
	- Merge datasets
	- Create indicators
	- Baesline DiD regression and eventplot
	- Moderating Effect
	*/

	

***********
*** SEM ***
***********	

do $dof/2_1GSEM_total.do
do $dof/2_2GSEM_urban.do
do $dof/2_3GSEM_rural.do
do $dof/2_4GSEM_bydisease.do



*****************
*** Bootstrap ***
*****************

do $dof/3_1total_boot.do
do $dof/3_2urban_boot.do
do $dof/3_3rural_boot.do

do $dof/3_4Boot_total_disease.do

