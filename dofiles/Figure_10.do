g touse = 1 // auxiliary var to compute quantiles on active sub-sample
foreach var of varlist agec ng_1 age_lgn g1_10 relw_wc10 dir app lp deltaEpa_5 lpers_anno_1 {
	replace touse = 0 if mi(`var')
}

* Quantile binning
xtile size_qtl_5 = lpers_anno_1 if touse, nq(5)
gen age_qtl_5 = agec

* check CIA holds
ciatest $covs, outcome(deltaEpa_5) score(index_std) bandwidth(5) site(graduatoria) vce(graduatoria) details
ciares $covs, outcome(deltaEpa_5) score(index_std) bandwidth(5) nb(30) site(graduatoria) gphoptions($gphspec title("") leg(off))
ciacs $covs, o(deltaEpa_5) s(index_std) b(5) a(win) site(graduatoria) gphoptions($gphspec title("") leg(off))

* compute treatment effect away from the cutoff
getaway $covs, o(deltaEpa_5) s(index_std) b(5) site(graduatoria) genvar(effect) 

replace touse = !mi(effect) 
g touse2 = !mi(r_imppot) & r_imppot>0 & touse 
g r_imppot_mil = r_imppot/1000

egen groupeff = group(agec dimimp codreg) if touse2 & win
bys groupeff: egen meffect = mean(effect) if win & touse2 

g Y1 = .        // Potential outcome if treated
g Y0 = .		// Potential outcome if control
replace Y1 = lpers_anno_1 if touse2 & win ==1      // Observed: Y(T,T)
replace Y0 = lpers_anno_1 - meffect if touse2 & win ==1  // Counterfactual: Y(T,C)
g jobs = sinh(Y1) - sinh(Y0)   // inverse arcsin function to obtain jobs in level

egen jj = mean(jobs) if win & touse2, by(size_qtl_5 age_qtl_5)
egen ff = mean(r_imppot_mil) if win & touse2, by(size_qtl_5 age_qtl_5)
g Avgcost = ff / jj

heatplot meffect i.age_qtl_5 i.size_qtl_5 if touse2, colors(YlOrRd) ytitle("Size") xtitle("Age") ///
	xlabel(1 "0-2" 2 "3-6" 3 "7-11" 4 "12-19" 5 "20+", labsize(small) angle(45))                 ///
	ylabel(1 "0-3" 2 "3-8" 3 "8-15" 4 "15-35" 5 "35+",nogrid labsize(small))                     /// 
	$gphspec keylabels(, format(%12.2f)) legend(title("") subtitle(""))                          ///
	title("Treatment Effect", color(black)) nodraw name(heat_effect, replace)


heatplot Avgcost i.size_qtl_5 i.age_qtl_5 if touse2, colors(YlOrRd) ytitle("Size") xtitle("Age") ///
	xlabel(1 "0-2" 2 "3-6" 3 "7-11" 4 "12-19" 5 "20+", labsize(small) angle(45))                 ///
	ylabel(1 "0-3" 2 "3-8" 3 "8-15" 4 "15-35" 5 "35+",nogrid labsize(small)) 					 ///
	$gphspec cuts(0 100 200 300 400 500 750 1250 1750) title("Cost per new job")                 ///
	legend(title("") subtitle("")) keylabels(, format(%12.0f)) nodraw name(heat_avg, replace)

graph combine heat_effect heat_avg, graphregion(color(white)) xsize(12) ysize(5)
graph save "$figures/Figure_10.gph", replace asis														
graph export "$figures/Figure_10.png", replace
