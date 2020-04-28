library('EpiEstim')
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
estimate.R = function(config,data){
  incid = make.incid(config,data)
  return(suppressWarnings({estimate_R(
    incid  = incid,
    method = 'parametric_si',
    config = make_config(make.re.config(config))
  )}))
}