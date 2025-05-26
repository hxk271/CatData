*hyun woo kim, chungbuk national university, 2025


	
	
	
*data prep

	*file use
	webuse nhanes2f, clear
	
	*recode variables
	keep health female black age diabetes
	keep if !missing(health, black, female, age, diabetes)
	
	
	
	
*goodness-of-fit

	*wald test for multinomial logit
	mlogit health female black age
	test ([Poor]female=0) ([Fair]female=0) ([Good]female=0) ([Excellent]female=0)
	
	*wald test for ordered logit
	ologit health female black age
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
	
	*hosmer-lemeshow goodness-of-fit
	ologit health female black age diabetes
	ologitgof, osvar(oscore) tableHL
	
	predict pr1-pr5, pr       //so-called "ordinal scores"
	gen E=1*pr1+2*pr2+3*pr3+4*pr4+5*pr5
	gen O=health
	gen chisq=((O-E)^2)/E
	egen tot=total(chisq)
	di 1-chi2(35, tot)
	
	
	
	
	
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
	
	
	
	
	
*parallel regression assumption

	*example 1: not violated
	ta black health, row nofreq
	scalar num=(.1326)/(.2228+.3297+.1805+.1344)  // p(y<=1|x+1)/p(y>1|x+1)
	scalar den=(.0633)/(.1544+.2789+.2589+.2445)  // p(y<=1|x) / p(y>1|x)
	scalar or1=num/den                            // odds ratio
	di or1
	scalar num=(.1326+.2228)/(.3297+.1805+.1344)  // p(y<=2|x+1)/p(y>2|x+1)
	scalar den=(.0633+.1544)/(.2789+.2589+.2445)  // p(y<=2|x) / p(y>2|x)
	scalar or2=num/den                            // odds ratio
	di or2
	scalar num=(.1326+.2228+.3297)/(.1805+.1344)  // p(y<=3|x+1)/p(y>3|x+1)
	scalar den=(.0633+.1544+.2789)/(.2589+.2445)  // p(y<=3|x) / p(y>3|x)
	scalar or3=num/den                            // odds ratio
	di or3	
	scalar num=(.1326+.2228+.3297+.1805)/(.1344)  // p(y<=4|x+1)/p(y>4|x+1)
	scalar den=(.0633+.1544+.2789+.2589)/(.2445)  // p(y<=4|x) / p(y>4|x)
	scalar or4=num/den                            // odds ratio
	di or4
	
	*canned commands
	ologit health black
	di exp(-_b[black])
	oparallel
	omodel logit health black
	*brant    //outdated
		
	*example 2: violated
	ta female health, nofreq row
	scalar num=(.0640)/(.1747+.2945+.2540+.2129)  // p(y<=1|x+1)/p(y>1|x+1)
	scalar den=(.0778)/(.1471+.2730+.2471+.2550)  // p(y<=1|x) / p(y>1|x)
	scalar or1=num/den                            // odds ratio
	di or1	
	scalar num=(.0640+.1747)/(.2945+.2540+.2129)  // p(y<=1|x+1)/p(y>1|x+1)
	scalar den=(.0778+.1471)/(.2730+.2471+.2550)  // p(y<=1|x) / p(y>1|x)
	scalar or2=num/den                            // odds ratio
	di or2
	scalar num=(.0640+.1747+.2945)/(.2540+.2129)  // p(y<=1|x+1)/p(y>1|x+1)
	scalar den=(.0778+.1471+.2730)/(.2471+.2550)  // p(y<=1|x) / p(y>1|x)
	scalar or3=num/den                            // odds ratio
	di or3
	scalar num=(.0640+.1747+.2945+.2540)/(.2129)  // p(y<=1|x+1)/p(y>1|x+1)
	scalar den=(.0778+.1471+.2730+.2471)/(.2550)  // p(y<=1|x) / p(y>1|x)
	scalar or4=num/den                            // odds ratio
	di or4
	

	*canned commands
	ologit health female
	di exp(-_b[female])
	omodel logit health female
	
	
	
*generalized ordered logit model
	
	*compare with the above
	gologit2 health female
	di exp(-_b[Poor:female])
	di exp(-_b[Fair:female])
	di exp(-_b[Average:female])
	di exp(-_b[Good:female])     
	
	*simplify with autofit option
	gologit2 health female, autofit
	gologit2 health black, autofit
	
	*compare with the multinomial logit model
	gologit2 health female black age
	mlogit health female black age, b(1)

	

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
	
	
	