*hyun woo kim, chungbuk national university, 2025


*karaca-mandic, norton, and dowd (2012)

	*toy data
	webuse margex, clear
	ren sex female

	*wrong variable generation for interaction effects
	gen agexfemale=age*female
	su outcome age female agexfemale

	/*
	Cross-partial derivatives of continous variable and discrete variable are
	different. Before using margins command, you need to specify the
	relationship between variables.
	
	To specify female as a dummy variable, you should use
	"logit outcome c.age##i.female",
	not "logit outcome age female agexfemale",
	which assumes female as a continous	variable.
	*/

	*check that interaction term is negative and not significant
	logit outcome c.age##i.female
	
	*check that d^2(outcome)/d(age)d(female) is positive and significant! See pp. 270-271.
	
	*use margins, if dummy
	margins r.female, dydx(age)

	*use margins, if continuous, on average
	margins, dydx(female) at(age=(20 21 30 31 40 41 50 51 60 61)) post
	di _b[1.female:2._at]-_b[1.female:1._at]  //21-20
	di _b[1.female:4._at]-_b[1.female:3._at]  //21-20
	di _b[1.female:6._at]-_b[1.female:5._at]  //21-20
	di _b[1.female:8._at]-_b[1.female:7._at]  //21-20
	
	di ((_b[1.female:2._at]-_b[1.female:1._at])+    ///
		(_b[1.female:4._at]-_b[1.female:3._at])+    ///
		(_b[1.female:6._at]-_b[1.female:5._at])+    ///
		(_b[1.female:8._at]-_b[1.female:7._at]))/4
	
	
	*use predictnl
	logit outcome age female c.age##i.female
	
	*PDF(xb)=b*p*(1-p), female=1
	predictnl phat1=(_b[age]+_b[c.age#1.female])* ///
	   (1/(1+exp(-(_b[_cons]+_b[age]*age+_b[female]+_b[c.age#1.female]*age))))*  ///
	(1-(1/(1+exp(-(_b[_cons]+_b[age]*age+_b[female]+_b[c.age#1.female]*age))))), ///
		                                                            se(phat1_se)
	
	*PDF(xb)=b*p*(1-p), female=0
	predictnl phat0=(_b[age])* ///
	   (1/(1+exp(-(_b[_cons]+_b[age]*age))))*  ///
	(1-(1/(1+exp(-(_b[_cons]+_b[age]*age))))), se(phat0_se)

	*see the results
	su phat*
	di .0137921-.0097216      //.0040705

	
	
	
		
	
	
*predicted probability curve
	
	*the boston hdma data, a cross-section from 1997-1998 	
	import delimited using "https://www.stat.auckland.ac.nz/~wild/data/Rdatasets/csv/Ecdat/Hdma.csv" ,clear
	
	*encoding
	foreach i of varlist pbcr dmi self single black deny {
		replace `i'="" if `i'=="NA"
		label def yesno 0 "no" 1 "yes", replace
		encode `i', gen(_temp) label(yesno)
		drop `i'
		ren _temp `i'
		}
	
	*labels
	label var dir "debt payments to total income ratio"
	label var hir "housing expenses to income ratio"
	label var lvr "ratio of size of loan to assessed value of property"
	label var ccs "consumer credit score from 1 to 6 (a low value being a good score)"
	label var mcs "mortgage credit score from 1 to 4 (a low value being a good score)"
	label var pbcr "public bad credit record ?"
	label var dmi "denied mortgage insurance ?"
	label var self "self employed ?"
	label var single "is the applicant single ?"
	label var uria "1989 Massachusetts unemployment rate in the applicant's industry"
	label var comdominiom "is unit condominium ?"
	label var black "is the applicant black ?"
	label var deny "mortgage application denied ?"

	*examining hir
	hist hir
	su hir, det
	ta hir
	
	*get logit estimates 1
	est clear
	eststo: logit den i.self i.single i.pbcr uria lvr i.black c.hir
	eststo: logit den i.self i.single i.pbcr uria lvr i.black##c.hir
	esttab, nogap wide
	
	*plotting predicted probabilities (continuous x dummy)
	su hir, det
	margins, at(lvr=(0(0.01)1.1)) by(black)
	marginsplot, recast(line) recastci(rarea)
	
	*get logit estimates 2
	eststo: logit den i.self i.single i.pbcr uria i.black c.lvr##c.hir
	esttab, nogap wide
	
	*plotting predicted probabilities (continuous x continuous)
	su lvr hir, det
	margins, at(lvr=(0(0.01)1.1) hir=(0 .214 .26 .2988))  //try without hir==1.1
	marginsplot, recast(line) recastci(rarea) ciopts(color(black%10))
	
	/* lvr, hir, and dir are heavily skewed. */
	
	
		
	
*uberti (2022)

	*data prep
	webuse mroz, clear
	gen nokid = (kidslt6==0)
	
	*get logit estimates
	logit inlf c.nwifeinc c.educ c.nwifeinc#c.educ i.nokid
	
	*basic
	margins, dydx(nwifeinc) at(educ=(5(1)17))
	marginsplot, recast(line) recastci(rarea) name(g0, replace)
	
	*scenario 1
	margins, dydx(nwifeinc) at(educ=(5(1)17) nokid=(0) nwifeinc=(60))
	marginsplot, recast(line) recastci(rarea) name(g1, replace) ///
			title("nokid=0, nwifeinc=60")
			
	*scenario 2
	margins, dydx(nwifeinc) at(educ=(5(1)17) nokid=(1) nwifeinc=(10))
	marginsplot, recast(line) recastci(rarea) name(g2, replace) ///
			title("nokid=1, nwifeinc=10")
			
	graph combine g0 g1 g2, ycommon col(3)
