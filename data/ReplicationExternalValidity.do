
*12345678901234567890123456789012345678901234567890123456789012345678901234567890
capture log close
clear all
set more off

*	************************************************************************
* 	File-Name: 	ReplicationExternalValidity.do
*	Log-file:	na
*	Date:  		04/20/2017
*	Author: 	Michaël Aklin, Patrick Bayer, SP Harish, and Johannes Urpelainen
*	Data Used:  ReplicationDataRaw.dta
*	Output		ReplicationDataFinal.dta
*	Purpose:   	.do file to replicate our results concerning the external
*				validity of our results.
*	************************************************************************

*	Path to the replication folder here. CHANGE HERE.
global datapath "C:/Users/`c(username)'/Dropbox/BigEnergyProject"

*	Path to a new folder to save new results/tables. CHANGE HERE.
global resultspath "C:/Users/`c(username)'/Dropbox/BigEnergyProject/MGPManuscripts/ImpactEvaluation/TablesFigures"



**********************************************
* 	Our sample
**********************************************
use "$datapath/ReplicationDataRaw.dta", clear
count

* keep only baseline data
tab survey
tab survey, nolabel
keep if survey == 1

* drop remote data
drop if remote == 1

* district and village
tab Q22_district 
tab Q24_village 

* lighting type (note that everyone is using kerosene in baseline)
tab lighttype
tab lighttype, nolabel
gen kerosene_light = 0
replace kerosene_light = 1 if lighttype == 0

* literacy
gen literacy = 0
replace literacy = 1 if Q34_readhindi == 1 | Q35_writehindi == 1
summ Q34_readhindi Q35_writehindi literacy

* solar installation
gen light_solar = 0
replace light_solar = 1 if Q95_lightingsource == 5

* collapse by village
collapse ///
casted1 ///
Q513_account ///
kerosene_light ///
literacy  ///
Q52_radio ///
Q53_tv ///
Q54_mobile ///
Q58_bike  ///
Q59_motorbike  ///
light_solar ///
, by(Q24_village)

count



