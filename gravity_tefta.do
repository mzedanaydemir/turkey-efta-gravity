* Turkey-EFTA Free Trade Agreement: structural gravity estimation (PPML with high-dimensional fixed effects)
clear all
set more off

* Read in data set
use "data/BYZ_EL.dta", clear

* lets look at the data
summarize
describe
cap distinct exporter importer year
describe rta

* WTO RTA portal
* https://rtais.wto.org/UI/PublicMaintainRTAHome.aspx

* Turkey–EFTA FTA (1992→) — EFTA: CHE, NOR, ISL, LIE
* Dummy variable for Turkey–EFTA: turefta
* No prior agreement should be double-counted.

* Construct turefta
gen byte tur_exp  = (exporter=="TUR")
gen byte tur_imp  = (importer=="TUR")
gen byte efta_exp = inlist(exporter,"CHE","NOR","ISL","LIE")
gen byte efta_imp = inlist(importer,"CHE","NOR","ISL","LIE")
gen byte turefta  = ((tur_exp & efta_imp) | (tur_imp & efta_exp)) & year>=1992

ppmlhdfe trade rta turefta INTL_BRDR_*, absorb(exp_time imp_time country_pair) cluster(country_pair)

* Direct interpretation (combined with average RTA):
di (exp(_b[rta]+_b[turefta])-1)*100

* Put RTA dummy to zero if turefta==1 -> easier interpretation
replace rta = 0 if turefta == 1

ppmlhdfe trade rta turefta INTL_BRDR_*, absorb(exp_time imp_time country_pair) cluster(country_pair)
est store model1

di (exp(_b[rta])-1)*100
di (exp(_b[turefta])-1)*100
* The Turkey–EFTA Agreement increased bilateral trade between Turkey and EFTA by the percentage above (ceteris paribus).

* Re-estimate with Weidner & Zylkin bias correction (if available)
quietly ppmlhdfe trade rta turefta INTL_BRDR_*, absorb(exp_time imp_time country_pair) cluster(country_pair) d
cap predict lambda
cap matrix beta = e(b)
cap ppml_fe_bias trade rta turefta INTL_BRDR_*, i(exp_id) j(imp_id) t(year) lambda(lambda) beta(beta)
cap est store model2

* Export results table
cap esttab model1 model2 using "Resulttable_TEFTA.rtf", replace title(Regression Results — Turkey–EFTA) se stats(N)
if _rc esttab model1 using "Resulttable_TEFTA.rtf", replace title(Regression Results — Turkey–EFTA) se stats(N)

* Sectoral Analysis
clear all
cap use "data/BYZ_EL_sectoral.dta", clear
if _rc==0 {
    replace rta = 0 if turefta==1 // (in case turefta exists already)
    cap drop turefta tur_exp tur_imp efta_exp efta_imp
    gen byte tur_exp  = (exporter=="TUR")
    gen byte tur_imp  = (importer=="TUR")
    gen byte efta_exp = inlist(exporter,"CHE","NOR","ISL","LIE")
    gen byte efta_imp = inlist(importer,"CHE","NOR","ISL","LIE")
    gen byte turefta  = ((tur_exp & efta_imp) | (tur_imp & efta_exp)) & year>=1992

    replace rta = 0 if turefta == 1
    * drop lambda* if re-running
    cap drop lambda*

    foreach sector in 31 32 33 34 35 36 37 38 {
        ppmlhdfe trade rta turefta INTL_BRDR_* if code == `sector', absorb(exp_time imp_time country_pair) cluster(country_pair)
        est store results_`sector'

        quietly ppmlhdfe trade rta turefta INTL_BRDR_* if code == `sector', absorb(exp_time imp_time country_pair) cluster(country_pair) d
        cap predict lambda_`sector'
        cap matrix beta_`sector' = e(b)
        cap ppml_fe_bias trade rta turefta INTL_BRDR_* if code == `sector', i(exp_id) j(imp_id) t(year) lambda(lambda_`sector') beta(beta_`sector')
        cap est store results_corrected_`sector'
    }

    esttab results_31 results_32 results_33 results_34 results_35 results_36 results_37 results_38 ///
        using "Sector_Results_TEFTA.rtf", replace title(Regression Results by Sector — Turkey–EFTA) ///
        mtitles("Food" "Textile" "Wood" "Paper" "Chemicals" "Minerals" "Metals" "Machinery") se stats(N)

    cap esttab results_corrected_31 results_corrected_32 results_corrected_33 results_corrected_34 ///
               results_corrected_35 results_corrected_36 results_corrected_37 results_corrected_38 ///
        using "Sector_Results_TEFTA_corrected.rtf", replace ///
        title(Regression Results by Sector (Bias-corrected) — Turkey–EFTA) ///
        mtitles("Food" "Textile" "Wood" "Paper" "Chemicals" "Minerals" "Metals" "Machinery") se stats(N)
}
