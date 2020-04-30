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
path.code  = file.path(path.root,'code')
source.fun = function(root=path.root,...){
  invisible(lapply(list(...),function(name){
    source(file.path(root,name))
  }))
}
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