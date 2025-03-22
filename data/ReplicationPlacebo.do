*12345678901234567890123456789012345678901234567890123456789012345678901234567890
clear all
set more off
set mem 800m
set matsize 11000
set maxvar 32767


*	************************************************************************
* 	File-Name: 	ReplicationPlacebo.do
*	Log-file:	na
*	Date:  		04/20/2017
*	Author: 	Michaël Aklin, Patrick Bayer, SP Harish, and Johannes Urpelainen
*	Data Used:  
*	Output		
*	Purpose:   	.do file to do the placebo test (randomization inference).
*	************************************************************************


*	Path to the datasets. CHANGE HERE.
* global datapath "C:/Users/harishsp/Dropbox/BigEnergyProject"

*	Path to a folder to save results/tables. CHANGE HERE.
* global resultspath "C:/Users/harishsp/Dropbox/BigEnergyProject/MGPManuscripts/ImpactEvaluation/TablesFigures"


********************************************************************************
* Private Kerosene
********************************************************************************

* our sample
use "ReplicationDataFinal.dta", clear
count

* drop remote habitations
drop if remote == 1

* purge the outcome

* Main Estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) 
* OLD: xtivreg Q918_keroseneexpensesprivate sd* (tvinstalled=tvitt) if remote == 0, fe
xtivreg Q918_keroseneexpensesprivate sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)


lincom tvinstalled
gen temp = `r(estimate)'*tvinstalled
gen Q918_keroprivate_purge = Q918_keroseneexpensesprivate-temp
drop temp
summ Q918_keroprivate_purge 

* number of treated habitations (50)
egen numb_treated = group(unique_id) if tvitt == 1
summ numb_treated

/*
* compare tvitt and tvinstalled
* br id2 Q11_hhid unique_id Q24_village Q25_hamlet survey tvinstalled tvitt if tvinstalled != tvitt
preserve
collapse (sum) tvitt tvinstalled tvadopted, by(id2 Q24_village Q25_hamlet)	
restore
*/

*********************
* save the ordering 
*********************

preserve
sort id2 Q11_hhid survey
keep id2 Q11_hhid unique_id Q24_village Q25_hamlet survey Q918_keroprivate_purge 
* ordering var for merging later
gen obsorder = _n
saveold "$resultspath/orgpanelorder.dta", replace
restore

*********************
* save the file
*********************
saveold "$resultspath/placeborandom.dta", replace

*********************
* before starting the randomization loop, collation dataset should have only one obs
* will be deleted later
*********************
use "$resultspath/est_placebo.dta", clear
count
keep if _n == 1
count
saveold "$resultspath/est_placebo.dta", replace


*********************
* LOOP THE RANDOMIZATION
*********************

local i = 1
* MA: change this number to control the number of reps
while `i' < 10001 {

use "$resultspath/placeborandom.dta", clear

cap drop hab1
egen hab1 = tag(id2)
cap drop u1
gen double u1 = runiform() if hab1 == 1
cap drop u2
bys id2: egen u2 = total(u1)
sort u2 Q11_hhid survey
* br Q11_hhid Q25_hamlet survey hab1 u1 u2 tvitt tvinstalled

* create ordering var for merging later
cap drop obsorder
gen obsorder = _n

* merge in with original ordering
* first drop any variables for which you want the original ordering
cap drop Q918_keroprivate_purge 
* everything should match
merge 1:1 obsorder using "$resultspath/orgpanelorder.dta", keepusing(Q918_keroprivate_purge)
drop _merge

* run the main estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) but the outcome variable should be Q918_keroprivate_purge
xtivreg Q918_keroprivate_purge sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)

* save the estimate
parmest, format(estimate min95 max95) saving("$resultspath/param`i'", replace)

dsconcat "$resultspath/est_placebo" "$resultspath/param`i'", append
keep if parm == "tvinstalled"

saveold "$resultspath/est_placebo.dta", replace

erase "$resultspath/param`i'.dta"


