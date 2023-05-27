matrix define Rlarge = J(12,6,.)       
matrix define Rsmall = J(12,6,.)       
local r = 1

foreach var of varlist deltaEpa_2pre deltaEpa_1pre deltaEpa_0 deltaEpa_1 deltaEpa_2 deltaEpa_3 deltaEpa_4 deltaEpa_5 {
	qui areg `var' (i.win c.interaction c.index_std)##i.abovemedian, absorb(graduatoria) vce(cluster graduatoria) 
	
	qui margins, dydx(win) at(abovemedian = (0 1))
	matrix aux = r(b)
	local tauSmall = aux[1,3]
	local tauLarge = aux[1,4]
	matrix aux = r(V)
	local se_tauSmall = sqrt(aux[3,3])
	local se_tauLarge = sqrt(aux[4,4])
	
	matrix Rsmall[`r', 1] = `r'
	matrix Rsmall[`r', 2] = $bandwidth
	matrix Rsmall[`r', 3] = `tauSmall'
	matrix Rsmall[`r', 4] = `se_tauSmall'
	matrix Rsmall[`r', 5] = Rsmall[`r', 3] - invnormal(0.975) * Rsmall[`r', 4]
	matrix Rsmall[`r', 6] = Rsmall[`r', 3] + invnormal(0.975) * Rsmall[`r', 4]			
	
	matrix Rlarge[`r', 1] = `r'
	matrix Rlarge[`r', 2] = $bandwidth
	matrix Rlarge[`r', 3] = `tauLarge'
	matrix Rlarge[`r', 4] = `se_tauLarge'
	matrix Rlarge[`r', 5] = Rlarge[`r', 3] - invnormal(0.975) * Rlarge[`r', 4]
	matrix Rlarge[`r', 6] = Rlarge[`r', 3] + invnormal(0.975) * Rlarge[`r', 4]	
	
	local r = `r' + 1
}


preserve
	clear
	svmat Rsmall
	svmat Rlarge
	replace Rsmall1 = Rsmall1 - 0.05
	replace Rlarge1 = Rlarge1 + 0.05
	twoway (rspike Rsmall5 Rsmall6 Rsmall1, lc(black) lw(medthick)) (scatter Rsmall3 Rsmall1, msize(medium)) 			 ///
		   (rspike Rlarge5 Rlarge6 Rlarge1, lc(black) lw(medthick)) (scatter Rlarge3 Rlarge1, msize(medium) ), 			 ///
		   yline(0, lc(black))  xline(2.5, lc(black) lp(dash)) $gphspec 												 ///
		   xlabel(1 "[-24,-12]" 2 "[-12,0]" 3 "[0,12]" 4 "[12,24]" 5 "[24-36]" 6 "[36-48]" 7 "[48-60]" 8 "[60-72]") 	 ///
		   ytitle("Cumulated log-change of employment") ylabel(,nogrid) legend(order(2 4) lab(2 "Small") lab(4 "Large")) ///
		   xtitle("Months since winning the subsidy") title("")
restore

graph export "$figures/Figure_8.png", replace
graph save "$figures/Figure_8.gph", replace asis
