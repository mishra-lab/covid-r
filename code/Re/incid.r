smooth.incid = function(config,incid){
  if (config$case.smooth){
    return(conv(incid, gauss.kernel(config$case.smooth)))
  } else {
    return(incid)
  }
}
get.ifr.weights = function(config,data){
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
load.cum.distr = function(dates){
  fname = file.path(path.data,'private','on-cum-distr.csv')
  data = load.data(fname)
  return(data[as.numeric(as.date(data$date)) %in% as.numeric(dates),])
}
get.case.select = function(config,data,context){
  select = as.logical(rep(1,nrow(data)))
  select = select & (data$region %in% region.map[[config$region]])
  if (config$case.def == 'death'){
    select = select & data$death
  }
  return(select)
}
cum.adjust = function(cases,adjust){
  return(c(cases[1],diff(adjust*cumsum(cases))))
}
get.cases = function(config,dates,distr,data,src){
  select = get.case.select(config,data,src)
  adjust = rep(1,length(dates))
  for (what in c('travel','ltc')){
    if (data.info[[what]]){             # if flag available: select lines
      if (src == what){
        select = select &  data[[what]] # include matches
      } else {
        select = select & !data[[what]] # exclude matches
      }
    } else {                            # flag not available: adjust counts
      if (src == what){
        adjust = distr[[what]]          # only proportion
      }
      if (src == 'main'){
        adjust = adjust - distr[[what]] # remove proportion
      }
    }
  }
  weights = get.case.weights(config,data)
  cases = as.vector(wtd.table(
    x = factor(as.numeric(data$dates[select]), levels=as.numeric(dates)),
    weights = weights[select]
  ))
  cases = cum.adjust(cases,adjust)
  return(cases)
}
get.incid = function(config,dates){
  data = load.case.data(config)
  distr = load.cum.distr(dates)
  cases = list(
    travel = get.cases(config,dates,distr,data,'travel'),
    main   = get.cases(config,dates,distr,data,'main'),
    ltc    = get.cases(config,dates,distr,data,'ltc')
  )
  combine.cases = function(context){
    return(smooth.incid(config,
      (config$case.travel == context) * cases$travel +
      (config$case.main   == context) * cases$main +
      (config$case.ltc    == context) * cases$ltc
    ))
  }
  local    = combine.cases('local')
  imported = combine.cases('imported')
  return(data.frame(
    local    = local * (1-config$unkn.import.frac),
    imported = local * (  config$unkn.import.frac) + imported * config$import.frac,
    dates    = dates
  ))
}