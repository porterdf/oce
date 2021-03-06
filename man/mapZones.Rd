% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map.R
\name{mapZones}
\alias{mapZones}
\title{Add Zones to a Map [DEPRECATED]}
\usage{
mapZones(longitude, polarCircle = 0, lty = "solid", lwd = 0.5 *
  par("lwd"), col = "darkgray", ...)
}
\arguments{
\item{longitude}{either a logical indicating whether to draw a zonal grid,
or a vector of longitudes at which to draw zones.}

\item{polarCircle}{a number indicating the number of degrees of latitude
extending from the poles, within which zones are not drawn.}

\item{lty}{line type.}

\item{lwd}{line width.}

\item{col}{line colour.}

\item{...}{optional arguments passed to \code{\link{lines}}.}
}
\description{
Plot zones (lines of constant longitude) on a existing map.
\strong{Warning:} this function will be removed soon;
see \link{oce-deprecated}.
}
\details{
Zones that will not fit in the plotting space are ignored.
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
mapPlot(longitude, latitude, type='l', grid=FALSE,
longitudelim=c(-80,10), latitudelim=c(0,120),
projection="orthographic", orientation=c(45,-100,0))
mapZones()
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
  \code{\link{mapMeridians}}, \code{\link{mapPlot}},
  \code{\link{mapPoints}}, \code{\link{mapPolygon}},
  \code{\link{mapScalebar}}, \code{\link{mapText}},
  \code{\link{mapTissot}}, \code{\link{shiftLongitude}},
  \code{\link{utm2lonlat}}
}

