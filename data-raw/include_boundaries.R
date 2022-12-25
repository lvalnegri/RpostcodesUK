#####################################
# RpostcodesUK * Include Boundaries #
#####################################

# OA boundaries: EW 2021 ( +  = ), NS 2011 ( +  = )
y1 <- qs::qread(file.path(Rfuns::bnduk_path, 's00', 'OA'), nthreads = 6) |> 
        subset(substr(OA, 1, 1) %in% c('N', 'S'))
y2 <- qs::qread(file.path(Rfuns::bnduk_path, 's00', 'OA21'), nthreads = 6) |> 
        setnames('OA21', 'OA')
y <- rbind(y1, y2) |> rmapshaper::ms_simplify(0.2, keep_shapes = TRUE)
assign('OA', y)
save(list = 'OA', file = file.path('data', 'OA.rda'), version = 3, compress = 'gzip')

ys <- fread('./data-raw/csv/OA_PCS.csv', key = 'OA')
yd <- fread('./data-raw/csv/OA_PCD.csv', key = 'OA')
yt <- fread('./data-raw/csv/PCD_PCT.csv')
ya <- fread('./data-raw/csv/OA_PCA.csv', key = 'OA')
ys[yd[ya]]

# PCS as dissolving of OA
yt <- y |> 
        merge() |> 
        rmapshaper::ms_dissolve('PCS') |> 
        dplyr::arrange(PCS)
assign('PCS', yt)
save(list = 'PCS', file = file.path('data', 'PCS.rda'), version = 3, compress = 'gzip')

# PCD as dissolving of PCS
yt <- y |> 
        merge(fread('./data-raw/csv/OA_PCD.csv')) |> 
        merge(fread('./data-raw/csv/OA_PCD.csv')) |> 
        rmapshaper::ms_dissolve('PCD')
assign('PCD', yt)
save(list = 'PCD', file = file.path('data', 'PCD.rda'), version = 3, compress = 'gzip')

# PCS as dissolving of PCD
yt <- y |> 
        merge(fread('./data-raw/csv/PCD_PCT.csv')) |> 
        rmapshaper::ms_dissolve('PCT') |> 
        dplyr::arrange(PCS)
assign('PCT', yt)
save(list = 'PCT', file = file.path('data', 'PCT.rda'), version = 3, compress = 'gzip')

# PCA as dissolving of OA
yt <- y |> 
        merge(fread('./data-raw/csv/OA_PCA.csv')) |> 
        rmapshaper::ms_dissolve('PCA')
assign('PCS', yt)
save(list = 'PCS', file = file.path('data', 'PCS.rda'), version = 3, compress = 'gzip')

