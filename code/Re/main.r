# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')
source.env(root='Re/data',iphis='iphis.r')

config.save = TRUE

R.obj = estimate.R()
plot.R(list(main=R.obj))
plot.cases(list(main=R.obj))

plot.R(vs='Travel',list(
  Include = estimate.R(case.travel='local'),
  Exclude = estimate.R(case.travel='imported')
))
save.fig('iphis-R-by-reported-compare-travel')

plot.R(vs='LTC Cases',list(
  Include = estimate.R(case.ltc='local'),
  Exclude = estimate.R(case.ltc='exclude')
))
save.fig('iphis-R-by-reported-compare-ltc')

plot.cases(vs='Source',list(
  All    = estimate.R(case.main='local',   case.travel='local',   case.ltc='local'   ),
  Other  = estimate.R(case.main='local',   case.travel='exclude' ,case.ltc='exclude' ),
  Travel = estimate.R(case.main='exclude' ,case.travel='local',   case.ltc='exclude' ),
  LTC    = estimate.R(case.main='exclude' ,case.travel='exclude' ,case.ltc='local'   )
)) + labs(y='New Reported Cases')
save.fig('iphis-cases-new-reported')

print('done')

