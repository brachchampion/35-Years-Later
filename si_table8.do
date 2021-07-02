	global indexes		overallhealth metabolicbp genhealth respiratory
	
	global wtbk35_org	$wtbk35 
	global wtbk6_org	$wtbk6
	global wtbk35_none 	
	global wtbk6_none 	
	
	foreach grp of global agegroups {
		* Clear out macros, estimates and matrices
		est clear
		global baseline
		global estimates
		cap mat drop C
		cap mat drop S
		* Get estimates
		foreach model in org none {
			foreach index of global indexes {
			    if "`index'"=="metabolicbp" global wt ${wtbk35_`model'}
				else 						global wt ${wtbk6_`model'}
				* Run regressions
				qui reg `index' $treat $baseline_ctrls 			i.$birthyr ${wt} if $group==`grp', cluster($cluster)
					est sto `index'
					global estimates $estimates `index'
				}
			* Format estimates
			qui esttab $estimates, ci l keep(ch_treat*)
			* Append row
			mat C = [ nullmat(C) \ r(coefs) ]
			* Sample size
			mat S = [ nullmat(S) \ r(stats) ]
			* Start over
			global estimates
			est clear
			}
			* Model names
			mat rownames C = org none
			mat rownames S = org none
			* Store for looping
			loc rnames : rownames C
			loc models : coleq C
			loc models : list uniq models
			* Loop over each control
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
				qui estadd sca N = S[`i',1]
				eststo `name'
				}
		esttab using "si_table8_`grp'.csv" ///
				, ci(%4.2f) b(%4.2f) s(N) l r noobs compress ///
				mtitle("Attrition" "Unweighted") br plain star(+ 0.10 * 0.05 ** 0.01) 
		}