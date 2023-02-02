#' Map Tiles
#' 
#' List of background tiles for `leaflet` maps
#'
#' @references \url{https://leaflet-extras.github.io/leaflet-providers/preview/}. 
#' 
#' To work correctly, needs to be paired with `add_maptile`.
#'
#' @export
#' 
tiles.lst <- list(
    'Google Maps Standard' = 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&hl=it',
    'Google Maps Satellite' = 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}&hl=it',
    'Google Maps Terreno' = 'https://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}&hl=it',
    'Google Maps Alternativo' = 'https://{s}.google.com/vt/lyrs=r&x={x}&y={y}&z={z}&hl=it',
    'Google Maps Solo Strade' = 'https://{s}.google.com/vt/lyrs=h&x={x}&y={y}&z={z}&hl=it',
    'OSM Mapnik' = 'OpenStreetMap.Mapnik',
    'OSM HOT' = 'OpenStreetMap.HOT',
    'OSM Topo' = 'OpenTopoMap',
    'OSM Cycle' = 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
    'Stamen Toner' = 'Stamen.Toner',
    'Stamen Toner Lite' = 'Stamen.TonerLite',
    'Stamen Toner Background' = 'Stamen.TonerBackground',
    'Stamen Terrain' = 'Stamen.Terrain',
    'Stamen Watercolor' = 'Stamen.Watercolor',
    'Esri Street' = 'Esri.WorldStreetMap',
    'Esri Topo' = 'Esri.WorldTopoMap',
    'Esri Imagery' = 'Esri.WorldImagery',
    'CartoDB Voyager' = 'CartoDB.Voyager',
    'CartoDB Positron' = 'CartoDB.Positron',
    'CartoDB Dark Matter' = 'CartoDB.DarkMatter',
    'OPNVKarte' = 'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png',
    'Hike Bike' = 'HikeBike.HikeBike',
    'Mtb' = 'MtbMap'
)


#' Add Map Tiles
#' 
#' Add a background layer to a `leaflet` map
#'
#' @param m   a `leaflet` object
#' @param x   text or url description of the required map tile (see `tiles.lst`)
#' @param grp an optional group name for the layer
#'
#' @return A `leaflet` object
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom leaflet addProviderTiles addTiles
#' 
#' @export
#'
add_maptile <- function(m, x, grp = NULL){
    switch(stringr::str_extract(x, 'google|memomaps|cycl'),
        'google' = m |> addTiles(
                            urlTemplate = x, 
                            attribution = 'Map data &copy; <a href="https://maps.google.com/">Google Maps</a>', 
                            options = tileOptions(subdomains = c('mt0', 'mt1', 'mt2', 'mt3'), useCache = TRUE, crossOrigin = TRUE),
                            group = grp
                ),
        'memomaps' = m |> addTiles(
                        urlTemplate = x, 
                        attribution = 'Map <a href="https://memomaps.de/">memomaps.de</a> <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                        options = tileOptions(useCache = TRUE, crossOrigin = TRUE),
                        group = grp    
                ),
        'cycl' = m |> addTiles(
                        urlTemplate = 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png', 
                        attribution = '<a href="https://github.com/cyclosm/cyclosm-cartocss-style/releases" title="CyclOSM - Open Bicycle render">CyclOSM</a> | Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                        options = tileOptions(useCache = TRUE, crossOrigin = TRUE),
                        group = grp
                ),
        `NA` = m |> addProviderTiles(x, group = grp, options = providerTileOptions(useCache = TRUE, crossOrigin = TRUE))
    )
}

