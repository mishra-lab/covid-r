# smooth incidence timeseries with a gaussian kernel
smooth.incid = function(config,incid){
  if (config$case.smooth){
    return(conv(incid, gauss.kernel(config$case.smooth)))
  } else {
    return(incid)
  }
}
# weights to infer number of cases based on deaths, using IFR = infection fatality ratio
# either overall or by age group
# WARNING: this has not been validated, and there are issues with overestimated precision
get.ifr.weights = function(config,data){
  # weight functions: point estimate or random sampling
  cap = function(wt){ min(wt, 100) }
  wt.fun = ifelse(config$case.sample > 1,
    function(ref,cm){ cap( ref / runif(1, cm$low, cm$high) ) },
    function(ref,cm){ cap( ref / cm$mean ) }
  )
  # weight maps based on infection fatality ratio
  ifr = distr.json('ifr')
  ref = ifr$overall$mean
  wt.map = list(
    overall = function(i){ wt.fun( ref, ifr$overall ) },
    age = function(i){ wt.fun( ref, ifr$age$groups[[ max(1,min(9,floor(data$age[i]/10)+1)) ]] ) }
  )[[ config$case.adj ]]
  # compute the weights
  return(sapply(1:nrow(data), wt.map))
}
get.case.weights = function(config,data){
  weights = rep(1,nrow(data))
  # no adjustment
  if (config$case.adj == FALSE){ return(weights) }
  # adjustment for deaths
  if (config$case.def == 'death'){
    weights = weights * get.ifr.weights(config,data)
  }
  # TODO: adjustment for reported cases
  return(weights)
}
get.case.select = function(config,data,context){
  select = as.logical(rep(1,nrow(data)))
  select = select & (data$region %in% region.map[[config$region]])
  if (config$case.def == 'death'){
    select = select & data$death
  }
  return(select)
}
get.cases = function(config,dates,data,src){
  select = get.case.select(config,data,src)
  adjust = rep(1,length(dates))
  for (what in c('travel','ltcr','ltcw')){
    if (src == what){
      select = select &  data[[what]] # include matches
    } else {
      select = select & !data[[what]] # exclude matches
    }
  }
  weights = get.case.weights(config,data)
  cases = as.vector(wtd.table(
    x = factor(as.numeric(data$dates[select]), levels=as.numeric(dates)),
    weights = weights[select]
  ))
  return(cases)
}
get.incid = function(config,dates){
  data = load.case.data(config)
  cases = list(
    travel = get.cases(config,dates,data,'travel'),
    main   = get.cases(config,dates,data,'main'),
    ltcr   = get.cases(config,dates,data,'ltcr'),
    ltcw   = get.cases(config,dates,data,'ltcw')
  )
  combine.cases = function(context){
    return(smooth.incid(config,
      (config$case.travel == context) * cases$travel +
      (config$case.main   == context) * cases$main +
      (config$case.ltcr   == context) * cases$ltcr +
      (config$case.ltcw   == context) * cases$ltcw
    ))
  }
  local    = combine.cases('local')
  imported = combine.cases('imported')
  return(data.frame(
    local    = local * (1-config$local.import.frac) + imported * (  config$import.local.frac),
    imported = local * (  config$local.import.frac) + imported * (1-config$import.local.frac),
    dates    = dates
  ))
}




