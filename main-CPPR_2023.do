********************************************************************************
********************************************************************************
************************ CPPR 2023 - Labour Economics **************************
********************************************************************************
********************************************************************************

* Version: 26 May 2023

version 17.0

clear all

global path    "YOUR_PATH" 
global data    "$path/data"
global dofil   "$path/dofiles"
global figures "$path/figures"
global tables  "$path/tables"

global outreg2opt "bdec(3) sdec(3) excel nonotes"
global gphspec "plotregion(lcolor(black) lwidth(medthin)) graphregion(color(white))"


cap mkdir "$path/figures"
cap mkdir "$path/tables"

************************************************************************************************************
** some auxiliary commands we use in our analysis

* Install rddensity (more info at https://rdpackages.github.io/rddensity/), we used version 20230121
* net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
* net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace

* Install getaway (more info at https://github.com/filippopalomba/getaway-package), we used version 20230506
* net install getaway, from("https://raw.githubusercontent.com/filippopalomba/getaway-package/main/stata") replace

************************************************************************************************************

*******************************************************************************
* Figure 1: own elaboration from Bank of Italy's data
*******************************************************************************

*******************************************************************************
* Figure 2: Job creation, employment share, and growth
*******************************************************************************

do "$dofil/Figure_2.do"


use "$data/dataL488.dta", clear
drop if mi(lpers_anno_1)

*** define RD parameters 
global bandwidth 5
keep if abs(index_std) < $bandwidth
global nbins = 30

*** generate variables
gen weight=$bandwidth - abs(index_std)
xtile bin=index_std if index_std>0, nq($nbins)
xtile bin0=index_std if index_std<0, nq($nbins)
replace bin=bin0-$nbins if index_std<0
drop bin0

bys bin: egen midbin=median(index_std)

global spec win index_std winxindex_std index_std2 winxindex_std2

qui sum pers_anno_1 if mi(win)==0, d
gen abovemedian=1 if pers_anno_1>r(p50)
replace abovemedian=0 if pers_anno_1<=r(p50)
gen fundspercap=r_impatt/pers_anno_1/1000


*******************************************************************************
* Figure 3: McCrary density and histogram
*******************************************************************************

do "$dofil/Figure_3.do"


*******************************************************************************
* Figures 4 and 5: Funds paid to winning firms: all and by firm size
*******************************************************************************

do "$dofil/Figure_4-5.do"


********************************************************
* Table 1: Firm investment and employment after subsidy
********************************************************

do "$dofil/Table_1.do"


********************************************
* Figures 6 and 7: Investment and employment
********************************************

do "$dofil/Figure_6-7.do"


********************************************
* Figure 8: Employment dynamics
********************************************

do "$dofil/Figure_8.do"


********************************************
* Table 2: Cost effectiveness at cutoff
********************************************

do "$dofil/Table_2.do"


**************************************************
* Figure 10: heterogeneity across age and size
**************************************************

do "$dofil/Figure_10.do"


**********************************************************************
* Figure 9: get marginals of the previous heatmap with standard errors
**********************************************************************

* set number of bootstrap draws (might take some minutes)
global breps = 1000
global covs "c.lp##(i.age_qtl_5 i.ng_1 i.g1_10 i.relw_wc10 i.dir i.app i.size_qtl_5)" 

do "$dofil/Figure_9.do"


**********************************************************************
* Figure 11: get marginals of the previous heatmap with standard errors
**********************************************************************

use "$data/dataL488.dta", clear
* set number of bootstrap draws (might take some minutes)
global breps = 1000

global covs "c.lp##(i.age_qtl_5 i.ng_1 i.age_lgn i.g1_10 i.relw_wc10 i.dir i.app)" 
global covsINV  "c.lpold i.age_qtl_5 i.ng_1 i.relw_wc10 i.g1_10"

do "$dofil/Figure_11.do"


	
