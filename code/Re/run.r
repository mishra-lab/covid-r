plot.map = list(
  R = plot.R,
  cases = plot.cases
)
run.default.R = function(what='R',...){
  return(plot.map[[what]](estimate.R(...)))
}
run.compare.case.travel = function(what='R',...){
  return(plot.map[[what]](vs='Travel',list(
    'Exclude' = estimate.R(case.travel='exclude',...),
    'Include' = estimate.R(case.travel='include',...)
  )))
}
run.compare.case.ltc = function(what='R',...){
  return(plot.map[[what]](vs='LTC',list(
    'Exclude' = estimate.R(case.def='report',case.ltc='exclude',...),
    'Include' = estimate.R(case.def='report',case.ltc='include',...)
  )))
}
run.compare.case.def = function(what='R',...){
  t.censor = get.config()$t.censor
  return(plot.map[[what]](vs='Case',list(
    'Deaths'   = estimate.R(t.censor=t.censor,case.def='death', ...),
    'Reported' = estimate.R(t.censor=t.censor,case.def='report',...)
  )))
}
run.compare.case.adj = function(what='R',...){
  return(plot.map[[what]](vs='Adjustment',list(
    'None'    = estimate.R(case.adj=FALSE,    case.smooth=1,...),
    'Overall' = estimate.R(case.adj='overall',case.smooth=1,...),
    'Age'     = estimate.R(case.adj='age',    case.smooth=1,...)
  )))
}
run.compare.case.smooth = function(what='R',...){
  return(plot.map[[what]](vs='Smoothing',list(
    'None'   = estimate.R(case.smooth=0,...),
    '2 Days' = estimate.R(case.smooth=2,...)
  )))
}