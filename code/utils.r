ggcolor = function(n){
  return(hcl(h=seq(15,375,length=n+1),l=65,c=100)[1:n])
}
as.date = function(dates){
  return(as.Date(
    dates,
    format='%Y-%m-%d',
    origin='1970-01-01'
  ))
}
conv = function(x,kern){
  N = length(x)
  K = (length(kern)-1)/2
  x = c(rep(x[1],K), x, rep(x[N],K))
  return(filter(x, kern, method='convolution')[(K+1):(K+N)])
}
gauss.kernel = function(sigma){
  K = ceiling(2.5*sigma)
  kernel = dnorm(seq(-K,+K),sd=sigma)
  return(kernel/sum(kernel))
}
# load json file from distr directory
distr.json = function(name){
  return(fromJSON(file=file.path(path.distr,paste0(name,'.json'))))
}
# common COVID19 distribution definitions using distr
covid.19.distr = function(param,which='master'){
  spec  = distr.json(param)[[which]]
  distr = list(
    norm  = Norm,
    gamma = Gammad,
    lognorm = Lnorm
  )[[spec$distr]]
  return(do.call(distr,spec$params))
}