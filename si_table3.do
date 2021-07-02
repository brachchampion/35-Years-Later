	global baseline			// empty for original model
	global childrenborn		kids2 kids3 kids4 kids5 kids6
	global spacing			m2_ageatlastchild m2_ageatfirstchild m2_avgbirthint
	global m1bmi			m1_bmicl
	global m2bmi			m2_bmicl
	global metabolicbp		metabolicbp
	global controls			childrenborn spacing m1bmi m2bmi metabolicbp	

	* Clear out macros, estimates and matrices
	est clear
	global baseline
	global estimates
	cap mat drop C
	cap mat drop S
	* Get estimates
	foreach ctrl in baseline $controls {
		foreach index of global indexes {
			if "`index'" == "metabolicbp" loc wt wtbk35
			else loc wt wtbk6
			qui reg `index' $treat $baseline_ctrls ${`ctrl'} i.$birthyr ${`wt'} if $group==61, cluster($cluster)
				est sto `index'
				global estimates $estimates `index'
			}
		* Format estimates
		qui esttab $estimates, ci l keep($treat)
		* Append row
		mat C = [ nullmat(C) \ r(coefs) ]
		* Sample size
		mat S = [ nullmat(S) \ r(stats) ]
		* Start over
		global estimates
		est clear
		}
		* Model names
		mat rownames C = baseline $controls
		mat rownames S = baseline $controls
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
	esttab using "si_table3.csv" ///
			, ci(%4.2f) b(%4.2f) s(N) l r noobs compress ///
			br plain star(+ 0.10 * 0.05 ** 0.01)  ///
			mtitle("Baseline" "Kids Ever Born" "Spacing" "MHSS1 BMI" "MHSS2 BMI" "Metabolic") 