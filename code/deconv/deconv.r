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
library('viridis')
source('config.r')
source('utils.r')

# config.save = TRUE

# define the time vector & distributions
dt = 0.01
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
nll.fun = function(par){
  S.hat = S.fun(G.fun(par))
  if (any(is.na(S.hat))) { return(1e9) }
  DKL = sum(S * (log(S) - log(S.hat))) # KL Divergence
  ELS = sum(S * log(S))                # Expectation of log S under t ~ S
  NLL = - (ELS - DKL)                  # negative log likelihood
  # Note: NLL is equivalent to DKL w.r.t. par as ELS does not depend on par
  return(NLL)
}
# compute the likelihood on a grid of alpha, beta
unc.fun = function(N=16){
  shape = seq(1,8,len=N)
  scale = seq(.33,8,len=N)
  U = expand.grid(shape=shape,scale=scale)
  U$NLL = mapply(
    function(shape,scale){
      return(nll.fun(c(shape,scale))/length(t)) },
    U$shape,U$scale)
  U$L = exp(-U$NLL)
  return(U)
}
# plot the likelihood vs alpha, beta
unc.plot = function(U,o){
  P = data.frame(shape=o$par[1],scale=o$par[2],L=o$L)
  ggplot(U,aes(x=shape,y=scale,fill=L,z=L)) +
    geom_raster(na.rm=TRUE) +
    stat_contour(na.rm=TRUE,bins=8,color='black',lwd=.1) +
    stat_contour(aes(z=1/sqrt(o$L-L)),bins=8,color='blue',lwd=.1) +
    scale_fill_viridis(option='inferno') +
    # geom_point(data=P,shape='*',color='blue') +
    labs(x=TeX('Shape ($\\alpha$)'),y=TeX('Scale ($\\beta$)'))
}
# run the optimization
mle.fun = function(){
  o = list(L=NA,par=c(shape=1,scale=1))
  opt = optim_nm(nll.fun,2,o$par,edge=.01,exit=1e4,tol=1e-9)
  o$par[1:2] = opt$par
  o$L        = exp(-opt$function_value/length(t))
  print(paste('L:',o$L))
  G.mean = o$par[[1]] * o$par[[2]]
  G.sd   = sqrt(o$par[[1]]) * o$par[[2]]
  G.95   = qgamma(.95, shape=o$par[1], scale=o$par[2])
  print(c(o$par,c(mean=G.mean,sd=G.sd,q95=G.95)))
  return(o)
}
# plotting the results
mle.plot = function(G){
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
    lims(x=c(-10,20),y=c(0,.22)) +
    labs(x='Time (days)') +
    theme_light() +
    theme(legend.text.align=0,legend.position=c(.99,.99),legend.justification=c(1,1))
}
## MLE
o = mle.fun()
G = G.fun(o$par)
mle.plot(G)
save.fig('.tmp/deconv/deconv',width=5,height=3)
## uncertainty
U = unc.fun() # N=128
g = unc.plot(U,o)
save.fig('.tmp/deconv/uncertainty',width=5,height=4)
