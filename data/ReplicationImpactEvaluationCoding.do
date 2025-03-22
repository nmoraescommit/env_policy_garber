*12345678901234567890123456789012345678901234567890123456789012345678901234567890
capture log close
clear all
set more off

*	************************************************************************
* 	File-Name: 	ImpactEvaluationCoding.do
*	Log-file:	na
*	Date:  		04/20/2017
*	Author: 	Michaël Aklin, Patrick Bayer, SP Harish, and Johannes Urpelainen
*	Data Used:  ReplicationDataRaw.dta
*	Output		ReplicationDataFinal.dta
*	Purpose:   	.do file to create the dataset for the Science Advance
*				article.
*	************************************************************************


*	************************************************************************
*	A. Data
*	************************************************************************

*	ASSUMES THAT THE DATASET IS IN THE SAME FOLDER
use "ReplicationDataRaw.dta", clear

*	These entries are errors
gen flag = 0
* Observations where people refused to participate in the survey (20 cases)
replace flag = 1 if Q916_keroseneexpenses == . & Q918_keroseneexpensesprivate == .

* Spillover in remote controls (10 cases)
replace flag = 1 if remote == 1 & Q95_lightingsource == 6 

* Drop flagged observations
drop if flag == 1

*	************************************************************************
*	B. Dependent variables
*	************************************************************************

*	************************************************************************
*	B.1. Kerosene
*	************************************************************************

*	Public Kerosene
* Missing for private kerosene should be zeros
replace Q916_keroseneexpenses = 0 if Q916_keroseneexpenses == .

*	Total Kerosene
gen total_kerosene = Q916_keroseneexpenses + Q918_keroseneexpensesprivate
* Add zeros for those who just don't use the private market
replace total_kerosene = 0 if total_kerosene == . & Q918_keroseneexpensesprivate == . 
replace total_kerosene = 0 if total_kerosene == . & Q916_keroseneexpenses == .
replace total_kerosene = . if Q916_keroseneexpenses == . & Q918_keroseneexpensesprivate == .

*	************************************************************************
*	B.2. Electricity & Lighting
*	************************************************************************

gen hourselec = Q93_elechours
replace hourselec = . if Q93_elechours == 99
replace hourselec = 0 if Q93_elechours == . 
replace hourselec = . if Q91_electricity == .


gen lightsat = .
replace lightsat = 4 if Q951_lightingsatis == 1
replace lightsat = 3 if Q951_lightingsatis == 2
replace lightsat = 2 if Q951_lightingsatis == 3
replace lightsat = 1 if Q951_lightingsatis == 4
replace lightsat = 0 if Q951_lightingsatis == 5

*	************************************************************************
*	B.3. Economic
*	************************************************************************


gen time_soccap = Q1723_relativestime + Q1722_friendstime

gen logsavings = log(Q62_savings+1)

gen studydummy = Q912_kidsstudying+Q962_studying
replace studydummy = 1 if studydummy == 2
replace studydummy = Q962_studying if Q912_kidsstudying == .

gen kidshourslight = Q913_kidshourslighting
replace Q913_kidshourslighting = . if Q913_kidshourslighting == 99

*	************************************************************************
*	C. Independent variables
*	************************************************************************

gen itt = 0
replace itt = 1 if treatment == 1 | installed == 1
replace itt = 0 if contamination == 1

gen tvitt = 0
replace tvitt = 1 if (treatment == 1 | installed == 1) & (survey == 2 | survey == 3)
replace tvitt = 0 if contamination == 1

gen tvtreatment = 0
replace tvtreatment = 1 if treatment == 1 & (survey == 2 | survey == 3)

gen tvinstalled = 0
replace tvinstalled = 1 if installed == 1 & (survey == 2 | survey == 3)

gen tvadopted = 0
replace tvadopted = 1 if Q92_MGPaccept == 1 | Q92_MGPaccept_Phone == 1
replace tvadopted = 0 if Q98_MGPdiscontinue == 1

