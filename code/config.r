suppressPackageStartupMessages(library('distrEx'))
library('rjson')
# misc
options(width=200,keep.source=TRUE)
# paths
path.root  = strsplit(getwd(),file.path('code'))
path.fig   = file.path(path.root,'out','fig')
path.value = file.path(path.root,'out','value')
path.data  = file.path(path.root,'data')
path.distr = file.path(path.root,'data','public','distr')
path.code  = file.path(path.root,'code')
# source several files
source.iter = function(root=path.code,...){
  invisible(lapply(list(...),function(name){
    source(file.path(root,name))
  }))
}
# pseudo-namespaces
env <<- list()
source.env = function(root=path.code,...){
  args = list(...)
  for (name in names(args)){
    env[[name]] <<- new.env()
    sys.source(file.path(root,args[[name]]), envir = env[[name]])
  }
}
# saving stuff
config.save = FALSE
save.fig = function(fname,ext='.pdf',width=6,height=4,...) {
  if (config.save) {
    ggsave(file.path(path.fig,paste0(fname,ext)),width=width,height=height,...)
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