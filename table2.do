** Regression table
*** BMI

	global sexes		Women
	global mechanisms	m1_bmicl m1_underwgt m1_overwgtpl m1_obese ///
						m2_bmicl m2_underwgt overwgtpl 	  m2_obese

	
	cap drop temptreat?
	qui tab $treat, gen(temptreat)
	foreach grp of global agegroups {
		est clear
		** Means of C/T and N
		* Get estimates
		global estimates
		foreach mechanism of global mechanisms {
			qui reg `mechanism' temptreat? $wtbk35 if $group==`grp', nocons
				est sto `mechanism'
			global estimates $estimates `mechanism'
			}
		* Format estimates
		qui esttab $estimates, ci label

			* Save into matrix
			mat C = r(coefs)
			mat S = r(stats)

			mat rownames C = meanC meanT
			
		eststo clear
		* Prepare row and column names for looping
		loc rnames : rownames C
		loc models : coleq C
		loc models : list uniq models
		* Loop through each indep/dep var and build coefficient and CI vectors
		loc i = 0
		foreach name of local rnames {
			loc ++i

				cap mat drop b
				cap mat drop ci_l
				cap mat drop ci_u
				cap mat drop p
				
			loc j = 0
			foreach model of local models {
				loc ++j
				loc c = 4*`j'-3
				mat tmp = C[`i',`c']
				if tmp[1,1]<. {
					mat colnames tmp = `model'
					mat b = nullmat(b), tmp
					}
				}
				
			ereturn post b
			eststo `name'
			}
		** Mean of difference with no controls or CI
		global estimates
		foreach mechanism of global mechanisms {
			qui reg `mechanism' $treat $wtbk35 if $group==`grp'
				est sto `mechanism'
			global estimates $estimates `mechanism'
			}
		* Format estimates
		qui esttab $estimates, ci label

			* Save into matrix
			mat C = r(coefs)
			mat S = r(stats)
			
		* Prepare row and column names for looping
		loc rnames : rownames C
		loc models : coleq C
		loc models : list uniq models
		* Loop through each indep/dep var and build coefficient and CI vectors
		loc i = 0
		foreach name in ch_treat {
			loc ++i
			
			loc j = 0
			foreach model of local models {
				loc ++j
				loc c = 4*`j'-3
				mat tmp = C[`i',`c']
				if tmp[1,1]<. {
					mat colnames tmp = `model'
					mat b 	= nullmat(b), tmp
					mat tmp[1,1] = C[`i',`c'+1]
					/*mat ci_l = nullmat(ci_l), tmp
					mat tmp[1,1] = C[`i',`c'+2]
					mat ci_u = nullmat(ci_u), tmp*/
					mat tmp[1,1] = C[`i',`c'+3]
					mat p = nullmat(p), tmp
					}
				}
				
			ereturn post b
			/*estadd mat ci_l
			estadd mat ci_u*/
			estadd mat p
			eststo `name'
			}
		** Mean of difference with controls and CI
		global estimates
		foreach mechanism of global mechanisms {
			qui reg `mechanism' $treat $baseline_ctrls $wtbk35 if $group==`grp'
				est sto `mechanism'
			global estimates $estimates `mechanism'
			}
		* Format estimates
		qui esttab $estimates, ci label

			* Save into matrix
			mat C = r(coefs)
			mat S = r(stats)
			
		* Prepare row and column names for looping
		loc rnames : rownames C
		loc models : coleq C
		loc models : list uniq models
		* Loop through each indep/dep var and build coefficient and CI vectors
		loc i = 0
		foreach name in ch_treat {
			loc ++i
				cap mat drop b
				cap mat drop ci_l
				cap mat drop ci_u
				cap mat drop p
			loc j = 0
			foreach model of local models {
				loc ++j
				loc c = 4*`j'-3
				mat tmp = C[`i',`c']
				if tmp[1,1]<. {
					mat colnames tmp = `model'
					mat b 	= nullmat(b), tmp
					mat tmp[1,1] = C[`i',`c'+1]
					mat ci_l = nullmat(ci_l), tmp
					mat tmp[1,1] = C[`i',`c'+2]
					mat ci_u = nullmat(ci_u), tmp
					mat tmp[1,1] = C[`i',`c'+3]
					mat p = nullmat(p), tmp
					}
				}
				
			ereturn post b
			qui estadd mat ci_l
			qui estadd mat ci_u
			qui estadd mat p
			eststo `name'_adj
			}
		** N
		loc snames : rownames S
		loc i = 0
		* Loop through each indep/dep var and grab sample size
		foreach name of local snames {
			loc ++i
			loc j = 0
			
				*cap mat drop b
			
			foreach model of local models {
				loc ++j
				mat tmp = S[`i',`j']
				mat colnames tmp = `model'
				mat b = nullmat(b), tmp
				}
			
			ereturn post b
			eststo `name'
			}
		
		* Output
		esttab using "table2_`grp'.csv" 																					///
			, ci label replace noobs compress star(+ 0.10 * 0.05 ** 0.01)												///
			mtitle("Mean of Comparison" "Mean of Treatment" "Difference in Means" "Adjusted Difference in Means" "N") 	///
			cell((b(star fmt(%4.2f))) (ci_l(par(lb cm) fmt(%4.2f)) & ci_u(par(dd rb) fmt(%4.2f)))) 						// find/replace lb=[ cm=, dd= rb=]
		}
	drop temptreat?