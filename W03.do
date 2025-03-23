*hyun woo kim, chungbuk national university, 2025



*file use
webuse lbw, clear


*visualization

	*scatterplot of low against bwt
	graph twoway (scatter low bwt) (lfit low bwt)
	
	*bwt versus lwt
	graph twoway (scatter bwt lwt) (lfit bwt lwt)


	

*logit model

	*logit command
	logit low lwt

	*wald test
	scalar chi2=(_b[lwt]/_se[lwt])^2
	di chi2                //chi2 value
	di 1-chi2(1, chi2)     //p-value
	test lwt=0             //canned command	

	*odds ratio 1
	logit low smoke, or
	logit low smoke
	di exp(_b[smoke])-1   //odds ratio of smoke

	*odds ratio 2
	logit low lwt, or
	logit low lwt
	di 1-exp(_b[lwt])     //1-odds ratio of lwt
	
	
	
	
*comparing ols and logit
		
	*get estimates
	est clear
	eststo: reg   bwt lwt
	eststo: reg   low lwt
	eststo: logit low lwt
	esttab, nogap wide

	*visualizing coefficients
	margins, at(lwt=(80(1)250))
	marginsplot

	*predicting y hat
	reg low lwt
	margins, at(lwt=(80(5)250))
	marginsplot, name(g1, replace)
	
	*predicting probability
	logit low lwt
	predict pr, pr
	margins, at(lwt=(80(5)250))
	marginsplot, name(g2, replace)

	*graph combination
	graph combine g1 g2
		
	*with covariates
	est clear
	eststo: reg   bwt smoke age lwt ht
	eststo: reg   low smoke age lwt ht
	eststo: logit low smoke age lwt ht
	esttab, nogap wide

	
	
	
*goodness-of-fit	

	*likelihood-ratio test 
	logit low lwt                  //model 1
	scalar lr=-2*(e(ll_0)-e(ll))
	di lr              //lr value
	di 1-chi2(1, lr)   //p-value
	di -2*e(ll)        //-2LL or deviance  

	*aic
	logit low age lwt ht
	estat ic
	logit low age lwt ui
	estat ic

	*introducing race variable
	est clear
	eststo m1: logit low smoke age lwt ht ui
	estat ic
	estat class
	eststo m2: logit low smoke age lwt ht ui i.race
	estat ic
	estat class
	lrtest m1 m2, stats
	esttab, nogap wide

	*so-called "r2"
	reg   low smoke age lwt ht ui     //real r2
	logit low smoke age lwt ht ui     //pseudo r2
	eret list                         //e(r2_p)
	di 1-(e(ll) / e(ll_0))            //mcfadden's or pseudo-r2
