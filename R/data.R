#' @importFrom data.table data.table
NULL

#' @import sf
NULL

#' Postcodes
#'
#' A list of all 2,619,057 *Postcode Units* `PCU` in the UK (as of NOV-22: 1,737,670 active, 881,387 terminated), 
#' together with their geographic coordinates (CRS 4326, WGS84), and the corresponding *Output Area* `OA` and current *Postcode Sector* `PCS`.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{PCU}}{ Postcode Unit in 7-chars format (the column \code{PCD} in the \code{ONSPD} file):
#'                      - 2, 3 or 4 character \emph{outward code}, left aligned; 
#'                      - 3 character \emph{inward code}, right aligned;
#'                      - 3rd and 4th characters may be blank }
#'   \item{\code{is_active}}{ Flag that indicates if the corresponding unit postcode is currently active or terminated }
#'   \item{\code{usertype}}{ Shows whether the postcode is a small or large user: 0 = small; 1 = large }
#'   \item{\code{x_lon}}{ The longitude coordinate of the geometric centroid }
#'   \item{\code{y_lat}}{ The latitude coordinate of the geometric centroid }
#'   \item{\code{OA11}}{ Output Area ONS code as of Census 2011 (for all for Countries)}
#'   \item{\code{OA21}}{ Output Area ONS code as of Census 2021 (England and Wales Only)}
#'   \item{\code{OA}}{ Output Area ONS code: Census 2021 for England and Wales, Census 2011 for N.Ireland and Scotland}
#'   \item{\code{PCS}}{ Postcode Sector }
#'   \item{\code{PCD}}{ Postcode District }
#'   \item{\code{PCT}}{ Post Town }
#'   \item{\code{PCA}}{ Postcode Area }
#'   \item{\code{RGN}}{ Region ONS code (for England only; the other Regions assumed the following pseudo codes: 
#'                      NIE_RGN = Northern Ireland, SCO_RGN = Scotland, WLS_RGN = Wales) }
#'   \item{\code{CTRY}}{ Country 3-chars code: ENG = England, NIE = Northern Ireland, SCO = Scotland, WLS = Wales }
#' }
#'
#' @note The postcodes units included are only the ones with an associated grid reference, and not related to a *non-geographical* Postcode Sector.
#'
#' For further details, see the [ONS Geoportal](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(PRD_ONSPD))
#'
'postcodes'


#' pc_linkage
#'
#' A mapping between Postcode Sectors/Districts, related to terminated Units (but each table contains all records).
#'
#' @format A list including two data.table, \code{PCS} and \code{PCD}, with the following columns for \code{PCS}:
#' \describe{
#'   \item{\code{PCS.old}}{ The actual Postcode Sector corresponding to the rule }
#'   \item{\code{PCS}}{ The current Postcode Sector corresponding to its location }
#' }
#' and similarly for \code{PCD}.
#'
'pc_linkage'


## NEIGHBOURS ----------
#' Neighbours
#'
#' This dataset contains the *1st order neighbours* for all the Postcode Zones: `PCS`, `PCD`, `PCT`, `PCA`.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{ type }}{ The type of the Zone }
#'   \item{\code{ idA  }}{ The ONS identifier for a Zone }
#'   \item{\code{ idB  }}{ The ONS identifier for the first order neighbours of the Zone with code `idA`}
#' }
#'
'neighbours'


## OA ------------------
#' OA
#'
#' Digital Vector Boundaries in `sf` format and *WGS84* CRS (*EPSG* 4326) 
#' for all 188,880 *Output Areas* in England and Wales (**Census 2021**), 
#'  in Scotland (**Census 2011**), and N.Ireland  (**Census 2011**).
#'
#' @return A `sf` dataframe with only one `OA` column for the corresponding *ONS* codes.
#'
#' For further details see \url{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-modified&tags=all(BDY_OA)}.
#'
'OA'

## PCS ----------------
#' PCS
#'
#' Digital Vector Boundaries in `sf` format and *WGS84* CRS (*EPSG* 4326) for the (approximate) 9450 *Postcode Sectors* in the UK.
#'
#' Built by dissolving the `OA` boundaries using the `lookups` table.
#' 
#' @return A `sf` dataframe with only one `PCS` column for the corresponding *Potscode Sector* codes.
#'
#' @note These are *not* the official boundaries as released by Royal Mail with their [Postcode Address File (PAF)](https://www.poweredbypaf.com/), 
#'       but only an approximation using the *Output Areas* 
#'       and the [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)) as a basis.
#'
'PCS'

## PCD ----------------
#' PCD
#'
#' Digital Vector Boundaries in `sf` format and *WGS84* CRS (*EPSG* 4326) for the *Postcode Districts* in the UK.
#'
#' Built by dissolving the `PCS` boundaries using the `lookups` table.
#' 
#' @return A `sf` dataframe with only one `PCD` column for the corresponding *Postcode District* codes.
#'
#' @note These are *not* the official boundaries as released by Royal Mail with their [Postcode Address File (PAF)](https://www.poweredbypaf.com/), 
#'       but only an approximation using the *Output Areas* 
#'       and the [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)) as a basis.
#'
'PCD'

## PCT ----------------
#' PCT
#'
#' Digital Vector Boundaries in `sf` format and *WGS84* CRS (*EPSG* 4326) for the 1,443 *Postcode Towns* in the UK.
#'
#' Built by dissolving the `PCT` boundaries using the `lookups` table.
#' 
#' @return A `sf` dataframe with only one `PCT` column for the corresponding *Post Town* codes. Not
#'
#' @note These are *not* the official boundaries as released by Royal Mail with their [Postcode Address File (PAF)](https://www.poweredbypaf.com/), 
#'       but only an approximation using the *Output Areas* 
#'       and the [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)) as a basis.
#'
'PCT'

## PCA ----------------
#' PCA
#'
#' Digital Vector Boundaries in `sf` format and *WGS84* CRS (*EPSG* 4326) for the 121 *Postcode Areas* in the UK.
#'
#' Built by dissolving the `PCT` boundaries using the `lookups` table.
#' 
#' @return A `sf` dataframe with only one `PCA` column for the corresponding *Postcode Area* codes.
#'
#' @note These are *not* the official boundaries as released by Royal Mail with their [Postcode Address File (PAF)](https://www.poweredbypaf.com/), 
#'       but only an approximation using the *Output Areas* 
#'       and the [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)) as a basis.
#'
'PCA'
