data.info = list(
  travel = TRUE,
  ltc    = FALSE
)
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
    region = region.clean[[original]]
    return(ifelse(is.null(region),NA,region))
  }
  return(unlist(lapply(data.raw$Diagnosing_Health_Unit_Area_Desc,map.fun)))
}
get.case.date = function(config,data.raw){
  if (config$case.date == 'episode'){
    return(as.date(data.raw$Accurate_Episode_Date))
  }
  if (config$case.date == 'report'){
    return(as.date(data.raw$Case_Reported_Date))
  }
}

load.case.data = function(config){
  fname = file.path(path.data,'private','ON_LineListforMOH_UofT.xlsx')
  data.raw = load.data(fname)
  return(data.frame(
    # TODO: add back date type
    dates  = get.case.date(config,data.raw),
    travel = data.raw$Case_AcquisitionInfo == 'Travel-Related',
    age    = data.raw$Age_At_Time_of_Illness,
    death  = !is.na(data.raw$Client_Death_date),
    region = get.case.region(data.raw)
  ))
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