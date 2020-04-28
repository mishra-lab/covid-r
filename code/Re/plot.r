library('ggplot2')

plot.R = function(R.objs,vs){
  if (missing(vs)){ vs = '' }
  g = estimate_R_plots(
    R.objs,
    what='R',
    options_R = list(
      ylim = c(0, 4.99),
      col  = ggcolor(length(R.objs))
    )
  )
  g = g +
    theme_light() +
    labs(title='',x='Time (days)',y='R(t)')
  if (is.list(R.objs)){
    g = g + guides(fill=FALSE) +
      scale_color_discrete(name=vs,labels=names(R.objs))
  }
  return(g)
}