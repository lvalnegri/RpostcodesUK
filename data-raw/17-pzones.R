##########################################
# RpostcodesUK * Create Dataset `pzones` #
##########################################

Rfuns::load_pkgs('data.table', 'sf')
load_all()

# calculate OAs for facebook population grid. Needs to be run only once to build the lookups
# yo <- qs::qread(file.path(bnduk_path, 's00', 'OAgb'))
# fbx <- fst::read_fst(file.path(datauk_path, 'fb_gridpop', 'total'), columns = c('x_lon', 'y_lat', 'pop'), as.data.table = TRUE) |>
#             st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326) |>
#             st_transform(27700) |>
#             st_make_valid() |>
#             st_join(yo, join = st_within)
# fbx <- data.table(
#             fbx |> st_drop_geometry(),
#             fbx |> st_transform(4326) |> st_coordinates() |> st_drop_geometry()
#         ) |> setnames(c('pop', 'OA', 'x_lon', 'y_lat'))
# fbx <- fbx[!is.na(OA)][substr(OA, 1, 1) %in% c('E', 'W')]
# setorder(fbx, 'OA')
# qs::qsave(fbx, './data-raw/qs/gridpop')

# bind codes and names with parents
ys <- fread(paste0('./data-raw/csv/PCS.csv'))
yd <- fread(paste0('./data-raw/csv/PCD.csv'))
yt <- fread(paste0('./data-raw/csv/PCT.csv'))
ya <- fread(paste0('./data-raw/csv/PCA.csv'))
yo <- fread('./data-raw/csv/output_areas.csv')
yp <- postcodes[is_active == 1, .(PCU, PCS, RGN, CTRY)][unique(yo[, .(PCS, PCD, PCT, PCA)]), on = 'PCS']
ys <- ys[, .(type = 'PCS', code = PCS, name = PCS, ordering)
         ][unique(yo[, .(code = PCS, parent = PCD)]), on = 'code'
           ][yp[, .N, .(PCS, country = CTRY)][order(PCS, -N)][, .SD[1], PCS][, N := NULL], on = c(code = 'PCS')]
yd <- yd[, .('PCD', PCD, PCD, ordering)
         ][unique(yo[, .(PCD, PCT)]), on = 'PCD'
           ][yp[, .N, .(PCD, CTRY)][order(PCD, -N)][, .SD[1], PCD][, N := NULL], on = 'PCD']
yt <- yt[, .('PCT', PCT, name, ordering)
         ][unique(yo[, .(PCT, PCA)]), on = 'PCT'
           ][yp[, .N, .(PCT, CTRY)][order(PCT, -N)][, .SD[1], PCT][, N := NULL], on = 'PCT']
ya <- ya[, .('PCA', PCA, name, 1:.N)
         ][yp[, .N, .(PCA, RGN)][order(PCA, -N)][, .SD[1], PCA][, N := NULL], on = 'PCA'
           ][yp[, .N, .(PCA, CTRY)][order(PCA, -N)][, .SD[1], PCA][, N := NULL], on = 'PCA']

# calculate geographic measure
fbx <- qs::qread('./data-raw/qs/gridpop')
y <- rbindlist(
        lapply(
            c('PCS', 'PCD', 'PCT', 'PCA'),
            \(x){
                message('Processing ', x)
                yb <- get(x) |> st_transform(27700)
                ym <- data.table(
                        type = x,
                        yb |> st_drop_geometry() |> setnames('id'),
                        area = yb |> st_area() |> as.numeric(),
                        perimeter = yb |> lwgeom::st_perimeter() |> as.numeric(),
                        yb |> st_centroid() |> st_transform(4326) |> st_coordinates() |> as.data.table() |> setnames(c('x_lon', 'y_lat')),
                        rbindlist( polylabelr::poi(yb) ) |> st_as_sf(coords = c('x', 'y'), crs = 27700) |> 
                            st_transform(4326) |> 
                            st_coordinates() |> 
                            st_drop_geometry() |> 
                            as.data.table() |> 
                            setnames(c('px_lon', 'py_lat')),
                        sapply(
                            1:nrow(yb), 
                            \(x) yb[x,] |> st_transform(4326) |> st_bbox()
                        ) |> matrix(ncol = 4, byrow = TRUE) |> as.data.table() |> setnames(c('bb_xmin', 'bb_ymin', 'bb_xmax', 'bb_ymax'))
                )
                yw <- yo[, .(OA, get(x))][fbx, on = 'OA'][, OA := NULL]
                yw <- yw[, .( weighted.mean(x_lon, pop), weighted.mean(y_lat, pop) ), V2] |> setnames(c('id', 'wx_lon', 'wy_lat'))
                yw[ym, on = 'id']
            }
        ), use.names = FALSE
)
y <- rbindlist(list(ys, yd, yt, ya), use.names = FALSE)[y, on = c('type', code = 'id')]
setcolorder(y, c('type', 'code', 'name', 'parent', 'country', 'ordering', 'area', 'perimeter', 'x_lon', 'y_lat'))
setorderv(y, c(c('type', 'code')))

save_dts_pkg(y, 'pzones', geouk_path, 'type', TRUE, 'postcodes_uk', 'pzones', TRUE, TRUE)

# create`postal` table
y1 <- y[type == 'PCS', .(PCS = code, PCD = parent)]
y2 <- y[type == 'PCD', .(PCD = code, PCT = parent)]
y3 <- y[type == 'PCT', .(PCT = code, PCA = parent)][!is.na(PCT)]
y4 <- y[type == 'PCA', .(PCA = code, RGN = as.character(parent))]
save_dts_pkg(y1[y2, on = 'PCD'][y3, on = 'PCT'][y4, on = 'PCA'][order(PCS)], 'postal', as_rdb = TRUE, dbn = 'postcodes_uk')

# clean
rm(list = ls())
gc()
