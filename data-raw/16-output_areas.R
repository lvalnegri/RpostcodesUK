################################################
# RpostcodesUK * Create Dataset `output_areas` #
################################################

Rfuns::load_pkgs('data.table')

ys <- fread(paste0('./data-raw/csv/OA_PCS.csv'), key = 'OA')
yd <- fread(paste0('./data-raw/csv/OA_PCD.csv'), key = 'OA')
yt <- fread(paste0('./data-raw/csv/PCD_PCT.csv'))
ya <- fread(paste0('./data-raw/csv/OA_PCA.csv'), key = 'OA')
y <- ya[yt[, .(PCD, PCT)][yd[ys], on = 'PCD'], on = 'OA'] |>setorderv(c('PCA', 'PCT', 'PCD', 'PCS', 'OA'))
yr <- fread(
        'https://www.arcgis.com/sharing/rest/content/items/efda0d0e14da4badbd8bdf8ae31d2f00/data',
        select = 1:3,
        col.names = c('OA', 'RGN', 'RGNd'),
        key = 'OA'
)
y <- yr[y]
y[, CTRY := substr(OA, 1, 1)]
y[CTRY != 'E', `:=`(
    RGN  = fcase( CTRY == 'W', 'W92000004', CTRY == 'S', 'S92000003', CTRY == 'N', 'N92000002'),
    RGNd = fcase( CTRY == 'W', 'Wales', CTRY == 'S', 'Scotland', CTRY == 'N', 'N.Ireland')
)]
y[, CTRY := fcase( CTRY == 'E', 'England', CTRY == 'W', 'Wales', CTRY == 'S', 'Scotland', CTRY == 'N', 'N.Ireland')]

setcolorder(y, c('OA', 'PCS', 'PCD', 'PCT', 'PCA')) 
save_dts_pkg(y, 'output_areas', geouk_path, c('RGN', 'PCS'), TRUE, 'postcodes_uk', 'output_areas', TRUE, TRUE)

rm(list = ls())
gc()