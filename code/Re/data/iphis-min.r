library(dplyr)
source('config.r')
source('utils.r')
source.iter(root='Re','re.r','plot.r','incid.r')

# columns to extract from the large database
cols = c(
  'ACCURATE_EPISODE_DATE',
  'CASE_REPORTED_DATE',
  'CASE_ACQUISITIONINFO',
  'LIKELY_ACQUISITION',
  'CLIENT_DEATH_DATE',
  'DIAGNOSING_HEALTH_UNIT_AREA',
  'LTCH_RESIDENT',
  'LTCH_HCW',
  'age_grp',
  'DAUID',
  'NHid',
  'NHname'
)
X = load.data(file.path(path.data,'private','IPHIS_REPORT.csv'))

# merge with DAUID-NH mapping to get NHid and NHname
fname = file.path(path.data, 'private', 'DAs16_NHs396_v12a_04June2020_FINAL_TORONTO.xlsx')
DAUID = data.frame(read_excel(fname, sheet='CityToronto_DAUID'))
X = X %>% dplyr::left_join(DAUID, by=c('DAUID' = 'DA2016_num'))

save.data(X[,cols], file.path(path.data,'private','IPHIS_REPORT_MIN.csv'))