###############################################################################
# UK GEOGRAPHY * 11 - Post Districts (PCD) and Towns (PCT) + Non-Geographical #
###############################################################################

Rfuns::load_pkgs('data.table')

message('- download Post Towns')
y <- rvest::read_html('https://en.wikipedia.org/wiki/List_of_post_towns_in_the_United_Kingdom') |> 
        rvest::html_elements('.toccolours td') |> 
        rvest::html_text() |> 
        matrix(ncol = 3, byrow = TRUE) |> 
        as.data.table() |> 
        setnames(c('PCA', 'PCAn', 'PCTw'))
y <- y[, .(PCTw = unlist(tstrsplit(PCTw, ',', type.convert = TRUE))), PCA ]
y[, `:=`( PCA = gsub('\n', '', PCA), PCTw = trimws(gsub('(.*,{0,1})\\[Note [0-9]{1,2}\\](.*)', '\\1\\2', PCTw)) )]
y <- y[!PCA %in% c('BF', 'GY', 'IM', 'JE')]
y[, PCTn := stringr::str_to_title(PCTw)]
yt <- rbindlist(list(
        y[grepl('\\(', PCTn)][order(PCTn, PCA)][, .(PCA, PCTw = PCTn, PCTn = paste0(gsub('(.*\\().*$', '\\1', PCTn), PCA, ')'))],
        y[grepl('^London$', PCTn)][order(PCA)][, .(PCA, PCTw = 'London', PCTn = paste0('London (', PCA, ')'))]
))
y <- rbindlist(list( y[!PCTn %in% yt$PCTw], yt ))[order(PCA, PCTn)]
fwrite(y, './data-raw/wiki/PCT_PCA.csv')
yt[, PCTo := gsub('(.*) \\(.*', '\\1', PCTn)]
fwrite(yt[order(PCTn)], './data-raw/wiki/PCT_rename.csv')

message('- download Post Districts')
yw <- rbindlist(lapply(
            sort(unique(y$PCA)),
            \(z){
                message(' - Processing: ', z)
                if(z %in% c('BT', 'EC', 'EH', 'NN')){ # Check if `IG` should be included
                    xp <- '//*[@id="mw-content-text"]/div[1]/table[3]'
                } else {
                    xp <- '//*[@id="mw-content-text"]/div/table[2]'
                }
                yt <- data.table(
                        htmltab::htmltab(
                            paste0(file.path('https://en.wikipedia.org/wiki', z), '_postcode_area'), 
                            xp,
                            rm_nodata_cols = FALSE
                        )
                )
                if(z %in% c('BT', 'EH'))
                    yt <- rbindlist(list(
                              yt,
                              data.table(
                                  htmltab::htmltab(
                                      paste0(file.path('https://en.wikipedia.org/wiki', z), '_postcode_area'), 
                                      '//*[@id="mw-content-text"]/div[1]/table[2]',
                                      rm_nodata_cols = FALSE
                                  )
                              )
                    ))
                yt
            }
), use.names = FALSE) |> setnames(c('PCD', 'PCTn', 'PCDd', 'LAD'))

message('- extract non geographical')
yw <- yw[!grepl('\\(', PCD)]
yw <- yw[!grepl('recoded', tolower(PCTn))]
ng.lbl <- 'non-geo|special|po box|boxes|process'
ng.pcd <- yw[grepl(ng.lbl, tolower(PCDd)) | grepl(ng.lbl, tolower(LAD)), .(PCD)]
ng.pcd <- ng.pcd[!PCD %in% yw[PCD %in% ng.pcd$PCD, .N, PCD][N > 1, PCD]]
ng.pcd <- rbindlist(list( ng.pcd, data.table(PCD = c('M61', 'M99', 'YO90')) ))
yw <- yw[!PCD %in% ng.pcd$PCD]
fwrite(ng.pcd, './data-raw/csv/pcd_non_geo.csv')

