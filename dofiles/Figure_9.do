matrix define avc_size = J(5,3,.)
matrix define avc_age = J(5,3,.)

** get sample estimates
cap drop jj ff Avgcost
egen jj = sum(jobs) if win & touse2, by(size_qtl_5)
egen ff = sum(r_imppot_mil) if win & touse2, by(size_qtl_5)
g Avgcost = ff / jj
tabstat Avgcost if win & touse2, by(size_qtl_5) stat(mean n) save

forval i=1/5 {
	matrix aux = r(Stat`i')
	matrix avc_size[`i', 1] = aux[1, 1]
}

cap drop jj ff Avgcost
egen jj = mean(jobs) if win & touse2, by(age_qtl_5)
egen ff = mean(r_imppot_mil) if win & touse2, by(age_qtl_5)
g Avgcost = ff / jj
tabstat Avgcost, by(age_qtl_5) stat(mean) save

forval i=1/5 {
	matrix aux = r(Stat`i')
	matrix avc_age[`i', 1] = aux[1, 1]
}

drop touse2 groupeff Y1 Y0 jobs meffect

matrix define bootStoreSize = J($breps, 5, .)
matrix define bootStoreAge = J($breps, 5, .)

set seed 8894

quietly {
	local b = 1
	while `b' <= $breps {
		preserve
		bsample, cluster(graduatoria)
		
		getaway $covs, o(deltaEpa_5) s(index_std) b(5) site(graduatoria) genvar(beffect) 

		replace touse = !mi(beffect) 
		g touse2 = !mi(r_imppot) & r_imppot>0 & touse 

		egen groupeff = group(agec dimimp codreg) if touse2 & win
		bys groupeff: egen meffect = mean(beffect) if win & touse2 

		g Y1 = .        
		g Y0 = .		
		replace Y1 = lpers_anno_1 if touse2 & win == 1      
		replace Y0 = lpers_anno_1 - meffect if touse2 & win == 1  
		g jobs = sinh(Y1) - sinh(Y0)   
		
		cap drop jj ff Avgcost
		egen jj = mean(jobs) if win & touse2, by(size_qtl_5)
		egen ff = mean(r_imppot_mil) if win & touse2, by(size_qtl_5)
		g Avgcost = ff / jj
		tabstat Avgcost, by(size_qtl_5) stat(mean) save

		forval i=1/5 {
			matrix aux = r(Stat`i')
			matrix bootStoreSize[`b', `i'] = aux[1, 1]
		}

		cap drop jj ff Avgcost
		egen jj = mean(jobs) if win & touse2, by(age_qtl_5)
		egen ff = mean(r_imppot_mil) if win & touse2, by(age_qtl_5)
		g Avgcost = ff / jj
		tabstat Avgcost, by(age_qtl_5) stat(mean) save

		forval i=1/5 {
			matrix aux = r(Stat`i')
			local auxx = aux[1, 1]
			if `auxx' > 0 {
				matrix bootStoreAge[`b', `i'] = aux[1, 1]		
			} 
			else {
				continue
			}
		}
		
		local b = `b' + 1

		restore
	}
}

preserve

	clear 
	svmat bootStoreSize
	svmat bootStoreAge

	local alp = 10
	local lb = `alp'/2
	local ub = (100 - `alp') + `alp'/2

	forval d = 1/5 {
	
		_pctile bootStoreSize`d', percentiles(`lb' `ub')
		matrix avc_size[`d',2] = r(r1)
		matrix avc_size[`d',3] = r(r2)
		
		_pctile bootStoreAge`d', percentiles(`lb' `ub')
		matrix avc_age[`d',2] = r(r1)
		matrix avc_age[`d',3] = r(r2)
			
	}

restore


preserve
clear
svmat avc_age
svmat avc_size
g id = _n

twoway (rspike avc_age2 avc_age3 id, lc(black) lw(medthick)) (scatter avc_age1 id, mc(black) msize(medium)), ///
     $gphspec xtitle("quintiles of age") ytitle("Avg. Cost (thousand of €'s)") legend(off) ///
	 xlabel(1 "0-2" 2 "3-6" 3 "7-11" 4 "12-19" 5 "20+") ylabel(, nogrid) ///
	 name("avc_age", replace) nodraw

twoway (rspike avc_size2 avc_size3 id, lc(black) lw(medthick)) (scatter avc_size1 id, mc(black) msize(medium)), ///
     $gphspec xtitle("quintiles of size") ytitle("Avg. Cost (thousand of €'s)") legend(off) ///
	 xlabel(1 "0-3" 2 "3-8" 3 "8-15" 4 "15-35" 5 "35+") ylabel(, nogrid) ///
	 name("avc_size", replace) nodraw
	 
graph combine avc_size avc_age, graphregion(color(white)) rows(2) 
graph save "$figures/Figure_9.gph", replace	asis														
graph export "$figures/Figure_9.png", replace
restore
