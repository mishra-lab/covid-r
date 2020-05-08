# Jesse Knight 2020
# University of Toronto
source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')
source.env(root='Re/data',iphis='iphis.r')

config.save = TRUE

refs = list(
  'S(t) [NP] Du 2020'       = list(param='ser-int', which='master'),
  'S(t) [NN] Zhang 2020'    = list(param='ser-int', which='Zhang2020'),
  'S(t) [NN] Nishiura 2020' = list(param='ser-int', which='Nishiura2020'),
  'G(t): [this]'            = list(param='gen-time',which='master')
)

t = seq(-60,60,0.1)
distr = data.frame(t=t)
R.objs = list()
R.fun = function(param,which){
  return(estimate.R(
    t.tau       = 11,
    case.smooth = 1,
    t.start     = as.date('2020-02-25'),
    t.end       = as.date('2020-05-01'),
    gen.time    = list(param=param, which=which)
  ))
}
distr.fun = function(param,which){
  D = covid.19.distr(param=param,which=which)
  print(paste(param,which,': mean =',E(D),'; sd =',sd(D),'; q95 = ',D@q(.95)))
  return(d(D)(t))
}
for (name in names(refs)){
  distr [[name]] = do.call(distr.fun,refs[[name]])
  R.objs[[name]] = do.call(R.fun,    refs[[name]])
}
# plot R
plot.R(R.objs,vs='Source',ylim=c(0,4),xlim=c('2020-03-08','2020-04-15')) +
  theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
save.fig('.tmp/deconv/Re',width=5,height=4)
# plot distr
D = melt(distr,id.vars='t',variable.name='Source',value.name='Probability')
ggplot(data=D, aes(x=t,y=Probability,color=Source)) +
  geom_line() +
  lims(x=c(-10,20)) +
  labs(x='Time (days)') +
  theme_light() +
  theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
save.fig('.tmp/deconv/distr-refs',width=5,height=3)