message('- drop duplicated non true non-geographical')
yw <- yw[!yw[, .I[LAD %like% 'non-geo' & (is.na(PCDd) | PCDd == 'PO Boxes')]]]

message('- unite share PCD by different PCT')
yw <- capitalize(yw, 'PCTn', as_factor = FALSE)
ywd <- yw[PCD %in% yw[, .N, PCD][N > 1, PCD]]
ywd <- ywd[, .(PCTn = paste(PCTn, collapse = '; ')), PCD][
          ywd[, .(PCDd = paste(PCDd, collapse = ', ')), PCD], on = 'PCD'][
              ywd[, .(LAD = head(LAD, 1)), PCD], on = 'PCD']
yw <- rbindlist(list( yw[!PCD %in% ywd$PCD], ywd ))

# Check PCD duplicates (==> PCT_joined): fix current, add new
yj <- fread('./data-raw/wiki/PCT_joined.csv')
yj <- yw[PCD %in% yw[,.N,PCD][N>1, PCD], .(PCD, PCTn)][yj,on = 'PCTn']
View(yj[yw[PCD %in% yw[,.N,PCD][N>1, PCD], .(PCD, PCTn)], on = 'PCTn'][order(PCTj)])
# ... check which must be done for yw and/or PCT_joined (==> https://en.wikipedia.org/wiki/File:XX_postcode_area_map.svg )
# ===================
yw[PCD == 'BR1', PCTn := 'Bromley North']
yw[PCD == 'SY24' & PCTn == 'Talybont', PCTn := 'Talybont (SY)']
yw[PCD == 'IP22', PCTn := 'Diss West']
yw[PCD == 'IP23', PCTn := 'Eye West']
yw[PCD == 'L20', PCDd := 'Bootle, Orrell, Kirkdale (Liverpool)']
yw[PCD == 'PO12', PCDd := gsub('Gosport', 'Gosport South', PCDd)]
yw[PCDd == 'Aberdyfi', PCTn := 'Aberdyfi']
yw[PCTn == 'St Albans', PCTn := 'St. Albans']
# ===================
View(yj[yw[PCD %in% yw[,.N,PCD][N>1, PCD], .(PCD, PCTn)], on = 'PCTn'][order(PCTj)])

yw <- rbindlist(list(
        yw,
        data.table( 
            PCD  = 'M3', 
            PCTn  = 'Manchester-Salford (Parts)',
            PCDd = 'Manchester: City Centre, Deansgate, Castlefield; Salford: Blackfriars, Greengate, Trinity',
            LAD  = 'Manchester, Salford'
        )
)) |> setorder('PCD') |> setcolorder(c('PCD', 'PCDd'))

message('- rename duplicated Town Names in different Areas')
yw[, PCA := gsub('([A-Z]+).*', '\\1', PCD)]
yw[PCTn %in% yt$PCTo, PCTn := paste0(PCTn, ' (', PCA, ')')]
# Cross check these two views before proceeding any further
View(yw[!PCTn %in% y$PCTn])
View(y[!PCTn %in% yw$PCTn])

message('- create Postal Towns PCT table')
pct <- unique(yw[, .(PCTn, PCA)])[order(PCA, PCTn)][, PCT := paste0('PCT_', str_add_char(PCA, 2, '_', 'r'), '_', str_add_char(1:.N, 2)), PCA]
setcolorder(pct, c('PCT', 'PCTn'))
fwrite(pct, './data-raw/csv/PCT.csv')

message('- create Postal Districts PCD table')
pcd <- yw[, .(PCD, PCDd, PCTn)][pct, on = 'PCTn'][, PCTn := NULL]
pcd <- pcd[, PCDn := as.numeric(regmatches(PCD, regexpr('[0-9]+', PCD)))][order(PCA, PCDn)][, ordering := 1:.N][, PCDn := NULL]
fwrite(yw, './data-raw/csv/PCD.csv')

message('DONE! Cleaning environment...')
rm(list = ls())
gc()
.rs.restartR()
