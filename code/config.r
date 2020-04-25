fig.path = file.path('..','out','fig')
value.path = file.path('..','out','value')
save.fig = function(fname,ext='.pdf',...) {
  print(last_plot())
  ggsave(file.path(fig.path,paste0(fname,ext)),...)
}
save.value = function(fname,value,rnd=3){
  s = sprintf(paste0('%.',rnd,'f'),value)
  sink(file.path(value.path,fname))
  cat(s)
  sink(NULL)
}