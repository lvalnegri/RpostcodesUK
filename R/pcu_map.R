#' Map a postcode unit
#'
#' Build a leaflet map for a postcode using its ONS centroid, the buffer from the union of its UPRNs, 
#' and the *voronoi* polygon 
#'
#' @param x a string 
#' @param bfr the value in meter for the buffer around the UPRNs 
#' @param cnc the value for the *concavity* of the "concave hull" around the UPRNs 
#'
#' @return a leaflet object
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import concaveman
#' @import leaflet
#' @import data.table
#' @import Rfuns
#' @import sf
#'
#' @export
#'
pcu_map <- \(x, bfr = 10, cnc = 2){
    x <- pcu_clean(x)
    if(is.null(x)) stop('The provided string is not a valid UK postcode.')
    pc <- postcodes[PCU == x]
    if(nrow(pc) == 0) stop('The provided postcode does not exist.')
    if(pc$is_active == 0) stop('The provided Postcode Unit is terminated. Its current Sector is ', pc$PCS, '.')
    uprn <- read_fst_idx(file.path(geouk_path, 'uprn'), x, c('x_lon', 'y_lat'))
    uprng <- uprn |> st_as_sf(coords =  c('x_lon', 'y_lat'), crs = 4326) |> st_transform(27700)
    leaflet() |> 
        addTiles() |> 
        addAwesomeMarkers(
            data = pc,
            group = 'Centroid',
            lng = ~x_lon,
            lat = ~y_lat,
            icon = makeAwesomeIcon()
        ) |> 
        addCircles(
            data = uprn,
            group = 'Addresses',
            lng = ~x_lon,
            lat = ~y_lat,
            radius = 2
        ) |> 
        addPolygons(
            data = uprng |> concaveman(cnc) |> st_zm() |> st_buffer(bfr) |> st_transform(4326),
            group = 'Buffer'
          
        ) |>
        addLayersControl(overlayGroups = c('Centroid', 'Addresses', 'Buffer'))
}
