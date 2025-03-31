*hyun woo kim, chungbuk national university, 2025



*file use: hong. ch. 7 replication
	
	import spss using "logistic-example.sav", clear
	drop if missing(pass, sc, lc, sex, race, science)

	
	
*interpretation: marginal effects

	*average marginal effect (ame)
	logit pass science i.sex
	margins, dydx(science)

	*average marginal effect: replication
	predict phat, pr
	gen me=_b[science] * phat * (1 - phat)      //see perraillon p. 56
	hist me    //distribution of 'individual' marginal effects
	su me      //the average of 'individual' marginal effects
	
	*average marginal effect of dummy variables
	margins, dydx(race)                 //logit must contain i.race

	*average marginal effects total
	margins, dydx(*)
	marginsplot, recast(bar)

	*coefplot after logit
	logit pass i.sex i.race
	coefplot, drop(_cons) base
	margins, dydx(*) post        //post means save
	coefplot, drop(_cons) base
	
	*conditional marginal effect, other variables being controlled at the means
	logit pass science i.sex i.race
	margins, dydx(science) atmeans
	margins, dydx(science) at(sex=1 race=1)  //it may make more sense.
	
	
	
	

*goodness-of-fit	

	*null model (p. 63)
	logit pass

	*classification table or confusion matrix (p. 62)
	estat class
	
	*full model (p. 68)
	logit pass sc lc b2.sex b4.race science
		
	*classification table or confusion matrix (p. 65)
	estat class
	
	*roc (receiver operating characteristic) curve
	lroc
	
	*sensitivity-specificity trade-off
	lsens
	
	*likelihood-ratio test 
	scalar lr=-2*(e(ll_0)-e(ll))
	di lr                     //lr value
	di 1-chi2(1, lr)          //p-value
	di -2*e(ll)               //-2LL or deviance (p. 64)

	*likelihood-ratio test for model comparison
	est clear
	eststo m1: logit pass sc lc b2.sex b4.race
	estat ic
	estat class
	eststo m2: logit pass sc lc b2.sex b4.race science
	estat ic
	estat class
	lrtest m1 m2, stats
	esttab, nogap wide
	
	*so-called "pseudo-r2"
	eret list
	di 1-(e(ll) / e(ll_0))    //mcfadden's

	*aic
	logit pass sc lc b2.sex b4.race science
	estat ic
	logit pass sc lc b2.sex b4.race reading
	estat ic
	
	*predicted probability (pp. 69-70)
	logit pass sc lc b2.sex b4.race science
	margins, at(race=1 sc=15 lc=17 science=56.37)