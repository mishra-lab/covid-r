library('EpiEstim')
library('questionr')
get.config = function(
  t.tau          = round(q(covid.19.distr('gen-time'))(0.9)),
  t.start        = as.date('2020-02-15'),
  t.end          = as.date('2020-04-28'),
  t.censor       = NULL,          # censor
  case.def       = 'death',       # 'death', 'report'
  case.travel    = 'exclude',     # 'exclude', 'include'
  case.ltc       = 'include',     # 'include', 'exclude'
  case.adj       = FALSE,         # FALSE, 'overall', 'age'
  case.sample    = FALSE,         # number of sample iterations
  case.smooth    = 2,             # sd of gaussian smoothing kernel
  region         = 'GTA'
){
  config = as.list(environment())
  config$t.censor = ifelse(is.null(t.censor), censor.map[[config$case.def]], t.censor)
  return(config)
}
make.re.config = function(config){
  nt = length(make.dates(config))
  G  = covid.19.distr('gen-time')
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
make.dates = function(config){
  return(seq(config$t.start, config$t.end-config$t.censor, 1))
}
make.ifr.weights = function(config,data){
  # weight functions: point estimate or random sampling
  cap = function(wt){ min(wt, 100) }
  wt.fun = ifelse(config$case.sample > 1,
    function(ref,cm){ cap( ref / runif(1, cm$low, cm$high) ) },
    function(ref,cm){ cap( ref / cm$mean) }
  )
  # weight maps based on infection fatality ratio
  ifr = distr.json('ifr')
  ref = ifr$overall$mean
  wt.map = list(
    overall = function(i){ wt.fun( ref, ifr$overall ) },
    age = function(i){ wt.fun( ref, ifr$age$groups[[ min(9,floor(data$age[i]/10)+1) ]] ) }
  )[[ config$case.adj ]]
  # compute the weights
  return(sapply(1:nrow(data), wt.map))
}
make.weights = function(config,data){
  weights = rep(1,nrow(data))
  # no adjustment
  if (config$case.adj == FALSE){ return(weights) }
  # adjustment for deaths
  if (config$case.def == 'death'){
    weights = weights * make.ifr.weights(config,data)
  }
  # TODO: adjustment for reported cases
  return(weights)
}
smooth.incid = function(config,incid){
  if (config$case.smooth){
    return(conv(incid, gauss.kernel(config$case.smooth)))
  } else {
    return(incid)
  }
}
make.incid = function(config,data){
  # define the dates
  dates = make.dates(config)
  # define the weights (may be random)
  weights = make.weights(config,data)
  # define some filters
  select.region = data$region %in% region.map[[config$region]]
  select.death  = !(!data$death & config$case.def=='death')
  select.local  = !(!data$local & config$case.travel=='exclude')
  # count function for both local and travel
  count.cases = function(local){
    select = ((local==select.local) & select.region & select.death)
    return(smooth.incid(config,as.vector(wtd.table(
      x = factor(x=as.double(data$dates[select]), levels=as.double(dates)),
      weights = weights[select],
    ))))
  }
  return(data.frame(
    local    = count.cases(local=TRUE),
    imported = count.cases(local=FALSE),
    dates    = dates
  ))
}
estimate.R = function(config,data,...){
  if (missing(config)){ config = get.config(...) }
  if (missing(data))  { data = clean.data() }
  R.objs = list()
  for (s in 1:max(1,config$sample)){
    incid = make.incid(config,data)
    R.objs[[s]] = suppressWarnings({estimate_R(
      incid  = incid,
      method = 'parametric_si',
      config = make_config(make.re.config(config))
    )})
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
# delays
censor.map = list(
  report = 14, # assumed
  death  = round(q(covid.19.distr('sym-death'))(.9)) # X % of deaths
)