by Q11_hhid (survey), sort: egen adopted = max(tvadopted)

gen group = .
replace group = 0 if remote == 1 & itt == 0
replace group = 1 if remote == 0 & itt == 0
replace group = 2 if remote == 0 & itt == 1
replace group = . if flag == 1
label define gr 0 "Remote Control" 1 "Close Control" 2 "Treatment"
label values group gr


gen tvremote = 0
replace tvremote = 1 if remote == 1 & (survey == 2 | survey == 3)


*	Waiting list treatment (9 habitations)
gen waiting_treatment = 0

replace waiting_treatment = 1 if Q24_village == "Basantapur" & Q25_hamlet == "Basantpur"
replace waiting_treatment = 1 if Q24_village == "Basantpur" & Q25_hamlet == "Basantpur"

replace waiting_treatment = 1 if Q24_village == "Karsa Kala" & Q25_hamlet == "Muslim Mohalla"
replace waiting_treatment = 1 if Q24_village == "Karsa Kalan" & Q25_hamlet == "Muslim Mohalla"

replace waiting_treatment = 1 if Q24_village == "Semrai" & Q25_hamlet == "Katari Poorvi Tola"
replace waiting_treatment = 1 if Q24_village == "Semrai" & Q25_hamlet == "Katari Purvi"

replace waiting_treatment = 1 if Q24_village == "Akohara" & Q25_hamlet == "Patti Tola"
replace waiting_treatment = 1 if Q24_village == "Akohra" & Q25_hamlet == "Patti Tola"

replace waiting_treatment = 1 if Q24_village == "Bairanamau Manjhari" & Q25_hamlet == "Tipra"
replace waiting_treatment = 1 if Q24_village == "Nandaupura" & Q25_hamlet == "West Tola Salimpur"
replace waiting_treatment = 1 if Q24_village == "Surihamau" & Q25_hamlet == "Takiya"
replace waiting_treatment = 1 if Q24_village == "Mallapur" & Q25_hamlet == "Mallapur Khas"
replace waiting_treatment = 1 if Q24_village == "Mathura" & Q25_hamlet == "Bada Karmullapur"

*	************************************************************************
*	D. Control variables
*	************************************************************************

quiet tab survey, gen(sd)
quiet tab Q37_religion, gen(religiond)
quiet tab Q38_caste, gen(casted)

*
gen logexp = log(Q61_expenses+1)

*
gen remote_x_sd1 = remote*sd1
gen remote_x_sd2 = remote*sd2
gen remote_x_sd3 = remote*sd3

gen children = Q315_malekidsschool + Q317_femalekidsschool

gen married = 0
replace married = 1 if Q39_married > 0 & Q39_married != .

* HH size is spouse+children+respondent
gen hhsize = married+children+1

* Reorganizing lighting type
/*
Original:
1 = electricity
2 = kerosene
3 = candles
4 = battery
5 = solar
6 = MGP
9 = other
*/

gen lighttype = .
* kerosene
replace lighttype = 0 if Q95_lightingsource == 2
replace lighttype = 4 if Q95_lightingsource == 4
replace lighttype = 1 if Q95_lightingsource == 6
replace lighttype = 2 if Q95_lightingsource == 5
replace lighttype = 3 if Q95_lightingsource == 1
replace lighttype = 4 if Q95_lightingsource == 3
replace lighttype = 4 if Q95_lightingsource == 9

label define lt 0 "Kerosene" 1 "MGP" 2 "Other Solar" 3 "Grid" 4 "Other"
label values lighttype lt


*	************************************************************************
*	E. Labeling
*	************************************************************************

