foreach var in lcumul_inv2 lpers_anno2 lpers_anno5 {
	
	* all firms
	preserve
	bys graduatoria: egen m$_var=mean($_var)

	areg $_var $spec, cluster(graduatoria) abs(graduatoria)
	predict fit
	predict fitsd, stdp
	gen upfit=fit+1.645*fitsd
	gen downfit=fit-1.645*fitsd

	bys bin: egen mean=mean($_var)
	bys bin: egen n=count($_var)
	bys bin: egen stdev=sd($_var)
	gen upmean=mean+1.645*stdev/(n^0.5)
	gen lowmean=mean-1.645*stdev/(n^0.5)

	sort bin
	replace mean=. if bin==bin[_n-1]
	replace upmean=. if bin==bin[_n-1]
	replace lowmean=. if bin==bin[_n-1]

	twoway (rarea upfit downfit index_std, sort fcolor(gs12) lcolor(gs12))                   ///
		   (line fit index_std if index_std<0, sort lcolor(red) lwidth(thick))               ///
		   (line fit index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick))           ///
		   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)),                      ///
		   ytitle("") xtitle("Score") xline(0, lcolor(black)) legend(off)                    ///
		   xlabel(-$bandwidth(1)$bandwidth) title("All firms", color(black)) ylabel(,nogrid) ///
		   $gphspec nodraw name(`var', replace)
	 restore
	 

	* below median
	preserve
	keep if abovemedian==0

	bys graduatoria: egen m$_var=mean($_var)

	areg $_var $spec, cluster(graduatoria) abs(graduatoria)
	predict fit
	predict fitsd, stdp
	gen upfit=fit+1.645*fitsd
	gen downfit=fit-1.645*fitsd

	bys bin: egen mean=mean($_var)
	bys bin: egen n=count($_var)
	bys bin: egen stdev=sd($_var)
	gen upmean=mean+1.645*stdev/(n^0.5)
	gen lowmean=mean-1.645*stdev/(n^0.5)

	sort bin
	replace mean=. if bin==bin[_n-1]
	replace upmean=. if bin==bin[_n-1]
	replace lowmean=. if bin==bin[_n-1]

	twoway (rarea upfit downfit index_std, sort fcolor(gs12) lcolor(gs12))                   ///
		   (line fit index_std if index_std<0, sort lcolor(red) lwidth(thick))               ///
		   (line fit index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick))           ///
		   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)),                      ///
		   ytitle("") xtitle("Score") xline(0, lcolor(black)) legend(off)                    ///
		   xlabel(-$bandwidth(1)$bandwidth) ylabel(,nogrid) 								 ///
		   $gphspec nodraw name(`var'_bm, replace) title("Below median sized firms", color(black))	 
	restore
		   
	* above median
	preserve
	keep if abovemedian==1

	bys graduatoria: egen m$_var=mean($_var)

	areg $_var $spec, cluster(graduatoria) abs(graduatoria)
	predict fit
	predict fitsd, stdp
	gen upfit=fit+1.645*fitsd
	gen downfit=fit-1.645*fitsd

	bys bin: egen mean=mean($_var)
	bys bin: egen n=count($_var)
	bys bin: egen stdev=sd($_var)
	gen upmean=mean+1.645*stdev/(n^0.5)
	gen lowmean=mean-1.645*stdev/(n^0.5)

	sort bin
	replace mean=. if bin==bin[_n-1]
	replace upmean=. if bin==bin[_n-1]
	replace lowmean=. if bin==bin[_n-1]

	twoway (rarea upfit downfit index_std, sort fcolor(gs12) lcolor(gs12))                   ///
		   (line fit index_std if index_std<0, sort lcolor(red) lwidth(thick))               ///
		   (line fit index_std if index_std>0, sort lcolor(dkgreen) lwidth(thick))           ///
		   (scatter mean midbin, msymbol(circle_hollow) mcolor(black)),                      ///
		   ytitle("") xtitle("Score") xline(0, lcolor(black)) legend(off)                    ///
		   xlabel(-$bandwidth(1)$bandwidth) ylabel(,nogrid) 								 ///
		   $gphspec nodraw name(`var'_am, replace) title("Above median sized firms", color(black))	 
	restore
  
}

* create figure 6
graph combine lcumul_inv2 lcumul_inv2_bm lcumul_inv2_am, cols(3) xsize(12) ysize(3) ycommon graphregion(color(white))
graph save "$figures/Figure_6.gph", replace asis
graph export "$figures/Figure_6.png", replace

* create figure 7
graph combine lpers_anno2 lpers_anno2_bm lpers_anno2_am lpers_anno5 lpers_anno5_bm lpers_anno5_am, cols(3) ///
		xsize(12) ysize(6) scale(0.8) ycommon graphregion(color(white))
graph save "$figures/Figure_7.gph", replace asis
graph export "$figures/Figure_7.png", replace
