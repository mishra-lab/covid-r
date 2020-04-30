library('readxl')
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
load.case.data = function(){
  fname = file.path(path.data,'private','ON_LineListforMOH_UofT.xlsx')
  data.raw = data.frame(read_excel(fname))
  data = data.frame(
    # TODO: add back date type
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
load.ltc.distr = function(){
  fname = file.path(path.data,'private','ltc-distr.csv')
  return(read.csv(fname))
}