###################################
# RpostcodesUK * include datasets #
###################################

Rfuns::load_pkgs('data.table')

for(x in c('missing_oa', 'missing_pcs', 'pcs_regions', 'pcs_linkage', 'pcd_linkage', 'pca_totals')) 
    save_dts_pkg(fread(paste0('./data-raw/csv/', x, '.csv')), dbn = 'postcodes_uk', x)

save_dts_pkg(fread('./data-raw/csv/pcs_non_geo.csv', sep = '\n'), dbn = 'postcodes_uk', 'pcs_non_geo')

rm(list = ls())
gc()