/*---------------------------------------------------------
* Topic: Carbon-intensive urbanization exacerbates elderly health inequalities across urban-rural divides
* Date: 20250509
* Update: 20250509

- Base models : Figures 3-5 and Extended Data Figures 2 and 3

- GSEM : Figure 6 
	
- GSEM bootstrap : Extended Data Figure 4



**********************
*** Baseline model ***
**********************

do $dof/1_Nupp_CarbonIntensity_health.do

	/*
	- Merge datasets
	- Create indicators
	- Baesline DiD regression and eventplot (FIgure 3)
	- Moderating Effect (Figures 4 and 5, Extended Data Figures 2 and 3)
	*/

	

***********
*** GSEM ***
***********	

do $dof/2_1GSEM_total.do

do $dof/2_2GSEM_urban.do

do $dof/2_3GSEM_rural.do

do $dof/2_4GSEM_bydisease.do



*****************
*** GSEM Bootstrap ***
*****************

do $dof/3_1total_boot.do

do $dof/3_2urban_boot.do

do $dof/3_3rural_boot.do

do $dof/3_4Boot_total_disease.do

