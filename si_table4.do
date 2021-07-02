	global regprog		outBrach
	global mechanisms	m1_conspc_food_total m2_conspc_food m1_lnconspc_food_total m2_lnconspc_food 
	* With baseline controls
	global filename "si_table4_panelA_cohorts"
		cap erase "${filename}.xml"
		cap erase "${filename}.txt"
	foreach mechanism of global mechanisms {
		if strpos("`mechanism'","m1")>0 loc wt wt96
		else 							loc wt wtbk35
		qui reg `mechanism' $treatSD $baseline_ctrls $baseline_ctrls_int 	i.$birthyr ${`wt'}, cluster($cluster)
			qui $regprog `mechanism' "${filename}"
		}
		cap erase "${filename}.txt"
	global filename "si_table4_panelA_combined"
		cap erase "${filename}.xml"
		cap erase "${filename}.txt"
	foreach mechanism of global mechanisms {
		if strpos("`mechanism'","m1")>0 loc wt wt96
		else 							loc wt wtbk35
		qui reg `mechanism' $treat $baseline_ctrls 							i.$birthyr ${`wt'}, cluster($cluster)
			qui $regprog `mechanism' "${filename}"
		}
		cap erase "${filename}.txt"
	* Without baseline controls
	global filename "si_table4_panelB_cohorts"
		cap erase "${filename}.xml"
		cap erase "${filename}.txt"
	foreach mechanism of global mechanisms {
		if strpos("`mechanism'","m1")>0 loc wt wt96
		else 							loc wt wtbk35
		qui reg `mechanism' $treatSD					 					i.$birthyr ${`wt'}, cluster($cluster)
			qui $regprog `mechanism' "${filename}" 
		}
		cap erase "${filename}.txt"
	global filename "si_table4_panelB_combined"
		cap erase "${filename}.xml"
		cap erase "${filename}.txt"
	foreach mechanism of global mechanisms {
		if strpos("`mechanism'","m1")>0 loc wt wt96
		else 							loc wt wtbk35
		qui reg `mechanism' $treat					 						i.$birthyr ${`wt'}, cluster($cluster)
			qui $regprog `mechanism' "${filename}" 
		}
		cap erase "${filename}.txt"