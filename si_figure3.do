	global indexes				metabolicbp genhealth respiratory
	
	global metabolicbp_comps	angina_z stroke_z overwgtpl_z hyperstage1_z hyperstage2_z
	global genhealth_comps		activities_diff_z hstat_poor_z adl_mob_z max_dom_z opc_score_poor_z
	global respiratory_comps	cld_z asthma_z
	
	global metabolicbpaseq		"Metabolic"
	global genhealthaseq		"Functional Health"
	global respiratoryaseq		"Respiratory"

	global rnames_metabolicbp	`""Metabolic Domain" "Angina" "Stroke" "Overweight or Obese" "Stage 1 Hypertension" "Stage 2 Hypertension""'
	global rnames_genhealth		`""Functional Domain" "Difficulties w/ Activities" "Poor Health Status" "ADL Mobility" "Max Dom Grip Strength" "Poor OPC Score""'
	global rnames_respiratory	`""Respiratory Domain" "Chronic Lung Disease" "Asthma""'
		
	foreach grp of global agegroups {
		* Set macro
		global coefs`grp'
		* Loop through indexes for each sex
		foreach index of global indexes {
			* Choose correct weight
			if "`index'" == "metabolicbp" loc wt wtbk35
			else loc wt wtbk6
			* Set matrix size based on number of variables
			loc N : word count `index' ${`index'_comps}
			mat `index'`grp' = J(`N',5,.)
			* Run regression for index
			qui reg `index' $treat $baseline_ctrls i.$birthyr ${`wt'} if ${group}==`grp', cluster($cluster)	
				* Fill in first row (index coefficient and CI)
				mat table = r(table)
				mat `index'`grp'[1,1] = table[1,1]
				mat `index'`grp'[1,2] = table[5,1]
				mat `index'`grp'[1,3] = table[6,1]
				mat `index'`grp'[1,5] = table[4,1]
				* Control group mean
				qui sum `index' if e(sample) & $treat==0, meanonly
				mat `index'`grp'[1,4] = r(mean)
			* Set counter
			loc i = 2
			* Run regression for each component of the index
			foreach comp of global `index'_comps {
				qui reg `comp' $treat $baseline_ctrls i.$birthyr ${`wt'} if ${group}==`grp', cluster($cluster)
				* Fill in subsequent rows
				mat table = r(table)
				mat `index'`grp'[`i',1] = table[1,1]
				mat `index'`grp'[`i',2] = table[5,1]
				mat `index'`grp'[`i',3] = table[6,1]
				mat `index'`grp'[`i',5] = table[4,1]
				* Control group mean
				qui sum `comp' if e(sample) & $treat==0, meanonly
				mat `index'`grp'[`i',4] = r(mean)
				* Increment counter
				loc ++i
				}
			* Name columns and rows
			mat colnames `index'`grp' = b ll ul cm pval
			mat rownames `index'`grp' = ${rnames_`index'}
			* Fill in macro
			global coefs`grp' ${coefs`grp'} (matrix(`index'`grp'[.,1]), ci((`index'`grp'[.,2] `index'`grp'[.,3])) aux(`index'`grp'[.,4] `index'`grp'[.,5])) 
			}
		}
	coefplot 	$coefs49, bylabel("1938-1949") || $coefs61, bylabel("1950-1961") || $coefs73, bylabel("1962-1973") ||	///
				, mlabel(${b_par_cm}) msize(vsmall) mlabp(1) mlabs(vsmall) nooffset		///
				xline(0,lp(dot) lc(black)) xlab(,labs(small)) ylab(,nogrid)				///
				head(	"Metabolic Domain" 			= "{bf:Metabolic}" 					///
						"Functional Domain" 		= "{bf:Functional}" 				///
						"Respiratory Domain" 		= "{bf:Respiratory}")				///
				p1(m(d)) p2(m(s)) p3(m(t)) byopts(legend(off) rows(1) 					///
				graphr(lc(white) fc(white)) plotr(lc(white) fc(white)))					///
				subtitle(,bcol(white)) grid(glcolor(gs14))										
	graph export "si_figure3.pdf", replace