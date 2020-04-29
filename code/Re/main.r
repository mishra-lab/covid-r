# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
library('reshape2')
invisible(sapply(c('data','re','plot','run'),function(fname){
  source(file.path('Re',paste0(fname,'.r')))
}))
config.save = TRUE
run.default.R()
run.compare.travel()
run.compare.case()
run.compare.adj.death()
print('done')