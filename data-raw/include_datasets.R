###############################################################################
# RpostcodesUK * Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
###############################################################################

Rfuns::load_pkgs('data.table')

# lookups
ys <- fread(paste0('./data-raw/csv/OA_PCS.csv'), key = 'OA')
yd <- fread(paste0('./data-raw/csv/OA_PCD.csv'), key = 'OA')
yt <- fread(paste0('./data-raw/csv/PCD_PCT.csv'))
ya <- fread(paste0('./data-raw/csv/OA_PCA.csv'), key = 'OA')
y <- ya[yt[, .(PCD, PCT)][yd[ys], on = 'PCD'], on = 'OA'] |> 
        setcolorder(c('OA', 'PCS', 'PCD', 'PCT')) |> 
        setorder('OA')
fn <- 'lookups'
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# pzones
ys <- fread(paste0('./data-raw/csv/PCS.csv'))
yd <- fread(paste0('./data-raw/csv/PCD.csv'))
yt <- fread(paste0('./data-raw/csv/PCT.csv'))
ya <- fread(paste0('./data-raw/csv/PCA.csv'))
y <- rbindlist(list(
        ys[, .(type = 'PCS', code = PCS, name = PCS, ordering)],
        yd[, .(type = 'PCD', code = PCD, name = PCD, ordering)],
        yt[, .(type = 'PCT', code = PCT, name, ordering)],
        ya[, .(type = 'PCA', code = PCA, name, ordering = 1:.N)]
))
fn <- 'pzones'
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )





rm(list = ls())
gc()