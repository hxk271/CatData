*hyun woo kim, chungbuk national university, 2025


*file

	webuse sysdsn1, clear
	sort patid
	isid patid    //unique id


*result table

	mlogit insure age male i.nonwhite i.site, base(3)
	esttab, nogap wide
	esttab using "table.csv", nogap unstack eform replace
	pwd   //folder to be saved

	
	
	
*predicted probabilities

	*predicted probabilities of outcomes, by age
	margins, at(age=(18(1)86))
	marginsplot, recastci(rarea)
	

	
*marginal effects
	
	*average marginal effects of each outcome
	margins, dydx(nonwhite)
	marginsplot, recast(bar)
	margins, dydx(age)
	marginsplot, recast(bar)

	*conditional marginal effects at the means
	margins, dydx(nonwhite) atmeans
	margins, dydx(age) atmeans
	
	*contrasts of predicted probabilities
	margins r.nonwhite
	
	*contrasts of average marginal effects of each outcome w.r.t. age
	margins r.nonwhite, dydx(age)
	marginsplot, recast(bar)
	
	
	 
	
	
*independence of irrelevant alternatives (or IIA)

	*model comparison 1
	est clear
	mlogit insure age male, base(1)
	eststo m1
	mlogit insure age male if insure!=3
	eststo m2
	esttab, unstack
	
	*hausman-mcfadden specification test
	hausman m2 m1, alleqs constant         //does not work appropriately

	*model comparison 2
	est clear
	mlogit insure age male nonwhite i.site, base(1)
	eststo m1
	mlogit insure age male nonwhite i.site if insure!=3
	eststo m2
	esttab, unstack
	
	*hausman-mcfadden specification test
	hausman m2 m1, alleqs constant         //does not work appropriately

	
	
	
	


*multinomial probit


	*model comparison
	est clear
	eststo: mlogit insure age male i.nonwhite i.site, base(3)
	margins, dydx(age)
	marginsplot, recast(bar) name(g1, replace)
	eststo: mprobit insure age male i.nonwhite i.site, base(3)
	margins, dydx(age)
	marginsplot, recast(bar) name(g2, replace)
	esttab, nogap wide   //did not 'unstack'
	
	graph combine g1 g2
