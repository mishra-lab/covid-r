# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')
source.env(root='Re/data',iphis='iphis.r')

# config.save = TRUE

R.obj = estimate.R()
plot.R(list(main=R.obj))
save.fig('iphis-R-main')
plot.cases(list(main=R.obj))
save.fig('iphis-cases')

plot.R(vs='Travel',list(
  Include = estimate.R(case.travel='local'),
  Exclude = estimate.R(case.travel='imported')
))
save.fig('iphis-R-by-reported-compare-travel')

plot.R(vs='LTCH Residents',ylim=c(0,3),list(
  Include = estimate.R(case.ltcr='local'),
  Exclude = estimate.R(case.ltcr='exclude')
))
save.fig('iphis-R-by-reported-compare-LTCR-in-GTA')

default = list(case.main='exclude',case.travel='exclude',case.ltcr='local',case.ltcw='imported')
plot.R(vs='Staff Cases\nin LTCH',ylim=c(0,5),list(
  '100% Imported'              = do.call(estimate.R,c(default,list(import.local.frac=0.0))),
  # '\n50% Imported\n50% Local'  = do.call(estimate.R,c(default,list(import.local.frac=0.5))),
  '\n10% Imported\n90% Local'  = do.call(estimate.R,c(default,list(import.local.frac=0.9)))
))
save.fig('iphis-R-by-reported-compare-LTCW-in-LTCH-GTA')

plot.R(vs='Region',list(
  Toronto = estimate.R(region='Toronto'),
  Halton  = estimate.R(region='Halton'),
  Durham  = estimate.R(region='Durham'),
  Peel    = estimate.R(region='Peel'),
  York    = estimate.R(region='York')
))
save.fig('iphis-R-by-reported-compare-region')

regions = c('Toronto','Durham','Halton','Peel','York','GTA')
for (region in regions){
  plot.R(vs='LTC Cases',ylim=c(0,3),list(
    Include = estimate.R(region=region,case.ltcr='local'),
    Exclude = estimate.R(region=region,case.ltcr='exclude')
  )) + ylab(paste0('R(t) in ',region))
  save.fig(paste0('iphis-R-by-reported-compare-ltcr-',region))
  plot.cases(list(main=estimate.R(region=region)))
  save.fig(paste0('iphis-cases-',region))
}

plot.cases(vs='Source',list(
  All    = estimate.R(case.main='local',  case.travel='local',  case.ltcr='local',  case.ltcw='local'  ),
  Other  = estimate.R(case.main='local',  case.travel='exclude',case.ltcr='exclude',case.ltcw='exclude'),
  Travel = estimate.R(case.main='exclude',case.travel='local',  case.ltcr='exclude',case.ltcw='exclude'),
  LTCR   = estimate.R(case.main='exclude',case.travel='exclude',case.ltcr='local',  case.ltcw='exclude'),
  LTCW   = estimate.R(case.main='exclude',case.travel='exclude',case.ltcr='exclude',case.ltcw='local'  )
)) + labs(y='New Reported Cases')
save.fig('iphis-cases-new-reported')

print('done')

