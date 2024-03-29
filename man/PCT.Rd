% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{PCT}
\alias{PCT}
\title{PCT}
\format{
An object of class \code{sf} (inherits from \code{data.frame}) with 1444 rows and 2 columns.
}
\usage{
PCT
}
\value{
A \code{sf} dataframe with only one \code{PCT} column for the corresponding \emph{Post Town} codes. Not
}
\description{
Digital Vector Boundaries in \code{sf} format and \emph{WGS84} CRS (\emph{EPSG} 4326) for the 1,443 \emph{Postcode Towns} in the UK.
}
\details{
Built by dissolving the \code{PCT} boundaries using the \code{lookups} table.
}
\note{
These are \emph{not} the official boundaries as released by Royal Mail with their \href{https://www.poweredbypaf.com/}{Postcode Address File (PAF)},
but only an approximation using the \emph{Output Areas}
and the \href{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)}{ONS Postcode Directory} as a basis.
}
\keyword{datasets}
