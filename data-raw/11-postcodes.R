#################################
# UK POSTCODES * 11 - POSTCODES #
#################################

Rfuns::load_pkgs('data.table', 'qs', 'rmapshaper', 'sf')

setDTthreads(10)

ons_id <- '489c152010a3425f80a71dc3663f73e1'
down <- FALSE

pc_path <- file.path(ext_path, 'uk', 'geography', 'postcodes')

if(down){
    message('\nDownloading ONSPD zip file...\n')
    tmpf <- tempfile()
    download.file(paste0('https://www.arcgis.com/sharing/rest/content/items/', ons_id, '/data'), destfile = tmpf)
    fname <- unzip(tmpf, list = TRUE)
    fname <- fname[order(fname$Length, decreasing = TRUE), 'Name'][1]
    message('Extracting csv file...')
    unzip(tmpf, files = fname, exdir = pc_path, junkpaths = TRUE)
    unlink(tmpf)
    system(paste0('mv ', pc_path, '/', basename(fname), ' ',  pc_path, '/ONSPD.csv'))
}

message('Loading ONSPD data...')
pc <- fread(
        file.path(pc_path, 'ONSPD.csv'), 
        select = c('pcd', 'osgrdind', 'doterm', 'usertype', 'long', 'lat', 'oa11', 'oa21', 'rgn', 'ctry', 'wz11'),
        col.names = c('PCU', 'osgrdind', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA11', 'OA', 'RGN', 'CTRY', 'WPZ'),
        na.string = '',
        key = 'PCU'
)
# >>>>>>>>> delete following when census 2021 results are published for every country <<<<<<<<<<<
pc[OA == '', OA := OA11]

message('Building lookalike tables as Table 1 and 3 in User Guide:')
message(' + Total dataset:')
rbind(pc[, .N, CTRY][order(CTRY)], pc[, .(CTRY = '==TOTAL==', .N)])
pc <- pc[!(CTRY %in% c('L93000001', 'M83000003'))]
message('Total UK: ', pc[, .N])
message(' + By user type (0-Small / 1-Large users)')
print(pc[, .N, usertype][order(usertype)])
message(' + By country and user type')
print(dcast(pc[, .N, .(usertype, CTRY)], CTRY~usertype))
message(' + By grid, country and user type, with count and percentage')
print(
    dcast(
        pc[, (Nct =.N),  .(usertype, CTRY)
           ][pc[, .N, .(osgrdind, usertype, CTRY)], on = c('usertype', 'CTRY')
             ][, pct := round(100 * N /V1, 2)][, V1 := NULL], 
        osgrdind~CTRY+usertype, 
        value.var = c('N', 'pct'), 
        fill = 0
    )
)

message('Deleting postcodes without grid reference (osgrdind == 9, deletes also GI/IM), then reorder by OA and PCU...')
pc <- pc[osgrdind < 9][, osgrdind := NULL][order(OA, PCU)]
message(' + Countries by usertypes (Table 3)...')
print(dcast(pc, CTRY~usertype))

message('Recoding "is_active" as binary 0/1 (Table 4)...')
pc[, is_active := ifelse(is.na(is_active), 1, 0)]
message(' + Countries by active vs. terminated...')
print(dcast(pc, CTRY~is_active))

message('Setting "is_active" = 1 for all postcodes in output areas that only include inactive pc...')
pc[!OA %in% unique(pc[is_active == 1, OA]), is_active := 1]
print(dcast(pc, CTRY~is_active))

message('Set PCD AB1/AB2/AB3 as terminated...')
pc[substr(PCU, 1, 4) %in% paste0('AB', 1:3, ' '), is_active := 0]

message('Calculate PC Sectors codes from postcodes...')
pc[is_active == 1, PCS := substr(PCU, 1, 5) ]

message('Deleting records associated witn non-geographic PC Sectors...')
message(' - Number of OAs before deletion: ', unique(pc[is_active == 1, .(OA)])[,.N])
ng <- read.csv('./data-raw/csv/pcs_non_geo.csv')
pc <- pc[!PCS %in% ng$PCS]
message(' - Number of 2011 OAs after deletion (UK): ', unique(pc[is_active == 1, .(OA11)])[,.N])
message(' - Number of 2021 OAs after deletion (ENG-WLS): ', unique(pc[is_active == 1, .(OA)])[,.N])

message('Fixing CTRY and RGN...')
pc[, CTRY := substr(CTRY, 1, 1)]
ctry <- data.table( 'old' = c('E', 'W', 'S', 'N'), 'CTRY' = c('ENG', 'WLS', 'SCO', 'NIE') )
pc <- ctry[pc, on = c(old = 'CTRY')][, old := NULL]
pc[substr(RGN, 1, 1) != 'E', RGN := paste0(CTRY, '_RGN')]

message('Saving a geographic WGS84 version...')
pcg <- pc[, .(PCU, x_lon, y_lat, is_active, PCS, OA, OA11, RGN, CTRY, WPZ)]
pcg <- st_as_sf(pcg, coords = c('x_lon', 'y_lat'), crs = 4326)
qsave(pcg, file.path(geouk_path, 'postcodes.wgs'), nthreads = 6)
message('Reprojecting using OSGB36 / British National Grid, epsg 27700...')
pcg <- pcg |> st_transform(27700)
qsave(pcg, file.path(geouk_path, 'postcodes.bng'), nthreads = 6)

message('Attach a postcode sector to missing OA11 (258)...')
bnd.oa <- qread(file.path(bnduk_path, 's00', 'OAgb'), nthreads = 6) |> setnames('OA', 'OA11')
oas <- fread('./data-raw/csv/OA_LSOA_MSOA.csv', select = 'OA', col.names = 'OA11')
yn11 <- oas[!OA11 %in% unique(pc[is_active == 1, OA11])][, .(OA = OA11)][order(OA)]
pcgn <- pcg |> dplyr::filter(is_active == 1)
y <- st_nearest_feature(bnd.oa |> subset(OA11 %in% yn11$OA), pcgn)
yn11 <- data.table(census = 2011, yn11, pcgn[y,] |> subset(select = PCS) |> st_drop_geometry())

message('Attach a postcode sector to missing OA21 (24)...')
bnd.oa <- qread(file.path(bnduk_path, 's00', 'OA21gb'), nthreads = 6) |> setnames('OA21', 'OA')
oas <- fread('./data-raw/csv/OA21_LSOA21_MSOA21.csv', select = 'OA21', col.names = 'OA')
yn21 <- oas[!OA %in% unique(pc[is_active == 1, OA])][order(OA)]
pcgn <- pcg |> dplyr::filter(is_active == 1)
y <- st_nearest_feature(bnd.oa |> subset(OA %in% yn21$OA), pcgn)
yn21 <- data.table(2021, yn21, pcgn[y,] |> subset(select = PCS) |> st_drop_geometry())
# >>>>>>>>> delete following when census 2021 results are published for every country <<<<<<<<<<<
yn21 <- rbindlist(list( yn21, yn11[substr(OA, 1, 1) %in% c('N', 'S')][, census := 2021] ), use.names = FALSE)
fwrite(rbindlist(list(yn11, yn21), use.names = FALSE)[order(census, OA)], './data-raw/csv/missing_oa.csv')

message('\nBuilding OA-PCS lookups...')
ypi <- pc[is_active == 1, .N, .(OA, PCS, RGN)][order(OA, -N)]
yp <- ypi[ypi[, .I[which.max(N)], OA]$V1][, N := NULL]
ypn <- unique(pc[is_active == 1 & !PCS %chin% unique(yp$PCS), .(OA, PCS)])
for(xp in unique(ypn$PCS)){
    for(xo in ypi[PCS == xp][order(-N)][, OA]){
        xop <- yp[OA == xo, PCS]
        xpo <- yp[PCS == xop]
        if(nrow(xpo) > 1){
            yp[OA == xo, PCS := xp]
            break
        }
    }
}
yp <- rbindlist(list( yp, unique(yp[PCS %chin% yn21$PCS, .(PCS, RGN)])[yn21, on = 'PCS'][, .(OA, PCS, RGN)] ))[order(OA)]
ypk <- yp[, .(OA, PCS)]
ypk[, PCD := gsub(' .*', '', substr(PCS, 1, 4)) ]
ypk[, PCA := sub('[0-9]', '', substr(PCS, 1, gregexpr("[[:digit:]]", PCS)[[1]][1] - 1) ) ]
fwrite(ypk[, .(OA, PCS)], './data-raw/csv/OA_PCS.csv')
fwrite(ypk[, .(OA, PCD)], './data-raw/csv/OA_PCD.csv')
fwrite(ypk[, .(OA, PCA)], './data-raw/csv/OA_PCA.csv')
fwrite(pc[is_active & !PCS %chin% unique(ypk$PCS)], './data-raw/csv/missing_pcs.csv')
fwrite(
    unique(pc[PCS %chin% pc[is_active == 1, .N, .(PCS, RGN)][, .N, PCS][ N > 1, PCS], .(PCS, RGN)][order(PCS)]),
    './data-raw/csv/pcs_countries.csv'
)

message('Adding correct order to PC Districts and save as csv file...')
pcd <- unique(ypk[, .(PCD)])[order(PCD)]
pcd[, `:=`( 
    PCDa = regmatches(pcd$PCD, regexpr('[a-zA-Z]+', pcd$PCD)), 
    PCDn = as.numeric(regmatches(pcd$PCD, regexpr('[0-9]+', pcd$PCD))) 
)]
pcd <- pcd[order(PCDa, PCDn)][, ordering := 1:.N][, .(PCD, ordering)]
fwrite(pcd, file.path('./data-raw/csv/PCD.csv'))

message('Adding correct order to PC Sectors and save as csv file...')
pcs <- unique(ypk[, .(PCD, PCS)])[order(PCS)]
pcs <- pcs[pcd, on = 'PCD']
pcs <- pcs[order(ordering, PCS)][, ordering := 1:.N][, .(PCS, ordering)]
fwrite(pcs, file.path('./data-raw/csv/PCS.csv'))

message('\nReworking PCU-PCS for entire postcodes...')
y <- rbindlist(list( pc[is_active == 1, .(PCU, PCS)], ypk[, .(OA, PCS)][pc[is_active == 0, .(PCU, OA)], on = 'OA'][, .(PCU, PCS)]))
pc <- y[pc[, PCS := NULL], on = 'PCU']

message('\nSaving a linkage between PCS/D old and new for terminated PCU...')
pcsa <- unique(ypk[, .(PCS.old = PCS, PCS)])
pcst <- pc[is_active == 0, .(PCU, PCS, PCS.old = gsub(' .*', '', substr(PCU, 1, 5)))
            ][!PCS.old %in% pcsa$PCS][, .N, .(PCS.old, PCS)][order(PCS.old, -N)]
pcst <- pcst[pcst[, .I[which.max(N)], PCS.old]$V1][, N := NULL]
fwrite(rbindlist(list( pcsa, pcst ))[order(PCS.old)], './data-raw/csv/pcs_linkage.csv')
pcda <- unique(ypk[, .(PCD.old = PCD, PCD)])
pcdt <- ypk[, .(OA, PCD)
           ][pc[is_active == 0, .(PCU, OA)], on = 'OA'
             ][, PCD.old := gsub(' .*', '', substr(PCU, 1, 4))
               ][!PCD.old %in% pcda$PCD][, .N, .(PCD.old, PCD)][order(PCD.old, -N)]
pcdt <- pcdt[pcdt[, .I[which.max(N)], PCD.old]$V1][, N := NULL]
fwrite(rbindlist(list( pcda, pcdt ))[order(PCD.old)], './data-raw/csv/pcd_linkage.csv')

message('Recoding char columns as factors...')
setcolorder(pc, c('PCU', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA', 'OA11',, 'PCS',, 'PCS',CTRY', 'WPZ'))'RGN', 'CTRY''RG'RGN', 'CTRY'
cols <- c('OA', 'OA11', 'PCS', 'PCS', 'CTRY', 'WPZ')'RGN', 'CTRY','RGN', 'CTRY',
pc[, (cols) := lapply(.SD, factor), .SDcols = cols]

message('Saving postcodes...')
setorderv(pc, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'), c(-1, rep(1, 5)))
save_dts_pkg(pc, 'postcodes', geouk_path, c('is_active', 'PCS'), TRUE, 'postcodes_uk', 'postcodes', TRUE, TRUE, TRUE)
file.copy('./data-raw/postcodes.csv.zip', './data-raw/csv/postcodes.csv.zip', overwrite = TRUE)
file.remove('./data-raw/postcodes.csv.zip')

message('Saving a lookalike Table 2 User Guide (remember that now postcodes without grid have been deleted)...')
pc <- ypk[pc[, PCS := NULL], on = 'OA']
pca <- rbindlist(list(
    pc[, .(
        PCD = uniqueN(PCD), 
        PCS = uniqueN(PCS), 
        live = sum(is_active), 
        terminated = sum(!is_active), 
        total = .N
    ), PCA][order(PCA)],
    pc[, .(
        PCA = 'TOTAL UK', 
        PCD = uniqueN(PCD), 
        PCS = uniqueN(PCS), 
        live = sum(is_active), 
        terminated = sum(!is_active), 
        total = .N
    )]        
))
fwrite(pca, './data-raw/csv/pca_totals.csv')

message('\n\nProcessing FULL postcodes dataset...')
message(' - Reading csv file...')
y <- fread(
    file.path(pc_path, 'ONSPD.csv'), 
    select = c(
       'pcd', 'lsoa11', 'msoa11', 'lsoa21', 'msoa21', 'oslaua', 'oscty', 'parish',
       'pcon', 'osward', 'ced', 'ttwa', 'bua11', 'buasd11', 'pfa', 'ccg', 'stp', 'nhser'
    ),
    col.names = c(
        'PCU', 'LSOA', 'MSOA', 'LSOA21', 'MSOA21', 'LAD', 'CTY', 'PAR',
        'PCON', 'WARD', 'CED', 'TTWA', 'BUA', 'BUAS', 'PFA', 'CCG', 'STP', 'NHSR'
    ),
    na.string = '',
    key = 'PCU'
)
y[y == ''] <- NA
y <- y[pc, on = 'PCU']
setcolorder(y, names(pc))

message(' - Saving as fst...')
setorderv(y, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'))
write_fst_idx('postcodes.full', c('is_active', 'PCS'), y, geouk_path)

message('DONE! Cleaning...')
rm(list = ls())
gc()
.rs.restartR()
