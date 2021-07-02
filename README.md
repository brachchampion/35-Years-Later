# Replication code for reproducing results from "Thirty-five years later"

Included here are the master do-files for reproducing the results found in "Thirty-five years later: Long-term effects of the Matlab maternal and child health/family planning program on older women’s well-being". 

The data and full documentation are found here: https://www.openicpsr.org/openicpsr/project/143101/version/V1/view

**Data:** The sample of 1,820 women used to produce the results are provided in de-identified form in "35_Years_Later_PublicData.dta". The file is unique by *personid* and contains all variables needed for replication (including constructed variables and interaction terms). Consult the data and variable construction sections of the supplementary information for detailed notes on how variables were constructed, trimmed, etc.

**Software:** Data and replication code are provided in Stata format. Stata 13 or later is generally adequate, though some figures use formatting features exclusive to Stata 15 and onward.

**Instructions:** 
1. Place "35_Years_Later_PublicData.dta" and all related do-files labeled "[si_]table/figureX.do" in the working directory.
2. Replace working directory file path in "35_Years_Later.do".
3. Run the master file "35_Years_Later.do".
4. Some post-analysis formatting is required to transform the output into the final print tables.

*Note: some results may differ slightly due to top-coding of variables for privacy concerns.*

**Use and sharing:** All code was written by me (Brachel Champion) and provided for the purpose of replication. For permissions other than replilcation, please email me at brachel.champion@colorado.edu.
