	* Bar graph
	* Make a macro for each bar command
	forval i = 1/5 {
		global bar`i' bar bmi position if position==`i'
		}
	* Make dummies for treatment status to get means/CIs
	cap drop temptreat?
	qui tab $treat, gen(temptreat)
		* Prepare matrix
		cap mat drop bmi
		mat bmi = J(5,4,.)
		mat colnames bmi = bmi position ll ul
		mat rownames bmi = m1T m1C gap m2T m2C 
		* Fill in matrix
		qui reg m1_bmicl temptreat2 temptreat1 if $group==61, nocons
			mat table = r(table)
			* M1: T
			mat bmi[1,1] = table[1,1]	// b
			mat bmi[1,3] = table[5,1]	// ll
			mat bmi[1,4] = table[6,1]	// ul
			* M1: C
			mat bmi[2,1] = table[1,2]
			mat bmi[2,3] = table[5,2]
			mat bmi[2,4] = table[6,2]
		qui reg m2_bmicl temptreat2 temptreat1 if $group==61, nocons
			mat table = r(table)
			* M2: T
			mat bmi[4,1] = table[1,1]
			mat bmi[4,3] = table[5,1]
			mat bmi[4,4] = table[6,1]
			* M2: C
			mat bmi[5,1] = table[1,2]
			mat bmi[5,3] = table[5,2]
			mat bmi[5,4] = table[6,2]
		preserve
			clear
			svmat bmi,names(col)
			replace position = _n
			
			twoway	($bar1, fc(navy) lc(navy) lw(medium))					///
					($bar4, fc(maroon) lc(maroon) lw(medium))				///
					($bar3,) 												///
					($bar2, fc(navy) lc(navy) lw(medium) fi(inten30))		///
					($bar5, fc(maroon) lc(maroon) lw(medium) fi(inten30))	///
					(rcap ul ll position, col(black))						///
					, xlab(1.5 "MHSS1" 4.5 "MHSS2", notick)					///
					ylab(17(1)23,gmax nogrid)								///
					graphr(lc(white) fc(white)) plotr(lc(white) fc(white)) 	///
					legend(order(	1 "M1: Treatment" 						///
									2 "M2: Treatment" 						///
									4 "M1: Comparison" 						///
									5 "M2: Comparison")						///
						   reg(lc(white)) colgap(*1.1) symy(4.1) symx(5))	///
					xtitle(" ") ytitle("BMI",m(medium))						///
					title("Means", place(w) col(black) span)				///
					name("figure2_bars",replace)
		restore
	drop temptreat?
	* Densities
	twoway	(kdensity m1_bmicl if $treat==1  & $group==61, lpat(solid) lcol(navy))			///	M1 T
			(kdensity m2_bmicl if $treat==1  & $group==61, lpat(solid) lcol(maroon))		/// M2 T
			(kdensity m1_bmicl if $treat==0  & $group==61, lpat(shortdash) lcol(navy))		/// M1 C
			(kdensity m2_bmicl if $treat==0  & $group==61, lpat(shortdash) lcol(maroon))	/// M2 C
			,title("Distributions",place(w) col(black) span) 			///
			xtitle("BMI") ytitle("") 									///
			xlab(10 18.5 23 30 40) ylab(0(.05).25,gmax nogrid)			///
			xline(18.5 23, lcol(gray))									///
			graphr(lc(white) fc(white)) plotr(lc(white) fc(white)) 		///
			text(.25 14 "{&larr} Underweight" .25 27 "Overweight {&rarr}", size(small)) ///
			legend(order(	1 "M1: Treatment"  2 "M2: Treatment" 		///
							3 "M1: Comparison" 4 "M2: Comparison") 		///
			reg(lc(white)) colgap(*1.1) symx(*.5))						///
			name("figure2_densities",replace)
	* Combine
	gr combine	figure2_bars figure2_densities					///
		, rows(1) graphr(lc(white) fc(white)) plotr(lc(white) fc(white))
	graph export "figure2.pdf", replace