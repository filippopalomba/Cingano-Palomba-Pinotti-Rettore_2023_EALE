quietly {
	cap drop lsat
	qui areg deltaEpa_5 $spec, cluster(graduatoria) abs(graduatoria)
	local effempl=_b[win]
	gen lsat=e(sample)

	sum pers_anno_1 if abs(index_std)<0.5 & lsat==1, d
	local l0=`r(mean)'
	sum r_imppot if abs(index_std)<0.5 & lsat==1 , d
	local funds=`r(mean)'

	noisily: display "		   | Tr Effect |  Init Empl  | New Jobs | Funds | Cost/job " 
	noisily: display "all firms        | " $_effempl " | " $_l0 " | " $_l0*$_effempl " | " $_funds  " | " int($_funds/($_l0*$_effempl))

	forvalues m=0/1 {
		preserve
		keep if abovemedian==$_m

		qui areg deltaEpa_5 $spec, cluster(graduatoria) abs(graduatoria)
		local effempl=_b[win]
		gen lsa=e(sample)
		sum pers_anno_1 if abs(index_std)<0.5 & lsa==1, d
		local l0=`r(mean)'
		sum r_imppot if abs(index_std)<0.5 & lsa==1, d
		local funds=`r(mean)'

		noisily: display "		   | Tr Effect |  Init Empl  | New Jobs | Funds | Cost/job " 
		noisily: display "abovemedian=$_m      | " $_effempl " | " $_l0 " | " $_l0*$_effempl " | " $_funds  " | " int($_funds/($_l0*$_effempl))
		restore
	}
}
