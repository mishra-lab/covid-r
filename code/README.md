# Estimating Re(t) of COVID-19 in Ontario / GTA

- Authors: Jesse Knight
- Last Update: 2020-06-24

## Code Overview
- `./` - config code
- `./deconv/` - code for the deconvolution paper only
- `./Re/` - code to generate incidence time series & estimate Re(t)

## Usage
1. Download the file `IPHIS_REPORT.csv` into `data/private/`
2. Run `make iphis-min` to produce the file `IPHIS_REPORT_MIN.csv`
   which is a subset of columns from the original for faster loading.
   Remember to re-run it after updating `IPHIS_REPORT.csv`.
3. Run `make Re-main` to plot some comparisons of Re(t)
   based on options in the `config` object (details below).
4. To get values of Re(t) by date, use `get.R.value` function,
   which assumes the "t" is the last day in the sliding window (details below).

## Implementation

1. `estimate.R` function will load the incidence data and compute Re(t)
   using `estimate_R` from the EpiEstim package, returning an "`R.obj`" (class `estimate_R`)
   There is an option to run multiple estimations and combine the results
   to better reflect uncertainty, but it may need a review of the merging approach.
2. `get.config` function has default options that can be overridden
   by passing any named argument. This controls all configuration of the Re(t) estimation.
   `estimate.R` can also pass arguments to `get.config` for convenience.
3. `get.incid` is called by `estimate.R` to generate
   an incidence time series as a data.frame with 3 columns:
   - `dates`: list of dates
   - `local`: cases assumed to be generated locally, and go on to generate more local cases
   - `imported` cases assumed to be generated elsewhere, but go on to generate local cases
   The values of `case.{travel,ltc,main}` define how these cases are treated.
   Cases may also filtered using `get.case.select` e.g. for sub-regions,
   or weighted using `get.case.weights` e.g. for inferring cases based on deaths.
   Note: IFR weights are broken right now, please do not use this method.
4. `load.case.data` is called by `get.incid` and is expected to return
   a data.frame with the required columns.
   Theoretically multiple data sources could each define a function `load.case.data`,
   which would be selected using "environments" based on the file name (e.g. `iphis`),
   thus allowing comparison of data from multiple sources in the same figure.
   The environment is "attached" (limited scope) in `estimate.R` after definition in `source.env`.
5. `plot.R` accepts one or a list of `R.obj` so they can be plotted and compared.
   The names will be used as the legend labels.
   Similarly `plot.cases` can plot the incidence time series for one or more `R.obj`.

### Notes & Gotchas
- We use the EpiEstim package by Cori et al 2013 to do the work:
  [[link]](https://doi.org/10.1093/aje/kwt133)
- Most "distributions" are defined in JSON files at `data/public/distr`.
  The parameters are loaded using the `distr.json` function,
  while distribution "objects" (distrEx package) can be defined
  using the `covid.19.distr` function, e.g. for sampling, getting quantiles, etc.
  Sometimes you can choose one of several parameterizations by name or a default is assumed.
- By default, `save.fig` won't actually save unless the pseudo-global parameter
  `config.save` is `TRUE`; this was done to avoid accidentally overwriting output.
- You can ignore the (or suppress) warnings about colour from the `plot` functions.
- Please use the default `config` options for: `case.adj` and `case.sample`
  as the implementation of these features needs review.
- Neighbourhood stratification should probably be treated like (but separate from) `regions`.
- Impact of outbreaks could probably be treated like `travel` / `ltc`