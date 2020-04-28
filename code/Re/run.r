run.default.R = function(...){
  config = get.config(...)
  data = clean.data(config)
  R = estimate.R(config,data)
  plot.R(R)
  save.fig('Re-default',width=6,height=4)
}
run.compare.travel = function(...){
  config = get.config(...)
  data = clean.data(config)
  # estimate R
  config$travel = 'exclude'
  R.exclude = estimate.R(config,data)
  config$travel = 'include'
  R.include = estimate.R(config,data)
  # plot
  plot.R(vs='Travel',list(
    Exclude=R.exclude,
    Include=R.include))
  save.fig('Re-cf-travel',width=6,height=4)
}
run.compare.case = function(...){
  config = get.config(...)
  data = clean.data(config)
  # estimate R
  config$case.def = 'death'
  R.death = estimate.R(config,data)
  config$case.def = 'report'
  R.report = estimate.R(config,data)
  # plot
  plot.R(vs='Case Definition',list(
    Deaths=R.death,
    Reported=R.report))
  save.fig('Re-cf-case',width=6,height=4)
}