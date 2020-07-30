# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')
source.iter(root='Re/data','iphis.r')
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

plot.R(vs='Region',list(
  Toronto = estimate.R(region='Toronto'),
  Halton  = estimate.R(region='Halton'),
  Durham  = estimate.R(region='Durham'),
  Peel    = estimate.R(region='Peel'),
  York    = estimate.R(region='York')
))
save.fig('iphis-R-by-reported-compare-region')

plot.cases(vs='Source',list(
  All    = estimate.R(case.main='local',   case.travel='local',   case.ltc='local'   ),
  Other  = estimate.R(case.main='local',   case.travel='exclude' ,case.ltc='exclude' ),
  Travel = estimate.R(case.main='exclude' ,case.travel='local',   case.ltc='exclude' ),
  LTC    = estimate.R(case.main='exclude' ,case.travel='exclude' ,case.ltc='local'   )
)) + labs(y='New Reported Cases')
save.fig('iphis-cases-new-reported')

# compute neighbourhood-level R
neighbourhoods.R = list()
# TODO: compute for all neighbourhoods
for (name in neighbourhood.map[1:5]) {
  neighbourhoods.R[[name]] = estimate.R(neighbourhood=name)
}

# save neighbourhood-level R to file
fname = file.path(path.data, 'private', 'IPHIS_NEIGHBOURHOOD_Rt_EPISODE_DATE.xlsx')
if (file.exists(fname)) file.remove(fname)
for (name in names(neighbourhoods.R)) {
  nh = neighbourhoods.R[[name]]
  write.xlsx(nh$R, file=fname, sheetName=gsub('/', '', name), row.name=FALSE, append=TRUE)
}

print('done')

