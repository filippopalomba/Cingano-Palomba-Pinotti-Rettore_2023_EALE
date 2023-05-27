rddensity index_std if abovemedian==0, plot plot_grid(es) plot_range(-$bandwidth $bandwidth) hist_range(-$bandwidth $bandwidth) hist_n(30) ///
	graph_opt(xtitle("Score") ylabel(,nogrid) legend(off) xlabel(-5(1)5) title("Below median sized firms", color(black)) $gphspec nodraw name(mccrary_belowmedian, replace)) 

rddensity index_std if abovemedian==1, plot plot_grid(es) plot_range(-$bandwidth $bandwidth) hist_range(-$bandwidth $bandwidth) hist_n(30) ///
	graph_opt(xtitle("Score") ylabel(,nogrid) legend(off) xlabel(-5(1)5) title("Above median sized firms", color(black)) $gphspec nodraw name(mccrary_abovemedian, replace)) 

graph combine mccrary_belowmedian mccrary_abovemedian, xsize(12) ysize(5) cols(3) scale(1.5) graphregion(color(white))
graph save "$figures/Figure_3.gph", replace asis
graph export "$figures/Figure_3.png", replace
