###################################
# RpostcodesUK * include datasets #
###################################

Rfuns::load_pkgs('data.table')
load_all()

# ancillary datasets
for(x in c('missing_oa', 'missing_pcs', 'pcs_regions', 'pcs_linkage', 'pcd_linkage', 'pca_totals')) 
    save_dts_pkg(fread(paste0('./data-raw/csv/', x, '.csv')), dbn = 'postcodes_uk', x)

save_dts_pkg(fread('./data-raw/csv/pcs_non_geo.csv', sep = '\n'), dbn = 'postcodes_uk', 'pcs_non_geo')

# OA boundaries: EW 2021 ( +  = ), NS 2011 ( +  = )
message('Processing OA')
y1 <- qs::qread(file.path(bnduk_path, 's00', 'OA'), nthreads = 6) |> 
        subset(substr(OA, 1, 1) %in% c('N', 'S'))
y2 <- qs::qread(file.path(bnduk_path, 's00', 'OA21'), nthreads = 6) |> 
        setnames('OA21', 'OA')
y <- rbind(y1, y2) |> rmapshaper::ms_simplify(0.2, keep_shapes = TRUE) |> dplyr::arrange(OA) |> st_make_valid()
assign('OA', y)
save(list = 'OA', file = file.path('data', 'OA.rda'), version = 3, compress = 'gzip')

# initial map
fn <- 'mps'
bbx <- st_bbox(OA) |> unname()
y <- leaflet() |>
        add_maptile(tiles.lst[[2]]) |> 
        fitBounds(bbx[1], bbx[2], bbx[3], bbx[4])
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# clean
rm(list = ls())
gc()