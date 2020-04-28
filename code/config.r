suppressPackageStartupMessages(library('distrEx'))
library('rjson')
# paths
path.root  = strsplit(getwd(),file.path('code'))
path.fig   = file.path(path.root,'out','fig')
path.value = file.path(path.root,'out','value')
path.data  = file.path(path.root,'data')
path.distr = file.path(path.root,'data','public','distr')
# saving stuff
save.fig = function(fname,ext='.pdf',...) {
  ggsave(file.path(path.fig,paste0(fname,ext)),...)
}
save.value = function(fname,value,rnd=3){
  s = sprintf(paste0('%.',rnd,'f'),value)
  sink(file.path(path.value,fname))
  cat(s)
  sink(NULL)
}
# common COVID19 distribution definitions using distr
covid.19.distr = function(param,which='master'){
  fname = file.path(path.distr,paste0(param,'.json'))
  spec  = fromJSON(file=fname)[[which]]
  distr = list(
    norm  = Norm,
    gamma = Gammad,
    lognorm = Lnorm
  )[[spec$distr]]
  return(do.call(distr,spec$params))
}
# helper functions
ggcolor = function(n){
  return(hcl(h=seq(15,375,length=n+1),l=65,c=100)[1:n])
}