matrix extvalsamp = J(10,1,.)
local i = 1
foreach x in ///
casted1 ///
Q513_account ///
kerosene_light ///
literacy  ///
Q52_radio ///
Q53_tv ///
Q54_mobile ///
Q58_bike  ///
Q59_motorbike  ///
light_solar ///
{
	sum `x'
 	matrix extvalsamp[`i',1] = r(mean)
	local i = `i' + 1
}

 matrix rownames extvalsamp = ///
 "Scheduled Caste" ///
 "Have a Bank Account" ///
 "Kerosene for Lighting" ///
"Literacy" ///
"Own a Radio" ///
"Own a TV" ///
"Own a Mobile" ///
"Own a Bike" ///
"Own a Motorbike" ///
"Solar Installation"

matrix list extvalsamp

* putexcel A2=matrix(extvalsamp, names) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", replace
frmttable using "$resultspath/ImpactEvaluationExtVal.tex", replace tex fragment ///
	statmat(extvalsamp) substat(0) sdec(2) statfont(fs11) ///
	ctitles("","Survey" \ "","(All)") hlines(101{0}1) ///
	noblankrows ///
	rtitles("Scheduled Caste" \ "Have Bank Account" \ "Kerosene for Lighting" \ ///
			"Literacy" \ "Own Radio" \ "Own TV" \ "Own Mobile" \ ///
			"Own Bicycle" \ "Own Motorbike" \ "Solar Installation")
	


***********************
* Uttar Pradesh (All)
***********************
use "$datapath/ReplicationCensusUPData.dta", clear
count

* keep only the latest year
keep if Year == 2007
count
* check duplicates
duplicates list villagecode

* scheduled caste
gen scvillage = totscpopvillage/totpopvillage 
summ scvillage 

* bank
label variable banking_hhnbr "Percent of Households with Banking Services"
replace banking_hhnbr = banking_hhnbr/100
summ banking_hhnbr 

* kerosene for lighting
replace light_kerosene = light_kerosene/100
summ light_kerosene

* literacy
replace literacyrate = literacyrate/100
summ literacyrate 

* radio
replace asset_radio = asset_radio/100
summ asset_radio 

* tv
replace asset_tv = asset_tv/100
summ asset_tv 

* mobile
replace asset_mobilephone = asset_mobilephone/100
summ asset_mobilephone 

* bicycle
replace asset_bicylce = asset_bicylce/100
summ asset_bicylce 

* scooter
replace asset_scooter = asset_scooter/100
summ asset_scooter

* solar
replace light_solar = light_solar/100
summ light_solar 

matrix extvalup1 = J(10,1,.)
local i = 1
foreach x in ///
scvillage  ///
banking_hhnbr  ///
light_kerosene ///
literacyrate ///
asset_radio ///
asset_tv  ///
asset_mobilephone ///
asset_bicylce  ///
asset_scooter  ///
light_solar  ///
{
	sum `x'
 	matrix extvalup1[`i',1] = r(mean)
	local i = `i' + 1
}


frmttable using "$resultspath/ImpactEvaluationExtVal.tex", merge tex fragment ///
	statmat(extvalup1) substat(0) sdec(2) statfont(fs11) ///
	ctitles("Uttar Pradesh" \ "(All)")  ///
	noblankrows 
	


***********************
* Uttar Pradesh (Unelectrified)
***********************
use "$datapath/ReplicationCensusDataUP.dta", clear
count 

* keep only the latest year
keep if Year == 2007
count
* keep only unelectrified villages
keep if light_elec == 0
count
* check duplicates
duplicates list villagecode

* scheduled caste
gen scvillage = totscpopvillage/totpopvillage 
summ scvillage 

* bank
label variable banking_hhnbr "Percent of Households with Banking Services"
replace banking_hhnbr = banking_hhnbr/100
summ banking_hhnbr 

* kerosene for lighting
replace light_kerosene = light_kerosene/100
summ light_kerosene

* literacy
replace literacyrate = literacyrate/100
summ literacyrate 

* radio
replace asset_radio = asset_radio/100
summ asset_radio 

* tv
replace asset_tv = asset_tv/100
summ asset_tv 

* mobile
replace asset_mobilephone = asset_mobilephone/100
summ asset_mobilephone 

* bicycle
replace asset_bicylce = asset_bicylce/100
summ asset_bicylce 

* scooter
replace asset_scooter = asset_scooter/100
summ asset_scooter

* solar
replace light_solar = light_solar/100
summ light_solar 

matrix extvalup2 = J(10,1,.)
local i = 1
foreach x in ///
scvillage  ///
banking_hhnbr  ///
light_kerosene ///
literacyrate ///
asset_radio ///
asset_tv  ///
asset_mobilephone ///
asset_bicylce  ///
asset_scooter  ///
light_solar  ///
{
	sum `x'
 	matrix extvalup2[`i',1] = r(mean)
	local i = `i' + 1
}


frmttable using "$resultspath/ImpactEvaluationExtVal.tex", merge tex fragment ///
	statmat(extvalup2) substat(0) sdec(2) statfont(fs11) ///
	ctitles("Uttar Pradesh" \ "(Unelectrified)")  ///
	noblankrows 
	

***********************
* India Census
* use 2011 numbers
***********************
use "$datapath/ReplicationCensusIndiaData.dta", clear
count	

* scheduled caste
gen scpop = c11_2011_total_sc_pop
replace scpop = "" if c11_2011_total_sc_pop == "NA"
destring scpop, replace
summ scpop

gen totpop = c11_2011_total_pop
replace totpop = "" if c11_2011_total_pop == "NA"
destring totpop, replace
summ totpop

gen scvillage = scpop/totpop
summ scvillage 

* bank
gen bank_frac = c11_2011_asset_availing_bank
replace bank_frac = "" if c11_2011_asset_availing_bank == "NA"
destring bank_frac, replace
replace bank_frac = bank_frac/100
summ bank_frac

* kerosene for lighting
gen light_kerosene = c11_2011_kero_light 
replace light_kerosene = "" if c11_2011_kero_light == "NA"
destring light_kerosene, replace
replace light_kerosene = light_kerosene/100
summ light_kerosene

* literacy
gen lit_frac = c11_2011_p_lit
replace lit_frac = "" if c11_2011_p_lit == "NA"
destring lit_frac, replace
replace lit_frac = lit_frac/totpop
summ lit_frac

* radio
gen asset_radio = c11_2011_asset_radio
replace asset_radio = "" if c11_2011_asset_radio == "NA"
destring asset_radio, replace
replace asset_radio = asset_radio/100
summ asset_radio

* tv
gen asset_tv = c11_2011_asset_tv 
replace asset_tv = "" if c11_2011_asset_tv == "NA"
destring asset_tv, replace
replace asset_tv = asset_tv/100
summ asset_tv

* mobile
gen asset_mobile = c11_2011_asset_mobile_phone 
replace asset_mobile = "" if c11_2011_asset_mobile_phone == "NA"
destring asset_mobile, replace
replace asset_mobile = asset_mobile/100
summ asset_mobile


* bike
gen asset_bike = c11_2011_asset_bike
replace asset_bike = "" if c11_2011_asset_bike == "NA"
destring asset_bike, replace
replace asset_bike = asset_bike/100
summ asset_bike

* scooter
gen asset_scooter = c11_2011_asset_scooter_motor_mop
replace asset_scooter = "" if c11_2011_asset_scooter_motor_mop == "NA"
destring asset_scooter, replace
replace asset_scooter = asset_scooter/100
summ asset_scooter

* solar
gen light_solar = c11_2011_solar_light
replace light_solar = "" if c11_2011_solar_light == "NA"
destring light_solar, replace
replace light_solar = light_solar/100
summ light_solar

matrix extvalind1 = J(10,1,.)
local i = 1
foreach x in ///
scvillage  ///
bank_frac ///
light_kerosene ///
lit_frac ///
asset_radio ///
asset_tv  ///
asset_mobile ///
asset_bike  ///
asset_scooter  ///
light_solar  ///
{
	sum `x'
 	matrix extvalind1[`i',1] = r(mean)
	local i = `i' + 1
}


frmttable using "$resultspath/ImpactEvaluationExtVal.tex", merge tex fragment ///
	statmat(extvalind1) substat(0) sdec(2) statfont(fs11) ///
	ctitles("India" \ "(All)")  ///
	noblankrows 
	


***********************
* India Census (unelectrified)
* use 2011 numbers
***********************
use "$datapath/ReplicationCensusIndiaData.dta", clear
count	

* keep only unelectrified villages
gen light_elec = c11_2011_elec_light
replace light_elec = "" if c11_2011_elec_light == "NA"
destring light_elec, replace
keep if light_elec == 0
count

* scheduled caste
gen scpop = c11_2011_total_sc_pop
replace scpop = "" if c11_2011_total_sc_pop == "NA"
destring scpop, replace
summ scpop

gen totpop = c11_2011_total_pop
replace totpop = "" if c11_2011_total_pop == "NA"
destring totpop, replace
summ totpop

gen scvillage = scpop/totpop
summ scvillage 

* bank
gen bank_frac = c11_2011_asset_availing_bank
replace bank_frac = "" if c11_2011_asset_availing_bank == "NA"
destring bank_frac, replace
replace bank_frac = bank_frac/100
summ bank_frac

* kerosene for lighting
gen light_kerosene = c11_2011_kero_light 
replace light_kerosene = "" if c11_2011_kero_light == "NA"
destring light_kerosene, replace
replace light_kerosene = light_kerosene/100
summ light_kerosene

* literacy
gen lit_frac = c11_2011_p_lit
replace lit_frac = "" if c11_2011_p_lit == "NA"
destring lit_frac, replace
replace lit_frac = lit_frac/totpop
summ lit_frac

* radio
gen asset_radio = c11_2011_asset_radio
replace asset_radio = "" if c11_2011_asset_radio == "NA"
destring asset_radio, replace
replace asset_radio = asset_radio/100
summ asset_radio

* tv
gen asset_tv = c11_2011_asset_tv 
replace asset_tv = "" if c11_2011_asset_tv == "NA"
destring asset_tv, replace
replace asset_tv = asset_tv/100
summ asset_tv

* mobile
gen asset_mobile = c11_2011_asset_mobile_phone 
replace asset_mobile = "" if c11_2011_asset_mobile_phone == "NA"
destring asset_mobile, replace
replace asset_mobile = asset_mobile/100
summ asset_mobile


* bike
gen asset_bike = c11_2011_asset_bike
replace asset_bike = "" if c11_2011_asset_bike == "NA"
destring asset_bike, replace
replace asset_bike = asset_bike/100
summ asset_bike

* scooter
gen asset_scooter = c11_2011_asset_scooter_motor_mop
replace asset_scooter = "" if c11_2011_asset_scooter_motor_mop == "NA"
destring asset_scooter, replace
replace asset_scooter = asset_scooter/100
summ asset_scooter

* solar
gen light_solar = c11_2011_solar_light
replace light_solar = "" if c11_2011_solar_light == "NA"
destring light_solar, replace
replace light_solar = light_solar/100
summ light_solar

matrix extvalind2 = J(10,1,.)
local i = 1
foreach x in ///
scvillage  ///
bank_frac ///
light_kerosene ///
lit_frac ///
asset_radio ///
asset_tv  ///
asset_mobile ///
asset_bike  ///
asset_scooter  ///
light_solar  ///
{
	sum `x'
 	matrix extvalind2[`i',1] = r(mean)
	local i = `i' + 1
}


frmttable using "$resultspath/ImpactEvaluationExtVal.tex", merge tex fragment ///
	statmat(extvalind2) substat(0) sdec(2) statfont(fs11) ///
	ctitles("India" \ "(Unelectrified)")  ///
	noblankrows 
	



STOP


***********************
* Uttar Pradesh
***********************
use "$datapath/ReplicationCensusUPData.dta", clear
count

* keep only the latest year
keep if Year == 2007
count
* check duplicates
duplicates list villagecode


* scheduled caste
gen scvillage = totscpopvillage/totpopvillage 
summ scvillage 
putexcel C3=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bank
label variable banking_hhnbr "Percent of Households with Banking Services"
summ banking_hhnbr 
putexcel C4=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* kerosene for lighting
replace light_kerosene = light_kerosene/100
summ light_kerosene
putexcel C5=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* literacy
replace literacyrate = literacyrate/100
summ literacyrate 
putexcel C6=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* radio
replace asset_radio = asset_radio/100
summ asset_radio 
putexcel C7=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* tv
replace asset_tv = asset_tv/100
summ asset_tv 
putexcel C8=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* mobile
replace asset_mobilephone = asset_mobilephone/100
summ asset_mobilephone 
putexcel C9=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bicycle
replace asset_bicylce = asset_bicylce/100
summ asset_bicylce 
putexcel C10=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* scooter
replace asset_scooter = asset_scooter/100
summ asset_scooter
putexcel C11=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* solar
summ light_solar 
putexcel C12=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify



***********************
* Uttar Pradesh (no electricity)
***********************
use "$datapath/ReplicationCensusUPData.dta", clear
count	

* keep only the latest year
keep if Year == 2007
count
* keep only unelectrified villages
keep if light_elec == 0
count
* check duplicates
duplicates list villagecode


* scheduled caste
gen scvillage = totscpopvillage/totpopvillage 
summ scvillage 
putexcel D3=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bank
label variable banking_hhnbr "Percent of Households with Banking Services"
summ banking_hhnbr 
putexcel D4=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* kerosene for lighting
replace light_kerosene = light_kerosene/100
summ light_kerosene
putexcel D5=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* literacy
replace literacyrate = literacyrate/100
summ literacyrate 
putexcel D6=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* radio
replace asset_radio = asset_radio/100
summ asset_radio 
putexcel D7=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* tv
replace asset_tv = asset_tv/100
summ asset_tv 
putexcel D8=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* mobile
replace asset_mobilephone = asset_mobilephone/100
summ asset_mobilephone 
putexcel D9=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bicycle
replace asset_bicylce = asset_bicylce/100
summ asset_bicylce 
putexcel D10=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* scooter
replace asset_scooter = asset_scooter/100
summ asset_scooter
putexcel D11=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* solar
summ light_solar 
putexcel D12=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify




***********************
* India Census
* use 2011 numbers
***********************
use "$datapath/ReplicationCensusIndiaData.dta", clear
count	

* scheduled caste
gen scpop = c11_2011_total_sc_pop
replace scpop = "" if c11_2011_total_sc_pop == "NA"
destring scpop, replace
summ scpop

gen totpop = c11_2011_total_pop
replace totpop = "" if c11_2011_total_pop == "NA"
destring totpop, replace
summ totpop

gen scvillage = scpop/totpop
summ scvillage 
putexcel E3=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bank
gen bank_frac = c11_2011_asset_availing_bank
replace bank_frac = "" if c11_2011_asset_availing_bank == "NA"
destring bank_frac, replace
replace bank_frac = bank_frac/100
summ bank_frac
putexcel E4=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* kerosene for lighting
gen light_kerosene = c11_2011_kero_light 
replace light_kerosene = "" if c11_2011_kero_light == "NA"
destring light_kerosene, replace
replace light_kerosene = light_kerosene/100
summ light_kerosene
putexcel E5=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* literacy
gen lit_frac = c11_2011_p_lit
replace lit_frac = "" if c11_2011_p_lit == "NA"
destring lit_frac, replace
replace lit_frac = lit_frac/totpop
summ lit_frac
putexcel E6=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* radio
gen asset_radio = c11_2011_asset_radio
replace asset_radio = "" if c11_2011_asset_radio == "NA"
destring asset_radio, replace
replace asset_radio = asset_radio/100
summ asset_radio
putexcel E7=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* tv
gen asset_tv = c11_2011_asset_tv 
replace asset_tv = "" if c11_2011_asset_tv == "NA"
destring asset_tv, replace
replace asset_tv = asset_tv/100
summ asset_tv
putexcel E8=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* mobile
gen asset_mobile = c11_2011_asset_mobile_phone 
replace asset_mobile = "" if c11_2011_asset_mobile_phone == "NA"
destring asset_mobile, replace
replace asset_mobile = asset_mobile/100
summ asset_mobile
putexcel E9=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bike
gen asset_bike = c11_2011_asset_bike
replace asset_bike = "" if c11_2011_asset_bike == "NA"
destring asset_bike, replace
replace asset_bike = asset_bike/100
summ asset_bike
putexcel E10=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* scooter
gen asset_scooter = c11_2011_asset_scooter_motor_mop
replace asset_scooter = "" if c11_2011_asset_scooter_motor_mop == "NA"
destring asset_scooter, replace
replace asset_scooter = asset_scooter/100
summ asset_scooter
putexcel E11=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* solar
gen light_solar = c11_2011_solar_light
replace light_solar = "" if c11_2011_solar_light == "NA"
destring light_solar, replace
summ light_solar
putexcel E12=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify




***********************
* India Census (unelectrified)
* use 2011 numbers
***********************
use "$datapath/ReplicationCensusIndiaData.dta", clear
count	

* keep only unelectrified villages
gen light_elec = c11_2011_elec_light
replace light_elec = "" if c11_2011_elec_light == "NA"
destring light_elec, replace
keep if light_elec == 0
count


* scheduled caste
gen scpop = c11_2011_total_sc_pop
replace scpop = "" if c11_2011_total_sc_pop == "NA"
destring scpop, replace
summ scpop

gen totpop = c11_2011_total_pop
replace totpop = "" if c11_2011_total_pop == "NA"
destring totpop, replace
summ totpop

gen scvillage = scpop/totpop
summ scvillage 
putexcel F3=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bank
gen bank_frac = c11_2011_asset_availing_bank
replace bank_frac = "" if c11_2011_asset_availing_bank == "NA"
destring bank_frac, replace
replace bank_frac = bank_frac/100
summ bank_frac
putexcel F4=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* kerosene for lighting
gen light_kerosene = c11_2011_kero_light 
replace light_kerosene = "" if c11_2011_kero_light == "NA"
destring light_kerosene, replace
replace light_kerosene = light_kerosene/100
summ light_kerosene
putexcel F5=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* literacy
gen lit_frac = c11_2011_p_lit
replace lit_frac = "" if c11_2011_p_lit == "NA"
destring lit_frac, replace
replace lit_frac = lit_frac/totpop
summ lit_frac
putexcel F6=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* radio
gen asset_radio = c11_2011_asset_radio
replace asset_radio = "" if c11_2011_asset_radio == "NA"
destring asset_radio, replace
replace asset_radio = asset_radio/100
summ asset_radio
putexcel F7=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* tv
gen asset_tv = c11_2011_asset_tv 
replace asset_tv = "" if c11_2011_asset_tv == "NA"
destring asset_tv, replace
replace asset_tv = asset_tv/100
summ asset_tv
putexcel F8=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* mobile
gen asset_mobile = c11_2011_asset_mobile_phone 
replace asset_mobile = "" if c11_2011_asset_mobile_phone == "NA"
destring asset_mobile, replace
replace asset_mobile = asset_mobile/100
summ asset_mobile
putexcel F9=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify

* bike
gen asset_bike = c11_2011_asset_bike
replace asset_bike = "" if c11_2011_asset_bike == "NA"
destring asset_bike, replace
replace asset_bike = asset_bike/100
summ asset_bike
putexcel F10=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify


* scooter
gen asset_scooter = c11_2011_asset_scooter_motor_mop
replace asset_scooter = "" if c11_2011_asset_scooter_motor_mop == "NA"
destring asset_scooter, replace
replace asset_scooter = asset_scooter/100
summ asset_scooter
putexcel F11=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify


* solar
gen light_solar = c11_2011_solar_light
replace light_solar = "" if c11_2011_solar_light == "NA"
destring light_solar, replace
summ light_solar
putexcel F12=(r(mean)) using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify



putexcel C1=("External Validity") ///
A2=("Variable") ///
B2=("Sample") ///
C2=("Uttar Pradesh (All)") ///
D2=("Uttar Pradesh (Unelectrified)") ///
E2=("All India") ///
F2=("All India (Unelectrified)") ///
using "$resultspath/ImpactEvaluation_ExternalValidity.xlsx", modify




STOP







