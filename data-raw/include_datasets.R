###############################################################################
# RpostcodesUK * Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
###############################################################################

Rfuns::load_pkgs('data.table')

ssave <- \(x){
    message(' - ', x)
    assign(x, fread(paste0('./data-raw/csv/', x, '.csv')))
    save(list = x, file = file.path('data', paste0(x, '.rda')), version = 3, compress = 'gzip')
}
for(fn in c('missing_oa', 'missing_pcs', 'pcs_regions', 'pcs_linkage', 'pcd_linkage', 'pca_totals')) ssave(fn)

fn <- 'pcs_non_geo'
assign(fn, fread('./data-raw/csv/pcs_non_geo.csv', sep = '\n'))
save(list = fn, file = 'data/pcs_non_geo.rda', version = 3, compress = 'gzip')

# output_areas
ys <- fread(paste0('./data-raw/csv/OA_PCS.csv'), key = 'OA')
yd <- fread(paste0('./data-raw/csv/OA_PCD.csv'), key = 'OA')
yt <- fread(paste0('./data-raw/csv/PCD_PCT.csv'))
ya <- fread(paste0('./data-raw/csv/OA_PCA.csv'), key = 'OA')
y <- ya[yt[, .(PCD, PCT)][yd[ys], on = 'PCD'], on = 'OA'] |> 
setorderv(y, c('PCA', 'PCT', 'PCD', 'PCS', 'OA'))
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
save_dts_pkg(y, 'pzones', geouk_path, 'type', TRUE, 'postcodes_uk', 'pzones', TRUE, TRUE)

# neighbours
fn <- 'neighbours'
assign(fn, data.table())
save(list = fn, file = './data/neighbours.rda', version = 3, compress = 'gzip')




rm(list = ls())
gc()