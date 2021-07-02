/*********************** Replication code for **********************************

	"Thirty-five years later: Long-term effects of the Matlab maternal and child 
	health/family planning program on older women’s well-being"

	by Tania Barham, Brachel Champion, Andrew Foster, Jena Hamadani, 
		Warren C. Jochem, Gisella Kagy, Randall Kuhn, Jane Menken, 
		Abdur Razzaque, Elisabeth Root, Patrick Turner
	
Copyright 2021, Brachel Champion, All rights reserved.
Contact: brachel.champion@colorado.edu

*******************************************************************************/

cd "~/Replication/" // change as applicable 

set scheme s2color // for figure replicability
* Import data
use "35_Years_Later_PublicData.dta",clear
	bys personid: assert _n==1
	
	* Set globals
	global treat 		ch_treat 
	global treatSD		ch_treat_bb_m2_gr73 ch_treat_bb_m2_gr61 ch_treat_bb_m2_gr49 bb_m2_group73 bb_m2_group61
	global birthyr		bb_m2_birthyr
	global group 		bb_m2_group_12
	global agegroups 	73 61 49
	global wtbk35		[pw=wt_74m2bk35_em]
	global wtbk6		[pw=wt_74m2bk6_em]
	global wt96		[pw=wt_74_96_74cen_base_ero_meg]
	global cluster		ch_vill_public
	global baseline_ctrls 	m2_m1_islamic age74_chcl hhh_ed_yrs74_chcl hhhsp_ed_yrs74_chcl hhc_bari_size74_chcl hhc_famsize74_chcl			///
						hhh_agria74_chcl hhh_fisha74_chcl hhh_busi74_chcl hhc_walltinmix74_chcl hhc_rooftin74_chcl hhc_latfix74_chcl	///
						hhc_drinktw74_chcl hhc_drinktkw74_chcl hhc_land82_chcl hhc_nroom74pc_chcl hhc_nboat74_chcl hhc_ncow74_chcl		///
						hhc_lamp74_chcl hhc_watch74_chcl hhc_radio74_chcl ars4_50 ars4_100 ars4_150 ars4_400 
	global baseline_ctrls_int	m2_m1_islamic_gr73 m2_m1_islamic_gr61 age74_chcl_gr73 age74_chcl_gr61 hhh_ed_yrs74_chcl_gr73 hhh_ed_yrs74_chcl_gr61				///
						hhhsp_ed_yrs74_chcl_gr73 hhhsp_ed_yrs74_chcl_gr61 hhc_bari_size74_chcl_gr73 hhc_bari_size74_chcl_gr61			///
						hhc_famsize74_chcl_gr73 hhc_famsize74_chcl_gr61 hhh_agria74_chcl_gr73 hhh_agria74_chcl_gr61						///
						hhh_fisha74_chcl_gr73 hhh_fisha74_chcl_gr61 hhh_busi74_chcl_gr73 hhh_busi74_chcl_gr61 hhc_walltinmix74_chcl_gr73 ///
						hhc_walltinmix74_chcl_gr61 hhc_rooftin74_chcl_gr73 hhc_rooftin74_chcl_gr61 hhc_latfix74_chcl_gr73				///
						hhc_latfix74_chcl_gr61 hhc_drinktw74_chcl_gr73 hhc_drinktw74_chcl_gr61 hhc_drinktkw74_chcl_gr73					///
						hhc_drinktkw74_chcl_gr61 hhc_land82_chcl_gr73 hhc_land82_chcl_gr61 hhc_nroom74pc_chcl_gr73						///
						hhc_nroom74pc_chcl_gr61 hhc_nboat74_chcl_gr73 hhc_nboat74_chcl_gr61 hhc_ncow74_chcl_gr73 hhc_ncow74_chcl_gr61	///
						hhc_lamp74_chcl_gr73 hhc_lamp74_chcl_gr61 hhc_watch74_chcl_gr73 hhc_watch74_chcl_gr61 hhc_radio74_chcl_gr73		///
						hhc_radio74_chcl_gr61 ars4_50_gr73 ars4_50_gr61 ars4_100_gr73 ars4_100_gr61 ars4_150_gr73 ars4_150_gr61			///
						ars4_400_gr73 ars4_400_gr61
	* Marker label for coefplot
	global	b_par_cm	string(@b, "%3.2f") /// Beta
						+ " (" + string(@aux1, "%3.2f") + ")" /// (control mean)
						+ 	cond(@aux2<.001,"***", 	/// Significance stars
							cond(@aux2<.01,"**",	///
							cond(@aux2<.05,"*",		///
							cond(@aux2<.1,"+",""))))	
	* Custom outreg program 
	capture program drop outBrach
	program define outBrach
		foreach i of global agegroups {
			sum `1' if $treat==0 & e(sample) & $group==`i', meanonly
				local meanC`i' = r(mean)
			}
		global addstat	addstat(Mean Control 1973, `meanC73',	///
								Mean Control 1961, `meanC61',	///
								Mean Control 1949, `meanC49',	///
								N,e(N))
		global options		label nocons noobs nor2 sym(**,*,+) excel append ///
							keep(ch_treat*) sortvar(ch_treat*) $addstat ci dec(2) adec(2) afmt(f)
		outreg2 using "`2'", $options
	end
	* Main tables and figures
	* Table 1
	run "table1.do"
	* Table 2
	run "table2.do"
	* Figure 1
	run "figure1.do"
	* Figure 2
	run "figure2.do"
	
	* Supplementary tables and figures
	* SI Table 1
	run "si_table1.do"
	* SI Table 2 omitted for privacy
	* SI Table 3
	run "si_table3.do"
	* SI Table 4
	run "si_table4.do"
	* SI Table 5
	run "si_table5.do"
	* SI Table 6
	run "si_table6.do"
	* SI Table 7
	run "si_table7.do"
	* SI Table 8
	run "si_table8.do"
	* SI Figure 2 omitted for privacy
	* SI Figure 3
	run "si_figure3.do"
	
cap graph close _all
