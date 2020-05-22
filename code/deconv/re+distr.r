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
  'G(t) [this]'             = list(param='gen-time',which='master')
)
R.dates = c('2020-03-16','2020-04-13')

t = seq(-60,60,0.1)
distr = data.frame(t=t)
R.objs = list()
R.fun = function(param,which){
  return(estimate.R(
    t.tau       = 11,
    case.smooth = 1,
    t.start     = as.date('2020-02-25'),
    t.end       = as.date('2020-05-15'),
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
  for (R.date in R.dates){
    save.value(paste('R',R.date,name),get.R.value(R.objs[[name]],date=R.date),rnd=2)
  }
  R.df = R.objs[[name]]$R
  R.df$dates = R.objs[[name]]$dates[R.df$t_end]
  save.csv(paste('R',name),R.df)
}
# plot R
plot.R(R.objs,vs='Source',ylim=c(0,3.5),xlim=c('2020-03-09','2020-05-04')) +
  theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
save.fig('.tmp/deconv/Re',width=5,height=4)
plot.R(R.objs,vs='Source',ylim=c(0.5,1.5),xlim=c('2020-03-30','2020-05-04')) +
  theme(legend.text.align=0,legend.position=c(.01,.01),legend.justification=c(0,0))
save.fig('.tmp/deconv/Re-zoom',width=5,height=4)
# plot distr
D = melt(distr,id.vars='t',variable.name='Source',value.name='Probability')
ggplot(data=D, aes(x=t,y=Probability,color=Source)) +
  geom_line() +
  lims(x=c(-10,20)) +
  labs(x='Time (days)') +
  theme_light() +
  theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
save.fig('.tmp/deconv/distr-refs',width=5,height=3)