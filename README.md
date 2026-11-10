# Trade effects of the Turkey–EFTA Free Trade Agreement

Seminar paper project, M.Sc. International Economic Policy, University of Würzburg.

**Question.** Did the Turkey–EFTA agreement (in force since 1992) raise trade between Turkey and Switzerland, Norway, Iceland and Liechtenstein, and how does the effect compare with the average regional trade agreement?

## Method

- Structural gravity model estimated with Poisson pseudo-maximum likelihood (`ppmlhdfe`), which keeps zero trade flows in the sample.
- Exporter-time, importer-time and country-pair fixed effects; standard errors clustered by country pair.
- A separate dummy isolates the Turkey–EFTA pairs from the average RTA effect.
- Bias correction for the three-way fixed-effects PPML estimator (`ppml_fe_bias`, Weidner and Zylkin).
- Sector-level estimates for eight manufacturing sectors (ISIC 31–38).

## Data

The estimation uses the Baier–Yotov–Zylkin / Larch regional trade agreements panel: 69 countries, 1988–2006, aggregate and sectoral bilateral trade flows. The data are not included in this repository. Place `BYZ_EL.dta` and `BYZ_EL_sectoral.dta` in a `data/` folder before running.

## Run

Requires Stata with `ppmlhdfe`, `reghdfe`, `ftools`, `estout` and `ppml_fe_bias`.

```stata
do gravity_tefta.do
```

The script writes the aggregate and sectoral regression tables as `.rtf` files.
