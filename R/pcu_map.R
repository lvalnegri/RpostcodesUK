#' Map a Postcode Unit or a Zone
#'
#' Build a leaflet map for a Postcode Unit or Zone using a *concave* or *convex hull* around its Properties. 
#'
#' @param x a string representing a Postcode Unit or Zone 
#' @param bfr the value in meter for the buffer around the group of Properties included in the Unit or Zone
#' @param concave logical to indicate a *concave hull* instead of the more classic *convex hull*
#' @param cnc_val the value for the *concavity* of the *concave hull* around the UPRNs 
#'
#' @return a leaflet object
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @import concaveman
#' @import leaflet
#' @import sf
#'
#' @export
#'
pcu_map <- \(x, bfr = 10, concave = TRUE, cnc_val = 2){
    x <- pcu_clean(x)
    if(is.null(x)) stop('The provided string is not a valid UK postcode.')
    pc <- postcodes[PCU == x]
    if(nrow(pc) == 0) stop('The provided postcode does not exist.')
    if(pc$is_active == 0) stop('The provided Postcode Unit is terminated. Its current Sector is ', pc$PCS, '.')
    uprn <- read_fst_idx(file.path(geouk_path, 'uprn'), x, c('x_lon', 'y_lat'))
    uprng <- uprn |> st_as_sf(coords =  c('x_lon', 'y_lat'), crs = 4326) |> st_transform(27700)
    
    if(concave){
      
    } else {
      
    }
    
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

# concave: mp |> addPolygons(data = pc2uprn('SE171') |> concaveman::concaveman(cnc_val) |> st_transform(27700) |> st_buffer(bfr) |> st_transform(4326))
# convex:  mp |> addPolygons(data = pc2uprn('SE171') |> st_transform(27700) |> st_union() |> st_buffer(bfr) |> sf::st_convex_hull() |> st_transform(4326))
