suppressPackageStartupMessages(library('distrEx'))
library('rjson')
# misc
options(width=200)
# paths
path.root  = strsplit(getwd(),file.path('code'))
path.fig   = file.path(path.root,'out','fig')
path.value = file.path(path.root,'out','value')
path.data  = file.path(path.root,'data')
path.distr = file.path(path.root,'data','public','distr')
# saving stuff
config.save = FALSE
save.fig = function(fname,ext='.pdf',...) {
  if (config.save) {
    ggsave(file.path(path.fig,paste0(fname,ext)),...)
  }
}
save.value = function(fname,value,rnd=3){
  if (config.save) {
    s = sprintf(paste0('%.',rnd,'f'),value)
    sink(file.path(path.value,fname))
    cat(s)
    sink(NULL)
  }
}
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
# helper functions
ggcolor = function(n){
  return(hcl(h=seq(15,375,length=n+1),l=65,c=100)[1:n])
}