* next loop
local i = `i' + 1

}	


use "$resultspath/est_placebo.dta", clear
* remove the first dummy obs
drop if _n == 1
count

* Plot the kdensity of the placebo estimates
twoway kdensity estimate, xline(-49.36) ///
title("Placebo Test") ///
xlabel(-100 "-100" 0 "0" 100 "100") ///
ylabel(, angle(0)) ///
xtitle("Placebo coefficients") ///
ytitle("k-density") ///
scheme(s1mono)

graph export "$resultspath/impact_placebo_privkero.png", as(png) replace

* count the number of cases that are greater
count if estimate < -49.36
* percent
di `r(N)'*100/10000

gen lesser = 0
replace lesser = 1 if estimate < -49.36

count if max95 < 0 & lesser == 1
di `r(N)'*100/10000

********************************************************************************
********************************************************************************

********************************************************************************
* Total Kerosene
********************************************************************************

* our sample
use "ReplicationDataFinal.dta", clear
count

* drop remote habitations
drop if remote == 1

* purge the outcome

* Main Estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) 
*OLD: xtivreg total_kerosene sd* (tvinstalled=tvitt) if remote == 0, fe first
xtivreg total_kerosene sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)


*xtivreg Q918_keroseneexpensesprivate sd* (tvinstalled=tvitt) if remote == 0, fe first
lincom tvinstalled
gen temp = `r(estimate)'*tvinstalled
gen total_kerosene_purge = total_kerosene-temp
drop temp
summ total_kerosene_purge 

* number of treated habitations (50)
egen numb_treated = group(unique_id) if tvitt == 1
summ numb_treated

/*
* compare tvitt and tvinstalled
* br id2 Q11_hhid unique_id Q24_village Q25_hamlet survey tvinstalled tvitt if tvinstalled != tvitt
preserve
collapse (sum) tvitt tvinstalled tvadopted, by(id2 Q24_village Q25_hamlet)	
restore
*/


*********************
* save the ordering 
*********************

preserve
sort id2 Q11_hhid survey
keep id2 Q11_hhid unique_id Q24_village Q25_hamlet survey total_kerosene_purge 
* ordering var for merging later
gen obsorder = _n
saveold "$resultspath/orgpanelorder.dta", replace
restore

*********************
* save the file
*********************
saveold "$resultspath/placeborandom.dta", replace

*********************
* before starting the randomization loop, collation dataset should have only one obs
* will be deleted later
*********************
use "$resultspath/est_placebo.dta", clear
count
keep if _n == 1
count
saveold "$resultspath/est_placebo.dta", replace


*********************
* LOOP THE RANDOMIZATION
*********************

local i = 1
* Change this number to control the number of reps
while `i' < 10001 {

use "$resultspath/placeborandom.dta", clear

cap drop hab1
egen hab1 = tag(id2)
cap drop u1
gen double u1 = runiform() if hab1 == 1
cap drop u2
bys id2: egen u2 = total(u1)
sort u2 Q11_hhid survey
* br Q11_hhid Q25_hamlet survey hab1 u1 u2 tvitt tvinstalled

* create ordering var for merging later
cap drop obsorder
gen obsorder = _n

* merge in with original ordering
* first drop any variables for which you want the original ordering
cap drop total_kerosene_purge  
* everything should match
merge 1:1 obsorder using "$resultspath/orgpanelorder.dta", keepusing(total_kerosene_purge)
drop _merge

* run the main estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) but the outcome variable should be total_kerosene_purge
xtivreg total_kerosene_purge sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)


* save the estimate
parmest, format(estimate min95 max95) saving("$resultspath/param`i'", replace)

dsconcat "$resultspath/placebo/est_placebo" "$resultspath/param`i'", append
keep if parm == "tvinstalled"

saveold "$resultspath/est_placebo.dta", replace

erase "$resultspath/param`i'.dta"


