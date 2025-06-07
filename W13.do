*hyun woo kim, chungbuk national university, 2025




*basic concepts

	*data structure
    webuse dollhill3, clear
	sort agecat smoke
    
    *fit poisson model
    poisson deaths smokes i.agecat
	
	*exposure
	poisson deaths smokes i.agecat, exposure(pyears)
	
	*mortality rate as incidence-rate ratio
	poisson deaths smokes i.agecat, exposure(pyears) irr

	*unconstrained and constrained exposure coefficients, and offset
	gen ln_pyears=ln(pyears)
	poisson deaths smokes i.agecat ln_pyears, irr

	constraint 1 ln_pyears=1
	poisson deaths smokes i.agecat ln_pyears, irr constraint(1)
	
	poisson deaths smokes i.agecat, irr offset(ln_pyears)
	
	
	
		
*data prep
	
	import delimited using "https://stats.idre.ucla.edu/stat/data/poisson_sim.csv", clear
	
	sort id
	label var num_awards "the number of awards earned by students at a high school in a year"
	label var math "students' scores on their math final exam"
	label var prog "the type of program in which the students were enrolled"	
	label def prog 1 "General" 2 "Academic" 3 "Vocational"
	label val prog prog
	
	hist num_awards

	
	

				
		
*poisson regression model

	*no exposure here
	poisson num_awards math i.prog, irr
	
	*predicted count
	predict predcount, n
	su math
	margins, at(math=(33(1)75))
	marginsplot, recast(line) recastci(rarea)
	
	*P(Y=y|X)
	predict predc0, pr(0)     //0
	predict predc1, pr(1)     //1
	predict predc2, pr(2,.)   //2 or more
	egen rowt=rowtotal(predc0 predc1 predc2)      //make sure 1
	
	*average marginal effect
	margins, dydx(*)
	
	
	
	
	
	
*goodness of fit

	*likelihood-ratio test 1
	ereturn list           //e-class returns
	di -2*(e(ll_0)-e(ll))  //-2LL or deviance
	
	*likelihood-ratio test 2
	est clear
	eststo m1: poisson num_awards math
	eststo m2: poisson num_awards math i.prog
	lrtest m1 m2
	
	*pseudo r-squared
	di 1-(e(ll)/e(ll_0))
	
	*aic and bic
	est clear
	poisson num_awards math i.prog, irr
	estat ic
	di -2*e(ll)+2*(e(rank))          //aic
	di -2*e(ll)+e(rank)*ln(e(N))     //bic
	
	*pearson's chi-squared gof statistics
	estat gof
	
	
	
	
*negative binomial regression model

	nbreg num_awards math i.prog, irr
	
	*chi2 test for alpha=0
	scalar ll_nb=e(ll)
	poisson num_awards math i.prog
	scalar ll_p=e(ll)
	di 2*(ll_nb-ll_p)    //chi2
	di .5 * (1-chi2(1, 2*(ll_nb-ll_p)))
		
		
		
		
		
*model comparison
	
	gen ln_num_awards=ln(num_awards+1)
	
	est clear
	eststo: reg num_awards math i.prog
	eststo: reg ln_num_awards math i.prog
	eststo: poisson num_awards math i.prog
	eststo: nbreg num_awards math i.prog
	esttab, wide
	
	

	

*zero-inflated poisson and negative binomial regression model
	
	*data prep
	webuse fish, clear
	
	*inflated zeroes
	hist count
	
	*fit zero-inflated Poisson model
	est clear
	eststo: poisson count persons livebait, irr
	eststo: zip count persons livebait, inflate(child camper) irr
	esttab, nogap wide 
	
	
	
