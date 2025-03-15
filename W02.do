*hyun woo kim, chungbuk national university, 2025




*regression diagnostics, omitted variable bias, and path model

	use "http://fmwww.bc.edu/ec-p/data/wooldridge/wage1.dta", clear
	
	*short regression (must be nested in long regression)
	reg lwage female
	ereturn list
	matrix coef_short=e(b)
	matrix list coef_short
	reg
	di "b of female (short)=" coef_short[1,1]

	*long regression
	reg lwage female tenure
	matrix coef_long=e(b)
	di "b of female (long)=" coef_long[1,1]
	
	*size of ovb: short b - long b (see how it is defined)
	di "b of female (short)-b of female (long)=" coef_short[1,1]-coef_long[1,1]

	*regress tenure on female (called auxiliary regression)
	reg tenure female
	mat coef_aux=e(b)
	
	*size of ovb in path model: see Handout5_student.pdf for proof
	scalar def ovb=coef_aux[1,1]*coef_long[1,2]
	di ovb     //indirect effect after all
	
	*total effect of being female
	di coef_long[1,1]+ovb
	di "b of female (short)=" coef_short[1,1]


	
	
	
	
*interaction terms

	*National Longitudinal Survey of Young Women, 14-24 years old in 1968
	webuse nlswork, clear
	ta year
	keep if year==88
	keep ln_wage union grade south collgrad
	keep if !missing(ln_wage, union, grade, south, collgrad)
	
	*visual
	graph twoway (scatter ln_wage grade if union==1) ///
	             (scatter ln_wage grade if union==0)
	*ols 1
	est clear
	eststo: reg ln_wage i.union c.grade
	eststo: reg ln_wage i.union##c.grade
	esttab, nogap wide r2
	
	*margins 1
	margins, at(grade=(0(1)18)) by(union)
	marginsplot

	*ols 2
	reg ln_wage i.union##i.south
	
	*margins 2
	margins, by(union south)
	marginsplot   //think why not preferred
	marginsplot, xdim(union south) recast(bar)
	
	
	

*threshold effect

	*1 if college graduated
	ta grade
	ta grade collgrad
	
	*model comparison
	est clear
	eststo: reg ln_wage grade
	eststo: reg ln_wage collgrad
	eststo: reg ln_wage i.grade
	esttab, r2 label wide

	*post-estimation
	ta grade       //compare 12.grade with 13.grade
	reg ln_wage i.grade
	test 12.grade=13.grade
	
	*visualize the coefficients
	*ssc install coefplot, replace
	reg
	coefplot
	coefplot, keep(*.grade) noci vertical xlabel(, labsize(tiny) angle(vertical))
	

	


		
	
	
*variable transformation

	/*Cost Data for U.S. Airlines, 90 Oservations On 6 Firms For 15 Years, 1970-1984

	These data are a subset of a larger data set provided to the author by Professor Moshe Kim.
	They were originally constructed by Christensen Associates of Madison, Wisconsin.
	
	See Greene 6th. p. 109.
	*/

	insheet using "http://www.stern.nyu.edu/~wgreene/Text/Edition7/TableF6-1.csv", clear

	*variable labels
	label var i "Airline"
	label var t "Year"
	label var q "Output, in revenue passenger miles, index number"
	label var c "Total cost, in $1000"
	label var pf "Fuel price"
	label var lf "Load factor, the average capacity utilization of the fleet"

	*log transformation
	gen lnc=ln(c)
	gen lnq=ln(q)
	gen lnq2=lnq^2
	gen lnpf=ln(pf)   //fuel

	*table 6.2 (Greene, 109)
	reg lnc lnq lnq2 lnpf lf i.i b15.t    //full
	
	*residual sum of squares
	di e(rss)                             //.1725

	*post-estimation tests if dummies are necessary
		
		*time effects only
		test 1.i=2.i=3.i=4.i=5.i=6.i=0
		testparm i.i

		*firm effects only
		test 1.t=2.t=3.t=4.t=5.t=6.t=7.t=8.t=9.t=10.t=11.t=12.t=13.t=14.t=15.t=0
		testparm i.t

		*no effects
		test 1.i=2.i=3.i=4.i=5.i=6.i=1.t=2.t=3.t=4.t=5.t=6.t=7.t=8.t=9.t=10.t=11.t=12.t=13.t=14.t=15.t=0
		testparm i.i i.t
		
	*visualize the coefficients
	*ssc install coefplot, replace
	reg
	coefplot
	coefplot, keep(*.t) noci vertical
	coefplot, keep(*.i)
