run.default.R = function(...){
  g = plot.R(estimate.R(...))
  save.fig('Re-default',width=6,height=4)
  return(g)
}
run.compare.travel = function(...){
  g = plot.R(vs='Travel',list(
    Exclude = estimate.R(travel='exclude',...),
    Include = estimate.R(travel='include',...)
  ))
  save.fig('Re-cf-travel',width=6,height=4)
  return(g)
}
run.compare.case = function(...){
  delay = get.config()$delay
  g = plot.R(vs='Case Definition',list(
    Deaths   = estimate.R(case.def='death',delay=delay,...),
    Reported = estimate.R(case.def='report',delay=delay,...)
  ))
  save.fig('Re-cf-case',width=6,height=4)
  return(g)
}
run.compare.adj.death = function(...,save=FALSE){
  g = plot.R(vs='Adjustment',list(
    None    = estimate.R(case.adj=FALSE,...),
    Overall = estimate.R(case.adj='overall',...),
    Age     = estimate.R(case.adj='age',...)
  ))
  save.fig('Re-cf-adj-death',width=6,height=4)
  return(g)
}