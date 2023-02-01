####################################
# UK GEOGRAPHY * 16 - Postal Towns #
####################################
# to check manually: 
# - CM92: Harlow, Pinnacles; 
# - CM98, CM99: Chelmsford
# - EC2N, EC2R, EC3A, EC3M, EC3V, EC4N, EC4R: EC London
# - PA62, PA63, PA68, PA69, PA74: Isle Of Mull
# - PH42: Isle Of Eigg
# - PH43: Isle Of Rum
# - PH44: Isle Of Canna
# - WC2R:	WC London

Rfuns::load_pkgs('data.table')

ya <- fread('./data-raw/csv/PCA.csv')
y <- rvest::read_html('https://en.wikipedia.org/wiki/List_of_post_towns_in_the_United_Kingdom')
y <- data.table(
        PCA = y |> rvest::html_elements('td:nth-child(1)') |> rvest::html_text() |> gsub('\n', '', x = _),
        PCT = y |> rvest::html_elements('td~ td+ td') |> rvest::html_text() |> gsub('\n', '', x = _)
)
y <- y[ya, on = 'PCA']
y <- y[, .(PCT = unlist(tstrsplit(PCT, ',', type.convert = TRUE))), PCA ]
y[, PCT := trimws(gsub('(.*,{0,1})\\[Note [0-9]{1,2}\\](.*)', '\\1\\2', PCT))]
fwrite(y, './data-raw/wiki/PCA_PCT.csv')

yw <- data.table()
for(idx in 1:nrow(ya)){
    message(' - Processing: ', ya[idx, name])
    if(ya[idx, PCA] %in% c('BT', 'EC', 'EH', 'IG', 'NN')){
        xp <- '//*[@id="mw-content-text"]/div[1]/table[3]'
    } else {
        xp <- '//*[@id="mw-content-text"]/div/table[2]'
    }
    yt <- data.table(
            htmltab::htmltab(
                paste0(file.path('http://en.wikipedia.org/wiki', ya[idx, PCA]), '_postcode_area'), 
                xp,
                rm_nodata_cols = FALSE
            )
    )
    if(ya[idx, PCA] %in% c('BT', 'EH'))
        yt <- rbindlist(list(
                  yt,
                  data.table(
                      htmltab::htmltab(
                          paste0(file.path('http://en.wikipedia.org/wiki', ya[idx, PCA]), '_postcode_area'), 
                          '//*[@id="mw-content-text"]/div[1]/table[2]',
                          rm_nodata_cols = FALSE
                      )
                  )
        ))
    setnames(yt, c('PCD', 'PCT', 'XC', 'LAD'))
    ys <- 'non-geo|special|boxes|office|process'
    yt <- yt[!grepl('recoded', tolower(PCT))]
    yt <- yt[!grepl(ys, tolower(LAD))]
    yt <- yt[!grepl(ys, tolower(XC))]
    yw <- rbindlist(list(yw, yt[, 1:2]))
    Sys.sleep(0.5)
}
yw <- Rfuns::capitalize(yw, 'PCT')
fwrite(yw, './data-raw/wiki/PCD_PCT.csv')

message('DONE! Cleaning...')
rm(list = ls())
gc()
.rs.restartR()
