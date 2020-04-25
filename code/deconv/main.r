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
source('config.r')

# define the time vector & distributions
dt = 0.1
t = seq(-60,60,dt)
S = dnorm(t, mean=3.96, sd=4.75)        # S(t) doi: 10.3201/eid2606.200357
H = dgamma(t, shape=5.807, scale=0.948) # H(t) doi: 10.7326/m20-0504
# assume G(t) is gamma
# n.b. this is not true deconvolution
#      and we assume G(t) and H(t) are independent
G.fun = function(par){
  dgamma(t, shape=par[1], scale=par[2])
}
# define the forward convolution: estimated S(t)
S.fun = function(G){
  return(dt*convolve(dt*convolve(G,H),rev(H)))
}
# define the objective function: SSE(S.hat-S.obs)
jfun = function(par){
  S.hat = S.fun(G.fun(par))
  return(sum((S.hat - S)^2))
}
# run the optimization
params = c(shape=1,scale=1)
opt = optim_nm(jfun,2,params,edge=.01,exit=1e4,tol=1e-9)
params[1:2] = opt$par
print(params)
save.value('G-gamma-shape',params['shape'])
save.value('G-gamma-scale',params['scale'])
G = G.fun(params)
# plot the distributions
df = data.frame(t=t, S=S, H=H, G=G, Z=S.fun(G))
colnames(df) = c('t','S(t)','H(t)','G(t)','S*(t)')
dfm = melt(df,id.vars='t',variable.name='Distribution',value.name='Probability')
g = ggplot(data=dfm, aes(x=t,y=Probability,color=Distribution)) +
  geom_line() +
  lims(x=c(-15,30)) +
  labs(x='Time (days)') +
  theme_light() +
  theme(legend.position = 'top')
save.fig('deconv',width=5,height=3)