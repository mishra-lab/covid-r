library('readxl')
# raw data
load.data = function(config){
  return(data.frame(read_excel(config$data.file)))
}
# data cleaning
region.clean <<- list(
  'TORONTO (3895)'       = 'Toronto',
  'DURHAM REGION (2230)' = 'Durham',
  'HALTON REGION (2236)' = 'Halton',
  'PEEL REGION (2253)'   = 'Peel',
  'YORK REGION (2270)'   = 'York'
)
get.case.dates = function(data.raw){
  return(as.date(data.raw$Accurate_Episode_Date))
}
get.case.local = function(data.raw){
  return(data.raw$Case_AcquisitionInfo != 'Travel-Related')
}
get.case.age = function(data.raw){
  return(data.raw$Age_At_Time_of_Illness)
}
get.case.death = function(data.raw){
  return(!is.na(data.raw$Client_Death_date))
}
get.case.region = function(data.raw){
  map.fun = function(key){
    region = region.clean[[key]]
    return(ifelse(is.null(region),NA,region))
  }
  return(unlist(lapply(data.raw$Diagnosing_Health_Unit_Area_Desc,map.fun)))
}
as.date = function(dates){
  return(as.Date(
    dates,
    format='%Y-%m-%d',
    origin='1970-01-01'
  ))
}
clean.data = function(config,data.raw){
  if (missing(data.raw)){ data.raw = load.data(config) }
  data = data.frame(
    dates  = get.case.dates(data.raw),
    local  = get.case.local(data.raw),
    age    = get.case.age(data.raw),
    death  = get.case.death(data.raw),
    region = get.case.region(data.raw)
  )
}
# combining regions
region.map = list(
  Toronto = 'Toronto',
  Durham  = 'Durham',
  Halton  = 'Halton',
  Peel    = 'Peel',
  York    = 'York',
  GTA     = c('Toronto','Durham','Halton','Peel','York')
)
# delays
delay.map = list(
  report = 5, # assumed
  death  = round(q(covid.19.distr('sym-death'))(.9)) # X % of deaths
)