library('readxl')
library('xlsx')
ggcolor = function(n){
  return(hcl(h=seq(15,375,length=n+1),l=65,c=100)[1:n])
}
file.ext = function(fname){
  return(tail(strsplit(fname,'\\.')[[1]],1))
}
fname.clean = function(fname){
  return(gsub(' ','-',fname))
}
load.data = function(fname){
  return(list(
    csv  = function(fname){ read.csv(fname) },
    xlsx = function(fname){ data.frame(read_excel(fname)) },
    json = function(fname){ fromJSON(file=fname) }
  )[[file.ext(fname)]](fname))
}
save.data = function(data,fname){
  list(
    csv  = function(data,fname){ write.csv(data,fname,row.names=FALSE) }
    # xlsx = function(data,fname){ write.xlsx(data,fname) }
    # json = function(data,fname){ toJSON(data,file=fname) }
  )[[file.ext(fname)]](data, fname)
}
as.date = function(dates,format='%Y-%m-%d'){
  return(as.Date(
    dates,
    format=format,
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
  return(load.data(file.path(path.distr,paste0(name,'.json'))))
}
# common COVID19 distribution definitions using distr
covid.19.distr = function(param,which='master'){
  spec  = distr.json(param)[[which]]
  distr = list(
    norm  = Norm,
    gamma = Gammad,
    lognorm = Lnorm,
    weibull = Weibull
  )[[spec$distr]]
  return(do.call(distr,spec$params))
}
# get lognorm params from mean and sd
lognorm.params = function(mu,sigma){
  return(list(
    meanlog = log(mu / sqrt(1 + (sigma/mu)^2)),
    sdlog   = sqrt(log(1 + (sigma/mu)^2))
  ))
}
# get gamma params from mean and sd
gamma.params = function(mu,sigma){
  return(list(
    shape = mu^2 / sigma^2,
    scale = sigma^2 / mu
  ))
}