fig.path = file.path('..','out','fig')
save.fig = function(fname,ext='.pdf',...) {
  print(last_plot())
  ggsave(file.path(fig.path,paste0(fname,ext)),...)
}