#' Regional file name for UPRN addresses
#'
#' Given the ONS code for an England Region, or an internal code for the Countries of Scotland and Wales, 
#' returns the name of the dataset for the UPRN PCUs and locations.
#'
#' @param x a string equal to one of the 11 Regions, see the column `RGN` in the `postal` dataset
#'
#' @return a string 
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @noRd
#' 
rgn_uprn <- \(x) paste0('U', ifelse(substr(x, 1, 1) == 'E', substring(x, nchar(x)), substr(x, 1, 1)))


#' Regional UPRN file name for postal hierarchy
#'
#' Given a Postcode Unit or a code for a Zone in the Postal Hierarchy (see either the table `pzones` or `postal`), 
#' returns the subset of all the locations of the Properties in that Zone.
#'
#' @param x a string equal to a Postcode unit or a zone in the *Postal* hierarchy
#' @param sf logical to indicate if the output should be a spatial `sf` object instead of a `data.table`
#'
#' @return a `data.table` or an `sf` object 
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom sf st_as_sf
#'
#' @export
#'
pc2uprn <- \(x, sf = TRUE){
    dtt <- getDTthreads()
    setDTthreads(2)
    x <- trimws(x)
    if(nchar(x) <= 2){
        if(nrow(pzones[type == 'PCA' & code == x]) == 0) stop('The provided code for a Postcode Area is not valid.')
        r <- rgn_uprn(unique(postal[PCA == x, RGN]))
        y <- postcodes[PCS %chin% postal[PCA == x, PCS], PCU]
    } else if(nchar(x) <= 4){
        if(nrow(pzones[type == 'PCD' & code == x]) == 0) stop('The provided code for a Postcode District is not valid.')
        r <- rgn_uprn(unique(postal[PCD == x, RGN]))
        y <- postcodes[PCS %chin% postal[PCD == x, PCS], PCU]
    } else if(nchar(x) <= 6){
        x <- gsub(' ', '', x)
        if(nrow(pzones[type == 'PCS' & code == x]) == 0) stop('The provided code for a Postcode Sector is not valid.')
        r <- rgn_uprn(unique(postal[PCS == x, RGN]))
        y <- postcodes[PCS == x, PCU]
    } else {
        y <- pcu_clean(x)
        if(is.null(y)) stop('The provided string does not correspond to a valid Postcode Unit format.')
        if(nrow(postcodes[PCU %chin% x]) == 0) stop('The provided Postcode Unit is not valid.')
        if(nrow(postcodes[is_active == 0 & PCU %chin% x]) > 0) stop('The provided Postcode Unit is terminated and has no Properties attached.')
        r <- rgn_uprn(postcodes[PCU == y, RGN])
    }
    y <- get(r)[PCU %in% y]
    if(sf) y <- y |> st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326)
    setDTthreads(dtt)
    y
}

