#####################################
# RpostcodesUK * Include Boundaries #
#####################################

Rfuns::load_pkgs('data.table')
load_all()

# OA boundaries: EW 2021 ( +  = ), NS 2011 ( +  = )
y1 <- qs::qread(file.path(Rfuns::bnduk_path, 's00', 'OA'), nthreads = 6) |> 
        subset(substr(OA, 1, 1) %in% c('N', 'S'))
y2 <- qs::qread(file.path(Rfuns::bnduk_path, 's00', 'OA21'), nthreads = 6) |> 
        setnames('OA21', 'OA')
y <- rbind(y1, y2) |> rmapshaper::ms_simplify(0.2, keep_shapes = TRUE) |> dplyr::arrange(OA)
assign('OA', y)
save(list = 'OA', file = file.path('data', 'OA.rda'), version = 3, compress = 'gzip')

# Boundaries for Postal hierarchy
y <- merge(y, output_areas)
for(x in c('PCS', 'PCD', 'PCT', 'PCA')){
    message('Processing ', x)
    assign(x, y |> rmapshaper::ms_dissolve(x) |> dplyr::arrange_at(x) |> dplyr::select_at(x))
    save(list = x, file = file.path('data', paste0(x, '.rda')), version = 3, compress = 'gzip')
}
