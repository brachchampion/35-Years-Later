	global	indexes				overallhealth metabolicbp genhealth respiratory
	global 	baseline_ctrl_set 	$baseline_ctrls $baseline_ctrls_int

	global 	overallname	"All"
	global 	cohortname	"Cohorts"
	
	global	cnames	b ll ul cm pval
	global	rnames	`""1962-1973" "1950-1961" "1938-1949""'
	
	global 	ctrls_adjusted			$baseline_ctrls	
	global 	ctrls_unadjusted
	global 	ctrls_adjusted_int		$baseline_ctrls $baseline_ctrls_int
	global 	ctrls_unadjusted_int 
	
	foreach model in adjusted unadjusted {
		global coefs_`model'
		foreach index of global indexes {
			* Choose weight
			if "`index'" == "metabolicbp" loc wt wtbk35
			else loc wt wtbk6
			* Set matrix
			mat `index'`model' = J(3,5,.)
			* Cohort treatment effects
			qui reg `index' $treatSD ${ctrls_`model'_int} i.$birthyr ${`wt'}, cluster($cluster)
				mat table = r(table)
				loc i = 0
				foreach grp of global agegroups {
					loc ++i
					* beta, CI and p-val
					mat `index'`model'[`i',1] = table[1,`i']
					mat `index'`model'[`i',2] = table[5,`i']
					mat `index'`model'[`i',3] = table[6,`i']
					mat `index'`model'[`i',5] = table[4,`i']
					* Control mean by group
					qui sum `index' if e(sample) & $treat==0 & $group==`grp', meanonly
					mat `index'`model'[`i',4] = r(mean)
					}
					
				mat colnames `index'`model' = $cnames
				mat rownames `index'`model' = $rnames
				
			* Average treatment effects
			mat `index'`model'avg = J(1,5,.) 
			qui reg `index' ch_treat ${ctrls_`model'} i.$birthyr ${`wt'}, cluster($cluster)
				mat table = r(table)
				mat `index'`model'avg[1,1] = table[1,1]
				mat `index'`model'avg[1,2] = table[5,1]
				mat `index'`model'avg[1,3] = table[6,1]
				mat `index'`model'avg[1,5] = table[4,1]
				qui sum `index' if e(sample) & $treat==0, meanonly
				mat `index'`model'avg[1,4] = r(mean)
				
				mat colnames `index'`model'avg = $cnames
				mat rownames `index'`model'avg = "1938-1973"
				
			* Fill in macro
			global coefs_`model' ${coefs_`model'}										///
								(														///
								matrix(`index'`model'avg[.,1]), 						///
								ci((`index'`model'avg[.,2] 	`index'`model'avg[.,3])) 	///
								aux(`index'`model'avg[.,4] 	`index'`model'avg[.,5]) 	///
								asequation(${overallname}) 								///
								\ 														///
								matrix(`index'`model'[.,1]), 							///
								ci((`index'`model'[.,2] 	`index'`model'[.,3])) 		///
								aux(`index'`model'[.,4] 	`index'`model'[.,5]) 		///
								asequation(${cohortname}) 								///
								)
			}
		}
	
	** Plot colors
	global pc_black		mc(black) 			ciop(lc(black))			mlabc(black)		m(o)
	global pc_navy		mc(navy)  			ciop(lc(navy))  		mlabc(navy)			m(d)
	global pc_maroon	mc(maroon) 			ciop(lc(maroon)) 		mlabc(maroon)		m(s)
	global pc_forestg	mc(forest_green) 	ciop(lc(forest_green)) 	mlabc(forest_green)	m(t)
	
	coefplot $coefs_adjusted, bylabel("Adjusted") || $coefs_unadjusted, bylabel("Unadjusted") ||	///
		, mlabel(${b_par_cm}) msize(small) mlabp(4) mlabs(vsmall) format(%3.2f) ///
		xline(0, lcolor(black) lpat(shortdash)) xlab(-.3(.1).35,labs(vsmall)) 	///
		 grid(glcolor(gs14))													///
		p1(label("Overall Health") 	$pc_black) 									///
		p2(label("Metabolic") 		$pc_navy) 									///
		p3(label("Functional") 		$pc_maroon) 								///
		p4(label("Respiratory") 	$pc_forestg) 								///
		subtitle(,bcol(white))	legend(rows(1) region(lc(none) fc(none)))		///
		byopts( 	title("Birth Year",place(w) span col(black))				///
			graphr(lc(white) fc(white)) plotr(lc(white) fc(white))				///
			)
	graph export "figure1.pdf", replace