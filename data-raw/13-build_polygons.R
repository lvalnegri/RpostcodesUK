#############################################################################
# RpostcodesUK * Build Polygons for Postal Hierarchy, plus Neighbours table #
#############################################################################

Rfuns::load_pkgs('data.table', 'sf')
load_all()

# OA boundaries: EW 2021 ( +  = ), NS 2011 ( +  = )
message('Processing OA')
y1 <- qs::qread(file.path(bnduk_path, 's00', 'OA'), nthreads = 6) |> 
        subset(substr(OA, 1, 1) %in% c('N', 'S'))
y2 <- qs::qread(file.path(bnduk_path, 's00', 'OA21'), nthreads = 6) |> 
        setnames('OA21', 'OA')
y <- rbind(y1, y2) |> rmapshaper::ms_simplify(0.2, keep_shapes = TRUE) |> dplyr::arrange(OA) |> st_make_valid()
assign('OA', y)
save(list = 'OA', file = file.path('data', 'OA.rda'), version = 3, compress = 'gzip')

# Boundaries for Postal hierarchy
y <- merge(y, output_areas) |> st_transform(27700)
yn <- data.table()
for(x in c('PCS', 'PCD', 'PCT', 'PCA')){
    message('\nProcessing ', x)
    message(' - building boundaries')
    yx <- y |>
          rmapshaper::ms_dissolve(x) |> 
          dplyr::arrange_at(x) |> dplyr::select_at(x) |> 
          st_make_valid()
    message(' - saving')
    assign(x, yx |> st_transform(4326) |> st_make_valid())
    save(list = x, file = file.path('data', paste0(x, '.rda')), version = 3, compress = 'gzip')
    message(' - calculate neighbours')
    yn <- rbindlist(list( yn, data.table( x, st_intersection(yx, yx) |> st_drop_geometry() |> as.data.table() ) ), use.names = FALSE)
}
setnames(yn, c('type', 'idA', 'idB'))
yn <- yn[idA != idB]
save_dts_pkg(yn, 'neighbours', dbn = 'postcodes_uk')

message('DONE! Cleaning...')
rm(list = ls())
gc()
.rs.restartR()
