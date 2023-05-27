**************
** total funds
**************

* all
preserve

reg r_impatt_t win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg r_impatt_t win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(r_impatt_t)
bys bin: egen n=count(r_impatt_t)
bys bin: egen stdev=sd(r_impatt_t)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))  ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))  ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))              ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 		 ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					 ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		 ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Total subsidy", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(funds, replace)
restore

 
* below median 
preserve

keep if abovemedian==0

reg r_impatt_t win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg r_impatt_t win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(r_impatt_t)
bys bin: egen n=count(r_impatt_t)
bys bin: egen stdev=sd(r_impatt_t)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))  	 ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))  	 ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))              	 ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 			 ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					 	 ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		 	 ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Below median size", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(funds_belowmedian, replace)

restore
 
 
* above median 
preserve

keep if abovemedian==1

reg r_impatt_t win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg r_impatt_t win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(r_impatt_t)
bys bin: egen n=count(r_impatt_t)
bys bin: egen stdev=sd(r_impatt_t)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))  	 ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))  	 ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))              	 ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 			 ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					 	 ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		 	 ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Above median size", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(funds_abovemedian, replace)

restore
 
 
 
*******************
** funds per worker
*******************

* all
preserve

reg fundspercap win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg fundspercap win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(fundspercap)
bys bin: egen n=count(fundspercap)
bys bin: egen stdev=sd(fundspercap)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))   ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))   ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))               ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 		  ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					  ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		  ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Subsidy/worker", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(fundspercap, replace)

restore

 
* below median 
preserve

keep if abovemedian==0

reg fundspercap win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg fundspercap win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(fundspercap)
bys bin: egen n=count(fundspercap)
bys bin: egen stdev=sd(fundspercap)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))      ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))      ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))                  ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 			 ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					     ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		     ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Below median size", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(fundspercap_belowmedian, replace)

restore
 
 
* above median 
preserve

keep if abovemedian==1

reg fundspercap win index_std if win==0, robust
predict fit0
predict fitsd0, stdp
gen upfit0=fit0+1.645*fitsd0
gen downfit0=fit0-1.645*fitsd0

reg fundspercap win index_std if win==1, robust
predict fit1
predict fitsd1, stdp
gen upfit1=fit1+1.645*fitsd1
gen downfit1=fit1-1.645*fitsd1



bys bin: egen mean=mean(fundspercap)
bys bin: egen n=count(fundspercap)
bys bin: egen stdev=sd(fundspercap)
gen upmean=mean+1.645*stdev/(n^0.5)
gen lowmean=mean-1.645*stdev/(n^0.5)

sort bin
replace mean=. if bin==bin[_n-1]
replace upmean=. if bin==bin[_n-1]
replace lowmean=. if bin==bin[_n-1]

twoway (rarea upfit0 downfit0 index_std if index_std<0, sort fcolor(gs12) lcolor(gs12))      ///
	   (rarea upfit1 downfit1 index_std if index_std>0, sort fcolor(gs12) lcolor(gs12))      ///
	   (line fit0 index_std if index_std<0, sort lcolor(red) lwidth(thick))                  ///
	   (line fit1 index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick)) 			 ///
	   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)), 					     ///
	   ytitle("ths. €'s, at 2010 prices") xtitle("Score") xline(0, lcolor(black)) 		     ///
	   legend(off) xlabel(-$bandwidth(1)$bandwidth) title("Above median size", color(black)) /// 
	   ylabel(,nogrid) $gphspec nodraw name(fundspercap_abovemedian, replace)

restore
 
 
* create Figure 4
graph combine funds fundspercap, cols(2) xsize(8) ysize(3) scale(1.3) graphregion(color(white))
graph save "$figures/Figure_4.gph", replace asis
graph export "$figures/Figure_4.png", replace

* create Figure 5
graph combine funds_belowmedian funds_abovemedian, cols(2) scale(0.6) ycommon title("Total subsidy", color(black)) ///
		graphregion(color(white)) nodraw name(fig5a, replace)
graph combine fundspercap_belowmedian fundspercap_abovemedian, cols(2) scale(0.6) ycommon title("Subsidy/worker", color(black)) ///
		graphregion(color(white)) nodraw name(fig5b, replace)
graph combine fig5a fig5b, scale(1.3) graphregion(color(white)) rows(2)
graph save "$figures/Figure_5.gph", replace asis
graph export "$figures/Figure_5.png", replace 
