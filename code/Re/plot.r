library('ggplot2')
library('reshape2')

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
plot.cases = function(R.objs,what='all',cum=FALSE,vs){
  if ('SI.Moments' %in% names(R.objs)) { R.objs=list(' '=R.objs) }
  if (missing(vs)){ vs = '.' }
  cfun  = ifelse(cum,cumsum,identity)
  iname = list(all='I',local='I_local',imported='I_imported')[[what]]
  df = data.frame(dates=as.date(seq(
    min(sapply(R.objs,function(R.obj){ head(R.obj$dates,1) })),
    max(sapply(R.objs,function(R.obj){ tail(R.obj$dates,1) })),
  )))
  for (name in names(R.objs)){
    index = df$dates %in% R.objs[[name]]$dates
    df[index,name] = cfun(R.objs[[name]][[iname]])
  }
  dfm = melt(df,id.vars='dates',value.name='Cases',variable.name=vs)
  g = ggplot(dfm,aes_string(x='dates',y='Cases',col=vs)) +
    geom_line() +
    theme_light() +
    labs(x='Time (days)',y='Cases')
  if (length(R.objs)==1){
    g = g + guides(col=FALSE)
  }
  return(g)
}
