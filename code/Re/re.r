# estimate R based on count data
library('EpiEstim')
library('questionr')
get.config = function(
  t.tau            = round(q(covid.19.distr('gen-time'))(0.9)),
  t.start          = as.date('2020-02-25'),
  t.end            = as.date('2020-05-01'),
  t.censor         = NULL,          # censor
  gen.time         = NULL,          # generation time source
  data.name        = 'moh',         # 'moh','olis','iphis'
  region           = 'GTA',         # 'GTA'
  data.source      = 'iphis',       # 'iphis','olis'
  case.date        = 'episode',     # 'episode', 'report'
  case.def         = 'report',      # 'death', 'report'
  case.travel      = 'local',       # 'local', 'imported', 'exclude'
  case.main        = 'local',       # 'local', 'imported', 'exclude'
  case.ltc         = 'local',       # 'local', 'imported', 'exclude'
  case.adj         = 'overall',     # FALSE, 'overall', 'age'
  import.frac      = 1,             # fraction of import with local contact
  unkn.import.frac = 0,             # fraction of local with unknown import contact
  case.smooth      = 1,             # sd of gaussian smoothing kernel
  case.sample      = FALSE          # number of sample iterations
){
  config = as.list(environment())
  if (is.null(gen.time)){ config$gen.time = list(param='gen-time',which='master') }
  if (is.null(t.censor)) { config$t.censor = censor.map[[config$case.def]] } 
  return(config)
}
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
get.dates = function(config){
  return(seq(config$t.start, config$t.end-config$t.censor, 1))
}
estimate.R = function(config,...){
  if (missing(config)){ config = get.config(...) }
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
  return(R)
}
# report censoring
censor.map = list(
  report = 3, # assumed
  death  = round(q(covid.19.distr('sym-death'))(.9)) # X % of deaths
)