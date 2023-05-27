g touse = 1 // auxiliary var to compute quantiles on active sub-sample
foreach var of varlist agec ng_1 age_lgn g1_10 relw_wc10 dir app lp deltaEpa_5 lpers_anno_1 {
	replace touse = 0 if mi(`var')
}
replace touse = 0 if abs(index_std) > 5

* Quantile binning
xtile size_qtl_5 = lpers_anno_1 if touse, nq(5)
g age_qtl_5 = agec

gen large=1 if dimimp=="G"
replace large = 0 if dimimp=="M" | dimimp=="P"
tab large dimimp

label define sizelab 1 "Large firm" 0 "SME"
label value large sizelab

getaway $covs, o(deltaEpa_5) s(index_std) b(5) site(graduatoria) genvar(effect) 

replace touse = !mi(effect) // identify Angrist sample
g touse2 = !mi(r_imppot) & r_imppot>0 & touse // identify treated
g r_imppot_mil = r_imppot/1000

egen groupeff = group(agec dimimp codreg) if touse2 & win
bys groupeff: egen meffect = mean(effect) if win & touse2 

g Y1 = .        // Potential outcome if treated
g Y0 = .		// Potential outcome if control

replace Y1 = lpers_anno_1 if touse2 & win ==1      // Observed: Y(T,T)
replace Y0 = lpers_anno_1 - meffect if touse2 & win ==1  // Counterfactual: Y(T,C)

g jobs = sinh(Y1) - sinh(Y0)   // inverse arcsin function to obtain jobs in level

egen jj = mean(jobs) if win & touse2, by(large)
egen ff = mean(r_imppot_mil) if win & touse2, by(large)
g Avgcost = ff / jj
tabstat r_imppot_mil jobs if win & touse2, by(large) stat(sum)

****store mean value of egffect and Avg cost

matrix define eff_large = J(2,3,.)
matrix define cost_large = J(2,3,.)

tabstat meffect , by(large) stat(mean) save
forval i=1/2 {
	matrix aux = r(Stat`i')
	matrix eff_large[`i', 1] = aux[1, 1]
}

tabstat Avgcost , by(large) stat(mean) save
forval i=1/2 {
	matrix aux = r(Stat`i')
	matrix cost_large[`i', 1] = aux[1, 1]
}



matrix define bootStoreCost = J($breps, 2, .)
matrix define bootStoreEff = J($breps, 2, .)
global breps = 200
set seed 8894

quietly {
	forval b = 1/$breps {
		preserve
		
		foreach var of varlist touse2 groupeff Y1 Y0 jobs meffect {
			ren `var' `var'old
		}
		
		bsample, cluster(graduatoria) 
		*bys graduatoria : gen count=_n==1
		getaway $covs, o(deltaEpa_5) s(index_std) b(5) site(graduatoria) genvar(beffect) 

		replace touse =!mi(beffect) // identify Angrist sample
		g touse2 = !mi(r_imppot) & r_imppot>0 & touse // identify treated

		egen groupeff = group(agec dimimp codreg) if touse2 & win
		bys groupeff: egen meffect = mean(beffect) if win & touse2 

		tabstat meffect if win & touse2, by(large) stat(mean) save

		forval i=1/2 {
			matrix aux = r(Stat`i')
			matrix bootStoreEff[`b', `i'] = aux[1, 1]
		}
		
		
		g Y1 = .        // Potential outcome if treated
		g Y0 = .		// Potential outcome if control

		replace Y1 = lpers_anno_1 if touse2 & win ==1      // Observed: Y(T,T)
		replace Y0 = lpers_anno_1 - meffect if touse2 & win ==1  // Counterfactual: Y(T,C)

		g jobs = sinh(Y1) - sinh(Y0)   // inverse arcsin function to obtain jobs in level

		** get sample estimates
		cap drop jj ff Avgcost
		egen jj = mean(jobs) if win & touse2, by(large)
		egen ff = mean(r_imppot_mil) if win & touse2, by(large)
		g Avgcost = ff / jj
		
		tabstat Avgcost if win & touse2, by(large) stat(mean) save

		forval i=1/2 {
			matrix aux = r(Stat`i')

			matrix bootStoreCost[`b', `i'] = aux[1, 1]
		}
		
		restore
	}
}


preserve
clear 
svmat bootStoreCost
svmat bootStoreEff

local alp = 10
local lb = `alp'/2
local ub = (100 - `alp') + `alp'/2

forval d = 1/2 {
	
	_pctile bootStoreCost`d', percentiles(`lb' `ub')
	matrix cost_large[`d',2] = r(r1)
	matrix cost_large[`d',3] = r(r2)
	
	_pctile bootStoreEff`d', percentiles(`lb' `ub')
	matrix eff_large[`d',2] = r(r1)
	matrix eff_large[`d',3] = r(r2)

}

restore



preserve
	clear
	svmat cost_large
	svmat eff_large
	g id = _n

	twoway (rspike cost_large2 cost_large3 id, lc(black) lw(medthick)) (scatter cost_large1 id, mc(black) msize(medium)),     ///
		   $gphspec title("Cost of new jobs", color(black)) xtitle("Size class") xlabel(1 "Small" 2 "Large")                  ///
		   xscale(range(0.5 2.5)) legend(off) ylabel(, nogrid) nodraw name(fig11a, replace)

restore


cap drop NewInvlsum_i5_av meffect dd funds_bneuro Invsum_exavg CI_exavg_bne
cap drop 
cap drop touse2 groupeff Y1 Y0 jobs meffect
cap drop effect
cap drop touse2
cap drop tousei

getaway $covsINV, o(lsum_i5_av) s(index_std) b(5) site(graduatoria) genvar(effect)
g tousei =!mi(effect) & !mi(lsum_i5_av) & !mi(deltaEpa_5)	
replace tousei=0 if mi(effect) 
g touse2 = !mi(r_imppot) & r_imppot>0 & tousei

egen groupeffc=group(agec dimimp codreg) if touse2 & win
bys groupeffc : egen meffect = mean(effect) if win & touse2 

cap drop Y1 Y0
g Y1 = .        // Potential outcome if treated
g Y0 = .		// Potential outcome if control

replace Y1 = lsum_i5_av if touse2 & win      // Observed: Y(T,T)
replace Y0 = lsum_i5_av - meffect if touse2 & win   // Counterfactual: Y(T,C)

g NewInvlsum_i5_av = sinh(Y1) - sinh(Y0)   // inverse arcsin function to obtain jobs in level

g dd= NewInvlsum_i5_av*sum_ind5
winsor dd, g(Invsum_exavg) p(0.01)

gen funds_bneuro= r_imppot/1000000000
g CI_exavg_bne=Invsum_exavg/1000000
gen mult=1/(1-proind1)
gen promised_inv_bneuro=funds_bneuro*mult


cap drop ff jj 
cap drop gg
cap drop CostInv

egen ff = mean(funds_bneuro) if win==1 & touse2 , by(large)
egen jj = mean(CI_exavg_bne) if win==1 & touse2, by(large)

g CostInv= ff/jj

matrix define eff_large = J(2,3,.)
matrix define cost_large = J(2,3,.)

tabstat meffect , by(large) stat(mean) save
forval i=1/2 {
	matrix aux = r(Stat`i')
	matrix eff_large[`i', 1] = aux[1, 1]
}

tabstat CostInv , by(large) stat(mean) save
forval i=1/2 {
	matrix aux = r(Stat`i')
	matrix cost_large[`i', 1] = aux[1, 1]

}

set seed 8894
matrix define bootStoreCost = J($breps, 2, .)
matrix define bootStoreEff = J($breps, 2, .)

quietly {
	forval b = 1/$breps {
		preserve
		bsample, cluster(graduatoria)
		foreach var of varlist tousei touse2 groupeff Y1 Y0  NewInvlsum_i5_av meffect dd funds_bneuro Invsum_exavg CI_exavg_bne {
				ren `var' `var'old
		}

		getaway $covsINV, o(lsum_i5_av) s(index_std) b(5) site(graduatoria) genvar(beffect)
		g tousei =!mi(beffect) & !mi(lsum_i5_av) & !mi(deltaEpa_5)	
		replace tousei=0 if mi(beffect) 
		g touse2 = !mi(r_imppot) & r_imppot>0 & tousei

		egen groupeffc=group(agec dimimp codreg) if touse2 & win
		bys groupeffc : egen meffect = mean(beffect) if win & touse2 

		
		tabstat meffect if win & touse2, by(large) stat(mean) save

			forval i=1/2 {
				matrix aux = r(Stat`i')
				matrix bootStoreEff[`b', `i'] = aux[1, 1]
			}
			
			
		cap drop Y1 Y0
		g Y1 = .        // Potential outcome if treated
		g Y0 = .		// Potential outcome if control

		replace Y1 = lsum_i5_av if touse2 & win      // Observed: Y(T,T)
		replace Y0 = lsum_i5_av - meffect if touse2 & win   // Counterfactual: Y(T,C)

		g NewInvlsum_i5_av = sinh(Y1) - sinh(Y0)   // inverse arcsin function to obtain jobs in level

		g dd= NewInvlsum_i5_av*sum_ind5
		winsor dd, g(Invsum_exavg) p(0.01)

		gen funds_bneuro= r_imppot/1000000000
		g CI_exavg_bne=Invsum_exavg/1000000

		
		cap drop ff jj 
		cap drop gg
		cap drop CostInv

		egen ff = mean(funds_bneuro) if win==1 & touse2 , by(large)
		egen jj = mean(CI_exavg_bne) if win==1 & touse2, by(large)

		g CostInv= ff/jj

		tabstat CostInv if win & touse2, by(large) stat(mean) save

		forval i=1/2 {
			matrix aux = r(Stat`i')
			matrix bootStoreCost[`b', `i'] = aux[1, 1]
		}

		restore
	}
}

preserve
clear 
svmat bootStoreCost
svmat bootStoreEff

local alp = 10
local lb = `alp'/2
local ub = (100 - `alp') + `alp'/2

forval d = 1/2 {
	_pctile bootStoreCost`d', percentiles(`lb' `ub')
	matrix cost_large[`d',2] = r(r1)
	matrix cost_large[`d',3] = r(r2)
	
	_pctile bootStoreEff`d', percentiles(`lb' `ub')
	matrix eff_large[`d',2] = r(r1)
	matrix eff_large[`d',3] = r(r2)
}

restore

preserve
	clear
	svmat cost_large
	svmat eff_large
	g id = _n

	twoway (rspike cost_large2 cost_large3 id, lc(black) lw(medthick)) (scatter cost_large1 id, mc(black) msize(medium)),  ///
		   $gphspec title("Cost of additional investment", color(black)) xtitle("Size class") xlabel(1 "Small" 2 "Large")  ///
		   xscale(range(0.5 2.5)) legend(off) ylabel(, nogrid) nodraw name(fig11b, replace)

restore

graph combine fig11a fig11b, graphregion(color(white))
graph save "$figures/Figure_11.gph", asis replace
graph export "$figures/Figure_11.png", replace
