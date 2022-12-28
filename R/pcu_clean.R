#' Format string as a UK postcode
#' 
#' Check a character string is in a UK valid postcode format, then convert it to a 7-char format
#'
#' The UK postcode system is hierarchical, the top level being "Postcode Area" (PCA) identified by 1 or 2 alphabetical character.
#' The next level is the "Postcode District" (PCD), also commonly known as the "outcode", and can take on several different formats, and anywhere from 2 to 4 alphanumeric characters long.
#' Next comes the Postcode Sector" (PCS), always identified by a single number, then finally the "unit", always formed by two alphabetical characters.
#' The combination of "sector" and "unit" is often called "incode", which is always 1 numeric character followed by 2 alphabetical characters.
#'
#' @param x a string
#'
#' @return a 7-char string
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
pcu_clean <- function(x){
    x <- toupper(gsub('[[:punct:]| ]', '', x))
    if(!grepl('[[:digit:]][[:alpha:]][[:alpha:]]$', x)) return(NULL)
    if(grepl('^[0-9]', x)) return(NULL)
    if(nchar(x) < 5 | nchar(x) > 7) return(NULL)
    if(nchar(x) == 5) return(paste0( substr(x, 1, 2), '  ', substring(x, 3) ) )
    if(nchar(x) == 6) return(paste0( substr(x, 1, 3), ' ', substring(x, 4) ) )
    x
}


#' Clean Multiple strings for UK postcodes
#' 
#' Check multiple character strings are valid UK postcodes, converting all of them to a 7-char format
#'
#' @param x a character vector
#'
#' @return a character vector
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
pcus_clean <- function(x) sapply(x, pcu_clean) |> as.character()


#' Extract the coordinates of a postcode
#'
#' @param x a PostCode Unit in any valid form
#'
#' @return A character vector of two components: longitude and latitude 
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
pcu_coords <- \(x) postcodes[PCU == pcu_clean(x), .(x_lon, y_lat)] |> as.numeric()

