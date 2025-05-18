*hyun woo kim, chungbuk national university, 2025


	

*data prep

	*file use
	webuse nhanes2f, clear
	
	*recode variables
	keep health female black age diabetes
	keep if !missing(health, black, female, age, diabetes)
	
	*outcome
	fre health
	
	
	
	
*fit ordered logit model

	*null model
	ologit health
	
	*joint test of statistical significance for cutpoints
	test (_b[/cut1]=0) (_b[/cut2]=0) (_b[/cut3]=0) (_b[/cut4]=0)
	
	*predicted probabilities
	di logistic(-1.64)
	di logistic(_b[/cut1])                      //probability of being poor
	di logistic(_b[/cut2])-logistic(_b[/cut1])  //probability of being fair
	di logistic(_b[/cut3])-logistic(_b[/cut2])  //probability of being average
	di logistic(_b[/cut4])-logistic(_b[/cut3])  //probability of being good
	di 1-logistic(_b[/cut4])                    //probability of being excellent
	fre health
	
	*saturated model
	ologit health female black age
	
	*joint test of statistical significance for cutpoints
	test (_b[/cut1]=0) (_b[/cut2]=0) (_b[/cut3]=0) (_b[/cut4]=0)
	
	*predicted probabilities
	predict xbhat, xb                //you've got XB
	di logistic(_b[/cut1]-xbhat)                            //probability of being poor
	di logistic(_b[/cut2]-xbhat)-logistic(_b[/cut1]-xbhat)  //probability of being fair
	di logistic(_b[/cut3]-xbhat)-logistic(_b[/cut2]-xbhat)  //probability of being average
	di logistic(_b[/cut4]-xbhat)-logistic(_b[/cut3]-xbhat)  //probability of being good
	di 1-logistic(_b[/cut4]-xbhat)                          //probability of being excellent
	fre health

	
	
	
*interpretations

	*odds ratio
	ologit, or
	
	*predicted probabilities for each of outcomes
	su age
	margins, at(age=(20(1)74))
	marginsplot, recast(line) recastci(rarea) ciopts(color(%10)) ///
			plotopts(lwidth(medthick)) graphregion(color(white)) scheme(s1color) ///
			title("") xtitle("Age") ytitle("Predicted Probability") ///
			xlabel(20(5)75) ysize(1) xsize(1.5) /// 
			legend(order(6 "Poor" 7 "Fair" 8 "Average" 9 "Good" 10 "Excellent")) ///
			legend(position(3) ring(1) cols(1) symy(6) symx(5))
    graph export "fig3.png", replace

	*predicted probabilities for a specific outcome
	margins, at(age=(20(1)74)) predict(outcome(3))
	marginsplot, recastci(rarea)
	
	*marginal effects
	margins, dydx(age)            //ame
	marginsplot, recast(bar) name(g1, replace)
	margins, dydx(age) atmeans    //cme at the means
	marginsplot, recast(bar) name(g2, replace)
	graph combine g1 g2
	
	
	
	
*goodness-of-fit

	*wald tests
	mlogit health female black age           //multinomial
	test ([Poor]female=0) ([Fair]female=0) ([Good]female=0) ([Excellent]female=0)
	ologit health female black age           //ordinal
	test female=0
	
	*likelihood-ratio test 
	scalar lr=-2*(e(ll_0)-e(ll))
	di lr                     //lr value
	di 1-chi2(1, lr)          //p-value
	
	*-2LL or deviance
	di -2*e(ll)
	
	*model comparison
	est clear
	eststo m1: ologit health female black age //diabetes=0
	eststo m2: ologit health female black age diabetes
	esttab, nogap wide
	lrtest m1 m2
	
	*mcfadden's pseudo-r2
	di 1-(e(ll) / e(ll_0))

	*information criteria
	estat ic
	
	
	
	
	
*alternatives

	*clear up
	est clear
	
	*ordered logit
	eststo: ologit health female black age
	margins, at(age=(20(1)74))
	marginsplot, name(g1, replace)
		
	*ordered probit
	eststo: oprobit health female black age
	margins, at(age=(20(1)74))
	marginsplot, name(g2, replace)
	
	*ols with ordinal dependent variable
	eststo: reg health female black age, robust
	margins, at(age=(20(1)74))
	marginsplot, name(g3, replace)
	
	*results
	esttab, nogap wide
	graph combine g1 g2 g3, col(3) ysize(1) xsize(3)
	
	
	
*which one to be chosen

	*goodness of fit indices
	ologit health female black age
	estat ic
	di -2*(e(ll_0) - e(ll))        // deviance of ordered logit
	reg health female black age
	estat ic
	di -2*(e(ll_0) - e(ll))        // deviance of ols
	
	*joint test of statistical significance for cutpoints
	ologit health female black age
	test (_b[/cut1]=0) (_b[/cut2]=0) (_b[/cut3]=0) (_b[/cut4]=0)
	
	
	
	
	