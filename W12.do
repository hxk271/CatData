*hyun woo kim, chungbuk national university, 2025


*prep data

	*low birth-weight data
	webuse lbw, clear

	*transform into an ordinal variable
	recode bwt (0/2499=1) (2500/2999=2) (3000/3499=3) (3500/5000=4), gen(bwt4)
	ta bwt bwt4, mis
		
		


*continuation-ratio logit model

	*ln[p(y=j)/p(y<j)]
	ccrlogit bwt4 i.smoke
	
	*ln[p(y=j)/p(y>j)]
	xi: ocratio bwt4 i.smoke, link(logit)   //somewhat old user-written command
	gencrm bwt4 i.smoke, link(logit)        //more recent user-written command
	
	*replication
	revrs bwt4
	ccrlogit revbwt4 i.smoke    //make sure it is equivalent to -b
	

	
	
*"unconstrained" continuation-ratio logit model
	
	*ln[p(y=j)/p(y<j)]
	ucrlogit bwt4 lwt         //see the note below

	*ln[p(y=j)/p(y>j)]
	gencrm revbwt4 lwt, free(lwt) link(logit)     //reversed Y
	
	*compare with multinomial logit model
	est clear
	eststo: ucrlogit bwt4 smoke i.race lwt ht ui   //see the note below
	eststo: mlogit   bwt4 smoke i.race lwt ht ui
	esttab, wide


	*Example 1: Continuation-ratio model with parallel lines assumption for all variables
	gencrm bwt smoke i.race lwt ht ui

	*Continuation-ratio model with no parallel lines assumption for smoking
	gencrm bwt smoke i.race lwt ht ui, free(smoke)

	*Example 3: Continuation-ratio model with proportionality constraint for smoking
	gencrm bwt smoke i.race lwt ht ui, factor(smoke)

	

	
	
	
*adjacent-category logit models
		
	*fit to the data
	adjcatlogit bwt4 i.smoke
	
	*compare with ordered logit model
	ologit bwt4 i.smoke

	*compare with multinomial logit model with constraints
	constraint 1 [3]1.smoke = 2*[2]1.smoke
	constraint 2 [4]1.smoke = 3*[2]1.smoke
	mlogit bwt4 i.smoke, base(1) constraint(1 2)
	di _b[2:1.smoke]             //coefficient
	di _b[2:_cons]               //tau 1
	di _b[3:_cons]-_b[2:_cons]   //tau 2
	di _b[4:_cons]-_b[3:_cons]   //tau 3
	
	*reveal the constraints
	adjcatlogit bwt4 i.smoke, listconstraints

	*odds ratios
	adjcatlogit, or

	*no margins for adjcatlogit
	adjcatlogit bwt4 i.smoke i.race lwt ht ui
	su lwt
	margins, at(lwt=(80(1)250))    //not available
	
	*alternative approach for predicted probabilities and marginal effects
	adjcatlogit bwt4 i.smoke i.race lwt ht ui, listconstraints
	constraint 1 [3]1.smoke = 2*[2]1.smoke
	constraint 2 [4]1.smoke = 3*[2]1.smoke
	constraint 3 [3]2.race = 2*[2]2.race
	constraint 4 [4]2.race = 3*[2]2.race
	constraint 5 [3]3.race = 2*[2]3.race
	constraint 6 [4]3.race = 3*[2]3.race
	constraint 7 [3]lwt = 2*[2]lwt
	constraint 8 [4]lwt = 3*[2]lwt
	constraint 9 [3]ht = 2*[2]ht
	constraint 10 [4]ht = 3*[2]ht
	constraint 11 [3]ui = 2*[2]ui
	constraint 12 [4]ui = 3*[2]ui
	mlogit bwt4 i.smoke i.race lwt ht ui, base(1) constraint(1/10)
	margins, at(lwt=(80(1)250))
	marginsplot, noci
	margins, dydx(lwt)
	marginsplot, recast(bar)
	

	
	
*stereotype logit model
		
	*fit to the data
	slogit bwt4 i.smoke, base(1)
	
	*compare with multinomial logit model
	mat list e(b)
	di -1 * _b[dim1: 1.smoke] * _b[phi1_2: _cons]
	di -1 * _b[dim1: 1.smoke] * _b[phi1_3: _cons]
	di -1 * _b[dim1: 1.smoke] * _b[phi1_4: _cons]
	mlogit bwt4 i.smoke, base(1)
	
	*fit to the data
	slogit bwt4 i.smoke i.race lwt ht ui, base(1)
	
	*joint significance test for rank order across items
	test [phi1_1]_cons = [phi1_2]_cons = [phi1_3]_cons
	
	*predicted probabilities
	qui su price
	margins, at(price=(`r(min)'(1000)`r(max)'))
	marginsplot, name(g2, replace) noci

	*goodness-of-fit
	estat ic
		
	