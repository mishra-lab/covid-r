# Recovering the generation time distribution from serial interval & incubation period
# Jesse Knight 2020
# University of Toronto
# Notation:
# S(t) serial interval
# H(t) incubation period
# G(t) generation time

library('ggplot2')
library('reshape2')
library('optimization')
library('latex2exp')
source('config.r')
source('utils.r')

# config.save = TRUE

# define the time vector & distributions
dt = 0.1
t = seq(-40,40,dt)
S = d(covid.19.distr('ser-int'))(t)
H = d(covid.19.distr('inc-per'))(t)
# assume G(t) is gamma
# n.b. this is not true deconvolution
#      and we assume G(t) and H(t) are independent
G.fun = function(par){
  # dweibull(t, shape=par[1], scale=par[2])
  # dlnorm(t, meanlog=par[1], sdlog=par[2])
  dgamma(t, shape=par[1], scale=par[2])
}
# define the forward convolution: estimated S(t)
S.fun = function(G){
  return(dt*convolve(dt*convolve(G,H),rev(H)))
}
# define the objective function:
jfun = function(par){
  S.hat = S.fun(G.fun(par))
  if (any(is.na(S.hat))) { return(1e9) }
  J = sum(S.hat * (log(S.hat) - log(S))) # KL Divergence
  # J = sum((S.hat - S)^2) # SSE(S.hat-S)
  return(J)
}
# run the optimization
params = c(shape=1,scale=1)
opt = optim_nm(jfun,2,params,edge=.01,exit=1e4,tol=1e-9)
params[1:2] = opt$par
print(paste('J:',opt$function_value))
G.mean = params[[1]] * params[[2]]
G.sd   = sqrt(params[[1]]) * params[[2]]
G.95   = qgamma(.95, shape=params[1], scale=params[2])
print(c(params,c(mean=G.mean,sd=G.sd,q95=G.95)))
G = G.fun(params)
# plot the distributions
df = data.frame(t=t, S=S, H=H, G=G, Z=S.fun(G))
colnames(df) = c('t','S(t)','H(t)','G(t)','S*(t)')
labs = unname(sapply(c(
  '$S(\\tau)$',
  '$H(\\tau)$',
  '$\\hat{G}(\\tau\\,|\\,\\theta^*)$',
  '$\\hat{S}(\\tau\\,|\\,\\theta^*)$'
),TeX))
colors = c('#FF6666','#CC66CC','#6699FF','#FF6666')
lines = c('solid','solid','solid','dashed')
dfm = melt(df,id.vars='t',variable.name='Distribution',value.name='Probability')
ggplot(data=dfm, aes(x=t,y=Probability,color=Distribution,linetype=Distribution)) +
  geom_line() +
  scale_color_manual(values=colors,labels=labs) +
  scale_linetype_manual(values=lines,labels=labs) +
  lims(x=c(-15,30)) +
  labs(x='Time (days)') +
  theme_light() +
  theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
save.fig('.tmp/deconv/deconv',width=5,height=3)