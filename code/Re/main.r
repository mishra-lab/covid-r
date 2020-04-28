# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
source(file.path('Re','data.r'))
source(file.path('Re','re.r'))
source(file.path('Re','plot.r'))
# config stuff
get.config = function(
  data.file = file.path(path.data,'private','ON_LineListforMOH_UofT.xlsx'),
  tau       = round(q(covid.19.distr('gen-time'))(0.9)),
  t0        = as.date('2020-02-15'),
  t1        = as.date('2020-04-26'),
  travel    = 'exclude',
  case.def  = 'death',
  region    = 'GTA',
  delay     = NULL
){
  config = as.list(environment())
  config$delay = ifelse(is.null(delay), delay.map[[config$case.def]], delay)
  return(config)
}
config = get.config()
# load data
data = clean.data(config)
# R @ default config
R.0 = estimate.R(config,data)
# R @ travel: include
R.travel.include = estimate.R(get.config(travel='include'),data)
# R @ case.def: report
R.case.report = estimate.R(get.config(case.def='report',delay=config$delay),data)
# plot R @ default
plot.R(R.0)
save.fig('Re-default',width=6,height=4)
# plot R compare travel
plot.R(list(Exclude=R.0,Include=R.travel.include),vs='Travel')
save.fig('Re-cf-travel',width=6,height=4)
# plot R compare case definition
plot.R(list(Deaths=R.0,Report=R.case.report),vs='Case Definition')
save.fig('Re-cf-case',width=6,height=4)