* next loop
local i = `i' + 1

}	


use "$resultspath/est_placebo.dta", clear
* remove the first dummy obs
drop if _n == 1
count

* Plot the kdensity of the placebo estimates
twoway kdensity estimate, xline(-45.18) ///
title("Placebo Test") ///
xlabel(-100 "-100" 0 "0" 100 "100") ///
ylabel(, angle(0)) ///
xtitle("Placebo coefficients") ///
ytitle("k-density") ///
scheme(s1mono)

graph export "$resultspath/impact_placebo_totalkero.png", as(png) replace

* count the number of cases that are greater
count if estimate < -45.18
* percent
di `r(N)'*100/10000

gen lesser = 0
replace lesser = 1 if estimate < -45.18

count if max95 < 0 & lesser == 1
di `r(N)'*100/10000



********************************************************************************
* Access to Electricity
********************************************************************************

* OUR SAMPLE
use "ReplicationDataFinal.dta", clear
count

* drop remote habitations
drop if remote == 1

* purge the outcome

* Main Estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) 
* OLD: xtivreg Q91_electricity sd* (tvinstalled=tvitt) if remote == 0, fe
xtivreg Q91_electricity sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)

lincom tvinstalled
gen temp = `r(estimate)'*tvinstalled
gen Q91_elec_purge = Q91_electricity-temp
drop temp
summ Q91_elec_purge 

* number of treated habitations (50)
egen numb_treated = group(unique_id) if tvitt == 1
summ numb_treated




*********************
* save the ordering 
*********************

preserve
sort id2 Q11_hhid survey
keep id2 Q11_hhid unique_id Q24_village Q25_hamlet survey Q91_elec_purge 
* ordering var for merging later
gen obsorder = _n
saveold "$resultspath/orgpanelorder.dta", replace
restore

*********************
* save the file
*********************
saveold "$resultspath/placeborandom.dta", replace

*********************
* before starting the randomization loop, collation dataset should have only one obs
* will be deleted later
*********************
use "$resultspath/est_placebo.dta", clear
count
keep if _n == 1
count
saveold "$resultspath/est_placebo.dta", replace


*********************
* LOOP THE RANDOMIZATION
*********************

local i = 1
* MA: change this number to control the number of reps
while `i' < 10001 {

use "$resultspath/placeborandom.dta", clear

cap drop hab1
egen hab1 = tag(id2)
cap drop u1
gen double u1 = runiform() if hab1 == 1
cap drop u2
bys id2: egen u2 = total(u1)
sort u2 Q11_hhid survey
* br Q11_hhid Q25_hamlet survey hab1 u1 u2 tvitt tvinstalled

* create ordering var for merging later
cap drop obsorder
gen obsorder = _n

* merge in with original ordering
* first drop any variables for which you want the original ordering
cap drop Q91_elec_purge  
* everything should match
merge 1:1 obsorder using "$resultspath/orgpanelorder.dta", keepusing(Q91_elec_purge)
drop _merge

* run the main estimation
* MA: CHANGE THE BELOW ESTIMATION TO THE MAIN ONE (MODEL 4) but the outcome variable should be Q91_elec_purge
xtivreg Q91_elec_purge sd* (tvinstalled=tvitt) if remote == 0, fe vce(cluster id2)


* save the estimate
parmest, format(estimate min95 max95) saving("$resultspath/param`i'", replace)

dsconcat "$resultspath/placebo/est_placebo" "$resultspath/param`i'", append
keep if parm == "tvinstalled"

saveold "$resultspath/est_placebo.dta", replace

erase "$resultspath/param`i'.dta"


* next loop
local i = `i' + 1

}	


use "$resultspath/est_placebo.dta", clear
* remove the first dummy obs
drop if _n == 1
count

* Plot the kdensity of the placebo estimates
twoway kdensity estimate, xline(.289109) ///
title("Placebo Test") ///
xlabel(-1 "-1" 0 "0" 1 "1") ///
ylabel(, angle(0)) ///
xtitle("Placebo coefficients") ///
ytitle("k-density") ///
scheme(s1mono)

graph export "$resultspath/impact_placebo_keroaccess.png", as(png) replace

* count the number of cases that are greater
count if estimate > .29
* percent
di `r(N)'*100/10000

gen greater = 0
replace greater = 1 if estimate > .29

count if min95 > 0 & greater == 1
di `r(N)'*100/10000






STOP



