##############################
# UK GEOGRAPHY * Postal Maps #
##############################

Rfuns::load_pkgs('data.table', 'leaflet')
load_all()

grps = c(
    paste0('Areas (PCA - ', nrow(PCA), ')'),
    paste0('Towns (PCT - ', formatC(nrow(PCT), big.mark = ','), ')'),
    paste0('Districts (PCD - ', formatC(nrow(PCD), big.mark = ','), ')'),
    paste0('Sectors (PCS - ', formatC(nrow(PCS), big.mark = ','), ')')
)
leaflet() |>
    addTiles() |>
    addPolygons(
        data = merge(PCA, pzones[type == 'PCA', .(PCA = code, name)]),
        group = grps[1],
        color = 'black',
        weight = 8,
        fillOpacity = 0,
        label = ~name
    ) |>
    addPolygons(
        data = merge(PCT, pzones[type == 'PCT', .(PCT = code, name)]),
        group = grps[2],
        color = 'magenta',
        weight = 6,
        fillOpacity = 0,
        label = ~name
    ) |>
    addPolygons(
        data = PCD,
        group = grps[3],
        color = 'blue',
        weight = 4,
        fillOpacity = 0,
        label = ~PCD
    ) |>
    addPolygons(
        data = PCS,
        group = grps[4],
        color = 'red',
        weight = 2,
        fillOpacity = 0.1,
        label = ~PCS
    ) |>
    addLayersControl(overlayGroups = grps) |> 
    htmlwidgets::saveWidget(paste0('./data-raw/maps/Postal.html'))

system(paste0('rm -r ./data-raw/maps/Postal_files'))
zip('./data-raw/maps/postal.zip', './data-raw/maps/Postal.html')
file.remove('./data-raw/maps/Postal.html')
