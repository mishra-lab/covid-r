library('ggplot2')

plot.R = function(R.objs,vs){
  if (is.list(R.objs) & length(R.objs)==1){ R.objs = R.objs[[1]] }
  if (missing(vs)){ vs = '' }
  g = estimate_R_plots(
    R.objs,
    what='R',
    options_R = list(
      col = ggcolor(length(R.objs))
    )
  )
  g = g +
    theme_light() +
    labs(title='',x='Time (days)',y='R(t)') +
    coord_cartesian(ylim = c(0,5)) 
  if (is.list(R.objs)){
    g = g + guides(fill=FALSE) +
      scale_color_discrete(name=vs,labels=names(R.objs))
  }
  return(g)
}
