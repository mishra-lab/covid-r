# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
sapply(c('data','re','plot','run'),function(fname){
  source(file.path('Re',paste0(fname,'.r')))
})
# run.default.R()
# run.compare.travel()
# run.compare.case()
