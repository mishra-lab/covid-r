library('EpiEstim')
get.config = function(
  data.file = file.path(path.data,'private','ON_LineListforMOH_UofT.xlsx'),
  tau       = round(q(covid.19.distr('gen-time'))(0.9)),
  t0        = as.date('2020-02-15'),
  t1        = as.date('2020-04-26'),
  travel    = 'exclude',
  case.def  = 'death',
  region    = 'GTA',
  delay     = NULL
){
  config = as.list(environment())
  config$delay = ifelse(is.null(delay), delay.map[[config$case.def]], delay)
  return(config)
}
make.re.config = function(config){
  nt = length(make.dates(config))
  G = covid.19.distr('gen-time')
  return(list(
    t_start = seq(2, nt-config$tau),
    t_end   = seq(2+config$tau, nt),
    mean_si = E(G),
    std_si  = sd(G)
  ))
}
make.dates = function(config){
  return(seq(config$t0, config$t1-config$delay, 1))
}
make.incid = function(config,data){
  # define the dates
  dates = make.dates(config)
  # define some filters
  select.region = data$region %in% region.map[[config$region]]
  select.death  = !(!data$death & config$case.def=='death')
  select.local  = !(!data$local & config$travel=='exclude')
  # count function for both local and travel
  count.cases = function(local){
    select = ((local==select.local) & select.region & select.death)
    return(as.vector(table(
      factor(x = as.double(data$dates[select]),
             levels = as.double(dates))
    )))
  }
  return(data.frame(
    local    = count.cases(local=TRUE),
    imported = count.cases(local=FALSE),
    dates    = dates
  ))
}
estimate.R = function(config,data,rep=1){
  R.objs = list()
  for (i in 1:rep){
    incid = make.incid(config,data)
    R.objs[[i]] = suppressWarnings({estimate_R(
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