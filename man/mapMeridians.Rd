% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map.R
\name{mapMeridians}
\alias{mapMeridians}
\title{Add Meridians on a Map [DEPRECATED]}
\usage{
mapMeridians(latitude, lty = "solid", lwd = 0.5 * par("lwd"),
  col = "darkgray", ...)
}
\arguments{
\item{latitude}{either a logical value indicating whether to draw
a meridian grid, or a vector of latitudes at which to draw meridians.}

\item{lty}{line type.}

\item{lwd}{line width.}

\item{col}{line colour.}

\item{...}{optional arguments passed to \code{\link{lines}}.}
}
\description{
Plot meridians (lines of constant latitude) on an existing map.
\strong{Warning:} this function will be removed soon;
see \link{oce-deprecated}.
}
\details{
Meridians that will not fit in the plotting space are ignored.
}
\section{Bugs}{

This should use \code{\link{approx}} to fill in multiple
segments within the line, so that e.g. great circle lines will be curved.
}
\examples{
\dontrun{
library(oce)
data(coastlineWorld)
longitude <- coastlineWorld[['longitude']]
latitude <- coastlineWorld[['latitude']]
mapPlot(longitude, latitude, type='l',
longitudelim=c(-130,-50), latitudelim=c(30,60),
proj="polyconic", orientation=c(90, -90, 0))
mapMeridians()
}

}
\author{
Dan Kelley
}
\seealso{
A map must first have been created with \code{\link{mapPlot}}.

Other functions related to maps: \code{\link{lonlat2map}},
  \code{\link{lonlat2utm}}, \code{\link{map2lonlat}},
  \code{\link{mapArrows}}, \code{\link{mapAxis}},
  \code{\link{mapContour}},
  \code{\link{mapDirectionField}}, \code{\link{mapGrid}},
  \code{\link{mapImage}}, \code{\link{mapLines}},
  \code{\link{mapLocator}},
  \code{\link{mapLongitudeLatitudeXY}},
  \code{\link{mapPlot}}, \code{\link{mapPoints}},
  \code{\link{mapPolygon}}, \code{\link{mapScalebar}},
  \code{\link{mapText}}, \code{\link{mapTissot}},
  \code{\link{mapZones}}, \code{\link{shiftLongitude}},
  \code{\link{utm2lonlat}}
}

