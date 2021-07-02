	global extended 	erosion_any meghna brac_any pour curr_mig_urban curr_mig_od 
	global FILENAME		"si_table6"
		cap erase "${FILENAME}.xls"
	cap drop control
	gen control = $treat == 0 if !missing($treat)

	cap postclose extended  
	postfile extended str40(outcome) float(meanT seT Ntreat meanC seC Ncontrol diffmeans difftstat diffsd_all)	///
		using "${FILENAME}", replace 
		
	foreach var of global extended { 
		qui reg `var' $treat, cluster($cluster) 

		*Get means for tx & cntrl groups 
			scalar  meanC    	= e(b)[1,2] 
			scalar  diffmean	= e(b)[1,1] 
			scalar  meanT     	= meanC + diffmean 

		*Get N for tx & cntrl groups 
			qui count if e(sample) & $treat==1 
			scalar  ntreat    	= r(N) 
			qui count if e(sample) & $treat==0 
			scalar  ncontrol  	= r(N)

		*Get total N 
			scalar 	N = e(N) 

		*Get Std. Errors for treatment, control & difference in means
			scalar  seC         = sqrt(e(V)[2,2]) 
            scalar  diffse      = sqrt(e(V)[1,1])
		qui reg `var' control, cluster($cluster)
			scalar  seT         = sqrt(e(V)[2,2]) 
			
			scalar  sdT 		= sqrt(ntreat) * seT 
			scalar  sdC		  	= sqrt(ncontrol) * seC 
			*Make t-stat for diff in means 
			scalar 	difftstat	= diffmean / diffse
			scalar 	diffsd_all	= diffmean / sqrt(sdT^2 + sdC^2) 
			
		*Make t-stat for diff in means 
			scalar 	difftstat	= diffmean / diffse
			scalar 	diffsd_all	= diffmean / sqrt(sdT^2 + sdC^2) 

		*Output the means, differences in means, std. errs, t-stat, & Ns. 
			post extended ("`: var lab `var''")  (meanT) (seT) (ntreat) (meanC) (seC) (ncontrol) (diffmean) (difftstat) (diffsd_all) 
			scalar drop _all
	  } 
	postclose  extended 
	preserve
		** Open up the posted file
		use "${FILENAME}.dta", clear 
			*Format output 
			format %9.2f meanT seT meanC seC diffmeans difftstat diffsd_all
			foreach var in seT seC {
				tostring `var',replace format(%9.2f) force
				replace `var' = "(" + `var' + ")"
				}
			order outcome meanT seT meanC seC diffmeans difftstat diffsd_all Ntreat Ncontrol
			export excel using "${FILENAME}", first(var) sheetreplace

		* Erase posted file
		erase  "${FILENAME}.dta" 
	restore