* loop over Panel A, Panel B, and Panel C
foreach var in lcumul_inv2 deltaEpa_2 deltaEpa_5 {

	* all firms - linear and quadratic, columns (1) and (2)
	areg $_var win index_std winxindex_std, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", replace $outreg2opt

	areg $_var win index_std winxindex_std index_std2 winxindex_std2, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", append $outreg2opt

	* small (below-median) - linear and quadratic, columns (3) and (4)
	areg $_var win index_std winxindex_std if abovemedian==0, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", append $outreg2opt

	areg $_var win index_std winxindex_std index_std2 winxindex_std2 if abovemedian==0, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", append $outreg2opt

	* large (above-median) - linear and quadratic, columns (5) and (6)
	areg $_var win index_std winxindex_std if abovemedian==1, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", append $outreg2opt

	areg $_var win index_std winxindex_std index_std2 winxindex_std2 if abovemedian==1, cluster(graduatoria) abs(graduatoria)
	outreg2 win using "$tables/Table1_`var'.xls", append $outreg2opt

}