label variable total_kerosene "Kerosene Spending (INR/Month)"
label variable tvtreatment "Treatment (Time Varying)"
label variable tvinstalled "Installed (Time Varying)"
label variable tvadopted "Adopted (Time Varying)"
label variable adopted "Adopted"
label variable tvitt "Treatment"
label variable itt "Treatment (ITT)"
label variable time_soccap "Time Spent with Family/Friends (Times per Week)"
label variable children "\# Children"
label variable remote_x_sd1 "1st Wave * Remote Control"
label variable remote_x_sd2 "2nd Wave * Remote Control"
label variable remote_x_sd3 "3rd Wave * Remote Control"
label variable casted1 "Scheduled Caste"
label variable casted2 "Scheduled Tribe"
label variable casted3 "Backward Caste"
label variable casted4 "Other Backward Caste"
label variable casted5 "Other"
label variable religiond1 "Hindu"
label variable religiond2 "Muslim"
label variable sd1 "1st Wave"
label variable sd2 "2nd Wave"
label variable sd3 "3rd Wave"
label variable logexp "HH Expenditures (log of INR/Month)"
label variable logsavings "HH Savings (log of INR/Month)"
label variable hourselec "Hours of Electricity (per Day)"
label variable Q918_keroseneexpensesprivate "Kerosene Spending (Private Market) (INR/Month)" 
label variable lightsat "Lighting Satisfaction"
label variable Q916_keroseneexpenses "Kerosene Spending (PDS) (INR/Month)"
label variable Q179_lightcooking "Sufficient Lighting for Cooking"
label variable Q98_lightinghours "Hours of Lighting (per Day)"
label variable Q91_electricity "Household Electrification ($=$1)"
label variable Q69_ownbusiness "Business Ownership ($=$1)"
label variable Q61_expenses "HH Expenditures (INR/Month)"
label variable Q62_savings "HH Savings (INR/Month)"
label variable studydummy "Lighting Used for Studying"
label var tvremote "Remote (Time-Varying)"


*	************************************************************************
*	F. Recode variable for discontinuation of MGP service
*	************************************************************************

replace Q981_MGPdiscontinuereason="Not stated" if Q98_MGPdiscontinue==1 & Q981_MGPdiscontinuereason==""

gen discont_reason = ""
replace discont_reason = "Service quality" if Q981_MGPdiscontinuereason=="Due to bad management"
replace discont_reason = "Service quality" if Q981_MGPdiscontinuereason=="Due to dispute with MGP officer"
replace discont_reason = "Service quality" if Q981_MGPdiscontinuereason=="MGP DISCONTINUED WITH THIS SERVICE"
replace discont_reason = "Service quality" if Q981_MGPdiscontinuereason=="MGP WORKERS BEHAVIOUR IS NOT GOOD"


replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="THEY WERE TAKING BILL AT 28 DAYS AND HE WANT TO GIVE THE BILL AT 30DAYS"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="Due to lack of money"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="IT IS VERY EXPENSIVE"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="Due to lack of money"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="Due to lack of money"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="Due to delay payment"
replace discont_reason = "Payment" if Q981_MGPdiscontinuereason=="THE WAY OF TAKING MONEY WAS BAD"

replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="LIGHT IS NOT GOOD."
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="LIGHT IS NOT REGULAR"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="LIGHT WAS NOT GOOD"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="MACHINE IS NOT WORKING"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="Panel was break before two months"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="MACHINE IS NOT WORKING"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="MGP provide electricity only two days in a week"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="MGP have not provide electricity properly"
replace discont_reason = "Lighting quality" if Q981_MGPdiscontinuereason=="MGP have not provide electricity Properly"

replace discont_reason = "Other" if Q981_MGPdiscontinuereason=="Due to dispute with neighbours"
replace discont_reason = "Other" if Q981_MGPdiscontinuereason=="ONLY USED 3 MONTHS"
replace discont_reason = "Other" if Q981_MGPdiscontinuereason=="Not stated"


*	************************************************************************
*	G. Final clean-up
*	************************************************************************

* Numerical cluster (for some versions of Stata)
encode unique_id, gen(id2)

xtset Q11_hhid survey

saveold "ReplicationDataFinal.dta", replace v(12)

