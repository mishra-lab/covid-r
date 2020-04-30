# Estimating effective reproductive number for COVID19 in GTA
# Jesse Knight 2020
# University of Toronto
source('config.r')
source('utils.r')
source.fun(root='Re','re.r','plot.r','run.r')
source.fun(root='Re/data','moh-uoft.r')
# run.compare.case.travel()
# run.compare.case.def()
# run.compare.case.adj()
# run.compare.case.smooth()
run.compare.case.ltc(case.travel='include')
print('done')