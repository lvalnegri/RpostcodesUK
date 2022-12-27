########################################
# UK POSTCODES * 16 - UPRN AddressBase #
########################################

Rfuns::load_pkgs('data.table', 'fst', 'sf')
setDTthreads(getDTthreads() - 1)

down <- FALSE
pc_path <- file.path(ext_path, 'uk', 'geography', 'postcodes')

if(down){
    message('\nDownloading ONSUD zip file...\n')
    ons_id <- '5276df7d94d64bbabb7822bee9645dd3'
    tmpf <- tempfile()
    tmpd <- tempdir()
    download.file(paste0('https://www.arcgis.com/sharing/rest/content/items/', ons_id, '/data'), destfile = tmpf)
    fnames <- grep('ONSUD.*\\.csv$', unzip(tmpf, list = TRUE)$Name, value = TRUE)
    message('Extracting and merging csv files...')
    y <- rbindlist(lapply(
            grep('ONSUD.*\\.csv$', unzip(tmpf, list = TRUE)$Name, value = TRUE),
            \(x){
                unzip(tmpf, x, exdir = tmpd, junkpaths = TRUE)
                fread(file.path(tmpd, gsub('.*\\/(.*)', '\\1', x)))
            }
    ))
    unlink(tmpf)
    unlink(tmpd)
    fwrite(y, file.path(pc_path, 'ONSUD.csv'))
}

message('Loading ONSUD data...')
y <- fread( file.path(pc_path, 'ONSUD.csv'), select = c('GRIDGB1E', 'GRIDGB1N', 'PCDS'), col.names = c('Easting', 'Northing', 'PCU'))
message('Cleaning PCUs...')
y <- y[PCU != '']
dd_clean_pcu(y)
setorder(y, 'PCU')
message('Changing CRS...')
y <- y |> 
      st_as_sf(coords = c('Easting', 'Northing'), crs = 27700) |> 
      st_transform(4326)
message('Extracting coordinates...')
y <- data.table( y |> st_drop_geometry(), y |> st_coordinates() ) |> setnames(c('X', 'Y'), c('x_lon', 'y_lat'))
y <- y[, .N, .(PCU, x_lon, y_lat)]
y[, `:=`( x_lon = round(x_lon, 7), y_lat = round(y_lat, 7) )]
message('Saving final table...')
write_fst_idx('uprn', 'PCU', y, geouk_path)

rm(list = ls())
gc()
