# data cleaning
get.case.region = function(data.raw){
  region.clean = list(
    'TORONTO (3895)'       = 'Toronto',
    'DURHAM REGION (2230)' = 'Durham',
    'HALTON REGION (2236)' = 'Halton',
    'PEEL REGION (2253)'   = 'Peel',
    'YORK REGION (2270)'   = 'York'
  )
  map.fun = function(original){
    region = region.clean[[as.character(original)]]
    return(ifelse(is.null(region),NA,region))
  }
  return(unlist(lapply(data.raw$DIAGNOSING_HEALTH_UNIT_AREA,map.fun)))
}
get.case.date = function(config,data.raw){
  fmt = '%d%b%Y:%H:%M:%S'
  if (config$case.date == 'episode'){
    return(as.date(data.raw$ACCURATE_EPISODE_DATE,format=fmt))
  }
  if (config$case.date == 'report'){
    return(as.date(data.raw$CASE_REPORTED_DATE,format=fmt))
  }
}
get.case.death = function(data.raw){
  return(data.raw$CLIENT_DEATH_DATE != '')
}
get.case.travel = function(data.raw){
  return(data.raw$CASE_ACQUISITIONINFO == 'Travel-Related')
}
get.case.ltc = function(data.raw){
  return(data.raw$LTCH_RESIDENT == 'Yes' | data.raw$LTCH_HCW == 'Yes')
}
get.case.age = function(data.raw){
  return(data.raw$age_grp)
}
load.case.data = function(config){
  # fname = file.path(path.data,'private','ON_LineListforMOH_UofT.xlsx')
  fname = file.path(path.data,'private','IPHIS_REPORT_MIN.csv')
  data.raw = load.data(fname)
  return(data.frame(
    region = get.case.region(data.raw),
    dates  = get.case.date(config,data.raw),
    death  = get.case.death(data.raw),
    travel = get.case.travel(data.raw),
    ltc    = get.case.ltc(data.raw),
    age    = get.case.age(data.raw)
  ))
}
# combining regions - TODO: better way?
region.map = list(
  Toronto = 'Toronto',
  Durham  = 'Durham',
  Halton  = 'Halton',
  Peel    = 'Peel',
  York    = 'York',
  GTA     = c('Toronto','Durham','Halton','Peel','York')
)