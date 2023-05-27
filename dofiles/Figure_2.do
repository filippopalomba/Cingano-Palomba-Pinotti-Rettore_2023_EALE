import excel using "$data/Figure_1.xlsx", clear cellrange(C8) firstrow

ren Sizecells size 
ren rightaxis empl_growth
ren Grossjobcreation share_grossjob 
ren employment share_empl

g sizeNum = _n
label define size 1 "[1-3)" 2 "[3-8)" 3 "[8-15)" 4 "[15-35)" 5 "35+"
label values sizeNum size

reshape long share, i(size empl_growth) j(shareType) string

g sizeNum_empl = sizeNum + 0.1
g sizeNum_grossjob = sizeNum - 0.1
bys sizeNum: g aux = _n
twoway (bar share sizeNum_grossjob if shareType == "_grossjob", barw(0.2)) ///
	   (bar share sizeNum_empl if shareType == "_empl", barw(0.2)) ///
	   (line empl_growth sizeNum if aux == 1, yaxis(2) lw(medthick) lc(black)), ///
	   yscale(range(0 0.6)) yscale(range(-0.015 0.015) axis(2)) ///
	   ylabel(0(0.1)0.6, angle(0)) ylabel(-0.015 "-1.5%" -0.01 "-1%" -0.005 "-0.5%" 0 "0%" 0.005 "0.5%" 0.01 "1%" 0.015 "1.5%", axis(2) angle(0)) ///
	   ytitle("", axis(2)) ytitle("") xtitle("Size") ///
	   xlabel(1 "[1-3)" 2 "[3-8)" 3 "[8-15)" 4 "[15-35)" 5 "35+") ///
	   legend(lab(1 "Share of Gross job Creation") lab(2 "Share of Employment") lab(3 "Employment Growth (right axis)") position(6) rows(1)) ///
	   scheme(white_tableau)
	   
graph save "$figures/Figure_2.gph", replace asis
graph export "$figures/Figure_2.png", replace
