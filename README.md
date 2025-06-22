/*---------------------------------------------------------
* Topic: Carbon-intensive urbanization exacerbates elderly health inequalities across urban-rural divides
* Date: 20250509
* Update: 20250509
* Note : GDP3 - 建成区GDP(以2010年建成区边界为准）

- Base models : 0515Nupp_CarbonIntensity_health

- SEM : 
	0509SEM_total
	0509SEM_urban
	0509SEM_rural
	
- SEM bootstrap
	0509_bootstrap



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

