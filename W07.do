*hyun woo kim, chungbuk national university, 2025


*data prep

	*file: alligator data
	import delimited using "https://users.stat.ufl.edu/~aa/glm/data/Alligators3.dat", ///
			 delim(whitespace) varnames(1) clear
			 
	*recoding
	drop v1 length food v5 v6 v7 v9 v10
	ren v3 length
	encode v8, gen(food)
	drop v8
	ta food

	
	
*estimates

	mlogit food length
	mlogit food length, base(3)         //change the base outcome
	mlogit food length, base(3) rrr     //relative risk ratio

	*equivalent to _b[F:length] when the base outcome is O
	mlogit food length, base(2)
	di _b[F:length]-_b[O:length]
	mlogit food length, base(3)
	
	
	
	
	
	
*predicted probabilities

	*prediction
	predict type1 type2 type3, pr      //respectively F, I, O
	hist type1
	graph twoway (connected type1 length) ///
	             (connected type2 length) ///
				 (connected type3 length)

	*plot
	su length
	margins, at(length=(1.24(0.1)3.89))
	marginsplot, noci               //without ci
	marginsplot, recastci(rarea)    //with ci

	
	
	
*significance test

	*get estimates, again
	mlogit food length, base(3)
	
	*wald test
	test [F]length=0

	
	
	
*goodness of fit

	*lr test
	ereturn list    //e-class returns of mlogit
	di -2*(e(ll_0)-e(ll))     //-2LL

	*pseudo r-squared
	di 1-(e(ll)/e(ll_0))
	
	*aic and bic
	estat ic
	di -2*e(ll)+2*e(k)         //aic
	di -2*e(ll)+e(k)*ln(e(N))  //bic
	