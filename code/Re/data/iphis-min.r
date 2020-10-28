source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')

# columns to extract from the large database
cols = c(
  'ACCURATE_EPISODE_DATE',
  'CASE_REPORTED_DATE',
  'LIKELY_ACQUISITION',
  'CLIENT_DEATH_DATE',
  'DIAGNOSING_HEALTH_UNIT_AREA',
  'LTCH_RESIDENT',
  'LTCH_HCW',
  'age_grp'
)
X = load.data(file.path(path.data,'private','IPHIS_REPORT.csv'))
save.data(names(X), file.path(path.data,'private','IPHIS_REPORT_HEAD.csv'))
save.data(X[,cols], file.path(path.data,'private','IPHIS_REPORT_MIN.csv'))