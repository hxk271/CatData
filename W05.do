*hyun woo kim, chungbuk national university, 2025



*file use

	*instructional dataset, n=753, cross-sectional labor force participation data
	use "http://www.stata.com/data/jwooldridge/eacsap/mroz.dta", clear

	*recoding variables
	recode kidslt6 (0=0) (1 2 3=1), gen(baby)
	label def baby 0 "No kids < 6yrs" 1 "kids < 6yrs"
	label val baby baby

	*dependent variable
	ta inlf
	
	
	
*linear probability model

	*get estimates
	est clear
	eststo: reg inlf kidslt6 age i.baby educ huswage i.city exper
	
	*get the predicted y
	predict yhat, xb
	correl inlf yhat
	
	*visualization
	graph twoway (lfit yhat exper, lcolor(black)) ///
	             (scatter yhat exper, ytitle("P(=1 if in lab frce, 1975)"))
	
	
	
*logit model

	*get estimates
	eststo: logit inlf kidslt6 age i.baby educ huswage i.city exper
	
	*comparison
	esttab, nogap wide
	
	*plotting the predicted probabilities
	margins, at(age=(30(1)60))    //continuous
	marginsplot
	margins, by(baby)             //categorical
	marginsplot, recast(bar)
	
	*average marginal effect
	eststo: logit inlf kidslt6 age i.baby educ huswage i.city exper
	margins, dydx(*) post         //make a result table for practice
	
	
	
	
*alternative regression models
	
	*introduction to probit model
	di normal(1.96)       //Phi(z)=p
	di invnormal(.975)    //Phi^(-1)(p)=z
	
	*interpretation of probit model
	probit pass b1.sex
	scalar z=_b[2.sex]*1+_b[_cons]     //z
	di z
	di normal(z)
	margins, by(sex)
	
	*logit, probit, and complementary log-log
	est clear
	eststo: logit pass sc lc b2.sex b4.race science
	margins, by(race)
	marginsplot, name(g1, replace) recast(bar)
	eststo: probit pass sc lc b2.sex b4.race science
	margins, by(race)
	marginsplot, name(g2, replace) recast(bar)
	eststo: cloglog pass sc lc b2.sex b4.race science
	margins, by(race)
	marginsplot, name(g3, replace) recast(bar)
	esttab, nogap wide
	graph combine g1 g2 g3, col(3) ycommon
