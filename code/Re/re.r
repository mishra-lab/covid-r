# estimate R based on count data
library('EpiEstim')
library('questionr')
# the main config options that get passed around
get.config = function(
  t.tau       = 3,           # Re sliding window (days); larger = more smooth but more delay
  t.censor    = 3,           # assumed reporting delay (days); remove last X days
  t.start     = as.date('2020-02-25'), # first R at t.start + t.tau + 1; first case at t.start
  t.end       = as.date('2020-09-29'), # last R at t.end - t.sensor; last case at t.end - t.censor
  gen.time    = NULL,        # generation time parameterization (default is master)
  region      = 'GTA',       # 'GTA'
  data.source = 'iphis',     # 'iphis' only for now
  case.date   = 'episode',   # 'episode', 'report'
  case.def    = 'report',    # what is a case: 'report', 'death'
  case.travel = 'imported',  # how to treat travel cases: 'local', 'imported', 'exclude'
  case.ltcr   = 'local',     # how to treat LTCR cases:   'local', 'imported', 'exclude'
  case.ltcw   = 'local',     # how to treat LTCW cases:   'local', 'imported', 'exclude'
  case.main   = 'local',     # hot to treat other cases:  'local', 'imported', 'exclude'
  case.adj    = FALSE,       # infer cases by deaths based on IFR: FALSE, 'overall', 'age'
  import.local.frac = 0,     # attribute a proportion of imported cases to actually local origin
  local.import.frac = 0,     # attribute a proportion of local cases to actually imported
  case.smooth = 1,           # SD of smoothing kernel for incidence (days)
  case.sample = FALSE        # number of repeated Re(t) estimations if randomly sampling anything
){
  config = as.list(environment())
  if (is.null(gen.time)){ config$gen.time = list(param='gen-time',which='master') }
  return(config)
}
# the config options that estimate_R actually uses
get.re.config = function(config){
  nt = length(get.dates(config))
  G  = do.call(covid.19.distr,config$gen.time)
  R0 = covid.19.distr('R0')
  return(list(
    mean_prior = E(R0),
    std_prior  = sd(R0)*1.96,
    t_start = seq(2, nt-config$t.tau),
    t_end   = seq(2+config$t.tau, nt),
    mean_si = E(G),
    std_si  = sd(G)
  ))
}
# gene
get.dates = function(config){
  return(seq(config$t.start, config$t.end-config$t.censor, 1))
}
estimate.R = function(config,...){
  if (missing(config)){ config = get.config(...) }
  # TODO: ... only works if config is not given
  dates = get.dates(config)
  R.objs = list()
  for (s in 1:max(1,config$case.sample)){
    attach(env[[config$data.source]])
    incid = get.incid(config,dates)
    R.objs[[s]] = suppressWarnings({estimate_R(
      incid  = incid,
      method = 'parametric_si',
      config = make_config(get.re.config(config))
    )})
    detach(env[[config$data.source]])
  }
  return(merge.R(R.objs))
}
merge.R = function(R.objs){
  # recover gamma params and combine using Welch-Satterthwaite
  N.R    = length(R.objs)
  shapes = sapply(R.objs, function(R){ R$R[['Mean(R)']]^2 / R$R[['Std(R)']]^2 })
  scales = sapply(R.objs, function(R){ R$R[['Std(R)']]^2 / R$R[['Mean(R)']] })
  shape  = rowSums(shapes * scales)^2 / rowSums(shapes * scales^2) / N.R
  scale  = rowSums(shapes * scales) / shape / N.R
  # hijack the first object
  R = R.objs[[1]]
  R$R[['Mean(R)']]           = scale * shape
  R$R[['Std(R)']]            = scale * shape^2
  R$R[['Quantile.0.025(R)']] = qgamma(.025, shape=shape, scale=scale)
  R$R[['Quantile.0.05(R)']]  = qgamma(.050, shape=shape, scale=scale)
  R$R[['Quantile.0.25(R)']]  = qgamma(.250, shape=shape, scale=scale)
  R$R[['Median(R)']]         = qgamma(.500, shape=shape, scale=scale)
  R$R[['Quantile.0.75(R)']]  = qgamma(.750, shape=shape, scale=scale)
  R$R[['Quantile.0.95(R)']]  = qgamma(.950, shape=shape, scale=scale)
  R$R[['Quantile.0.975(R)']] = qgamma(.975, shape=shape, scale=scale)
  # WARNING: this probably does not actually represent uncertainty accurately
  #          since we re-estimate a different gamma distribution
  #          but the true uncertainty distribution likely has fatter tails.
  return(R)
}
get.R.value = function(R.obj,date,col='Mean(R)'){
  row = R.obj$R$t_end==which(R.obj$dates==date)
  return(R.obj$R[row,col])
}