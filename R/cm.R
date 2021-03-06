## vim:textwidth=100:expandtab:shiftwidth=4:softtabstop=4


#' @title Class to Store Current Meter (CM) Data
#' 
#' @description
#' Class to store current meter data from an interocean S4 device.  A file
#' containing CM profile data may be read with \code{\link{read.cm}}. The results
#' may be plotted with \code{\link{plot,cm-method}} or summarized with
#' \code{\link{summary,cm-method}}.  Data may be retrieved with
#' \code{\link{[[,cm-method}} or replaced with \ \code{\link{[[<-,cm-method}}.
#' 
#' @author Dan Kelley
#' 
#' @family classes provided by \code{oce}
#' @family things related to \code{cm} data
setClass("cm", contains="oce")

#' @title A CM Record
#' 
#' @description
#' The result of using \code{\link{read.cm}} on a current meter file holding measurements made with an
#' InterOcean S4 device.  See \code{\link{read.cm}} for some general cautionary notes on reading such
#' files, and be aware that the salinities in this sample dataset are known to be incorrect, for
#' unknown reasons perhaps related to lack of calibration of an old instrument that is seldom used.
#'
#' @name cm
#' @docType data
#' @usage data(cm)
#' @examples
#' \dontrun{
#' library(oce)
#' data(cm)
#' summary(cm)
#' plot(cm)
#' }
#' @family datasets provided with \code{oce}
#' @family things related to \code{cm} data
NULL

#' @title Extract Something From a CM Object
#' @param x A cm object, i.e. one inheriting from \code{\link{cm-class}}.
#'
#' @template sub_subTemplate
#'
#' @family things related to \code{cm} data
setMethod(f="[[",
          signature(x="cm", i="ANY", j="ANY"),
          definition=function(x, i, j, ...) {
              callNextMethod()
          })

#' @title Replace Parts of a CM Object
#' @param x An \code{cm} object, i.e. inheriting from \code{\link{cm-class}}
#' @template sub_subsetTemplate
#' @family things related to \code{cm} data
setMethod(f="[[<-",
          signature(x="cm", i="ANY", j="ANY"),
          definition=function(x, i, j, value) {
              callNextMethod(x=x, i=i, j=j, value=value)
          })

setMethod(f="initialize",
          signature="cm",
          definition=function(.Object, filename="(unknown)", sample, time,
                              u, v, heading,
                              conductivity, salinity, temperature, pressure) {
              .Object@metadata$filename <- filename
              .Object@metadata$units$temperature <- list(unit=expression(degree*C), scale="ITS-90") # guess on the unit
              .Object@metadata$units$conductivity <- list(unit=expression(mS/cm), scale="")
              .Object@data$sample <- if (missing(sample)) NULL else sample
              .Object@data$time <- if (missing(time)) NULL else time
              .Object@data$u <- if (missing(u)) NULL else u
              .Object@data$v <- if (missing(v)) NULL else v
              .Object@data$heading <- if (missing(heading)) NULL else heading
              .Object@data$conductivity <- if (missing(conductivity)) NULL else conductivity
              .Object@data$salinity <- if (missing(salinity)) NULL else salinity
              .Object@data$temperature <- if (missing(temperature)) NULL else temperature
              .Object@data$pressure <- if (missing(pressure)) NULL else pressure
              .Object@processingLog$time <- as.POSIXct(Sys.time())
              .Object@processingLog$value <- "create 'cm' object"
              return(.Object)
          })

#' @title Summarize a CM Object
#' 
#' @description
#' Summarizes some of the data in a \code{cm} object, presenting such information
#' as the station name, sampling location, data ranges, etc.
#'
#' @param object A \code{cm} object, i.e. one inheriting from \code{\link{cm-class}}.
#' 
#' @param ... Further arguments passed to or from other methods.
#' 
#' @seealso The documentation for \code{\link{cm-class}} explains the structure
#' of \code{cm} objects, and also outlines the other functions dealing with them.
#' 
#' @author Dan Kelley
#' 
#' @family things related to \code{cm} data
setMethod(f="summary",
          signature="cm",
          definition=function(object, ...) {
              cat("Cm summary\n----------\n\n", ...)
              showMetadataItem(object, "filename",      "File source:        ", quote=TRUE)
              showMetadataItem(object, "type",          "Instrument type:    ")
              showMetadataItem(object, "serialNumber",  "Serial Number:      ")
              showMetadataItem(object, "version",       "Version:            ")
              callNextMethod()
          })


#' @title Subset a CM Object
#' 
#' @description
#' This function is somewhat analogous to \code{\link{subset.data.frame}}.
#' 
#' @param x a \code{cm} object, i.e. inheriting from \code{\link{cm-class}}.
#' 
#' @param subset a condition to be applied to the \code{data} portion of \code{x}.
#' See \sQuote{Details}.
#' 
#' @param ... ignored.
#' 
#' @return A new \code{cm} object.
#' 
#' @examples
#' library(oce)
#' data(cm)
#' plot(cm)
#' plot(subset(cm, time < mean(range(cm[['time']]))))
#' 
#' @author Dan Kelley
#' @family things related to \code{cm} data
setMethod(f="subset",
          signature="cm",
          definition=function(x, subset, ...) {
              subsetString <- paste(deparse(substitute(subset)), collapse=" ")
              res <- x
              dots <- list(...)
              debug <- getOption("oceDebug")
              if (length(dots) && ("debug" %in% names(dots)))
                  debug <- dots$debug
              if (missing(subset))
                  stop("must give 'subset'")
              if (length(grep("time", subsetString))) {
                  oceDebug(debug, "subsetting a cm by time\n")
                  keep <- eval(substitute(subset), x@data, parent.frame(2))
                  names <- names(x@data)
                  oceDebug(debug, vectorShow(keep, "keeping bins:"))
                  oceDebug(debug, "number of kept bins:", sum(keep), "\n")
                  if (sum(keep) < 2)
                      stop("must keep at least 2 profiles")
                  res <- x
                  ## FIXME: are we handling slow timescale data?
                  for (name in names(x@data)) {
                      if (name == "time" || is.vector(x@data[[name]])) {
                          oceDebug(debug, "subsetting x@data$", name, ", which is a vector\n", sep="")
                          res@data[[name]] <- x@data[[name]][keep] # FIXME: what about fast/slow
                      } else if (is.matrix(x@data[[name]])) {
                          oceDebug(debug, "subsetting x@data$", name, ", which is a matrix\n", sep="")
                          res@data[[name]] <- x@data[[name]][keep,]
                      } else if (is.array(x@data[[name]])) {
                          oceDebug(debug, "subsetting x@data$", name, ", which is an array\n", sep="")
                          res@data[[name]] <- x@data[[name]][keep,,, drop=FALSE]
                      }
                  }
              }
              res@processingLog <- processingLogAppend(res@processingLog, paste("subset.adp(x, subset=", subsetString, ")", sep=""))
              res
          })


#' @title Read a CM file
#' 
#' @description
#' Read a current-meter data file, producing an object of type \code{cm}.
#' 
#' @details
#' There is function has been tested on only a single file, and the data-scanning
#' algorithm was based on visual inspection of that file.  Whether it will work
#' generally is an open question. It should be noted that the sample file had
#' several odd characteristics, some of which are listed below.
#' \itemize{
#' 
#'   \item  The file contained two columns named \code{"Cond"}, which was guessed
#'   to stand for conductivity. Since only the first contained data, the second was
#'   ignored, but this may not be the case for all files.  
#' 
#'   \item The unit for \code{"Cond"} was stated in the file to be \code{"mS"},
#'   which makes no sense, so the unit was assumed to be mS/cm, and the value was
#'   divided by the standard value 42.914mS/cm (see Culkin and Smith, 1980), to
#'   estimate the conductivity ratio.
#' 
#'   \item The file contained a column named \code{"T-Temp"}, which is not
#'   something the author has seen in his career. It was assumed to stand for
#'   in-situ temperature.
#' 
#'   \item The file contained a column named \code{"Depth"}, which is not something
#'   an instrument can measure. Presumably it was calculated from pressure (with
#'   what atmospheric offset, though?) and so pressure was inferred from it using
#'   \code{\link{swPressure}}.
#' 
#'   \item The file contained several columns that lacked names. These were
#'   ignored.
#' 
#'   \item The file contained several columns that seem to be derived from the
#'   actual measured data, such as \code{"Speed"}, \code{"Dir"}, \code{"N-S Dist"},
#'   etc. These are ignored.
#' 
#'   \item The file contained several columns that were basically a mystery to the
#'   author, e.g. \code{"Hx"}, \code{"Hy"}, \code{"Vref"}, etc. These were ignored.
#' 
#' }
#' 
#' Based on such considerations, \code{read.cm.s4()} reads only the columns that
#' were reasonably well-understood based on the sample file. Users who need more
#' columns should contact the author.
#' 
#' 
#' @param file a connection or a character string giving the name of the file to
#' load.
#' 
#' @param from index number of the first measurement to be read, or the time of
#' that measurement, as created with \code{\link{as.POSIXct}} (hint: use
#' \code{tz="UTC"}).
#' 
#' @param to indication of the last measurement to read, in a format matching that
#' of \code{from}.
#' 
#' @param by an indication of the stride length to use while walking through the
#' file. If this is an integer, then \code{by-1} measurements are skipped between
#' each pair of profiles that is read. This may not make much sense, if the data
#' are not equi-spaced in time.  If \code{by} is a string representing a time
#' interval, in colon-separated format, then this interval is divided by the
#' sampling interval, to get the stride length. \emph{BUG:} if the data are not
#' equi-spaced, then odd results will occur.
#' 
#' @param longitude optional signed number indicating the longitude in degrees
#' East.
#' 
#' @param latitude optional signed number indicating the latitude in degrees North.
#' 
#' @param type character string indicating type of file (ignored at present).
#' 
#' @param tz character string indicating time zone to be assumed in the data.
#' 
#' @param debug a flag that turns on debugging.  The value indicates the depth
#' within the call stack to which debugging applies.
#' 
#' @param monitor ignored at present.
#' 
#' @param processingLog if provided, the action item to be stored in the log.  This
#' parameter is typically only provided for internal calls; the default that it
#' provides is better for normal calls by a user.
#' 
#' @param ... Optional arguments passed to plotting functions.
#' 
#' @return An object of \code{\link[base]{class}} \code{"cm"}, which contains measurements
#' made with a current-meter device.  The \code{data} slot will contain
#' \code{time}, \code{u} (eastward velocity, converted from cm/s to m/s), \code{v}
#' (northward velocity, converted from cm/s to m/s) \code{salinity} (salinity, with
#' the caution that the values in the sample file seem about 6PSU higher than they
#' should be), \code{temperature} (temperature, assumed in-situ), and
#' \code{pressure} (pressure, calculated with \code{\link{swPressure}} based on the
#' \code{"Depth"} column in the file).
#' 
#' \code{Caution.} The value in the \code{"Hdg"} file is stored as \code{heading}
#' in the data, but this is just a guess.
#' 
#' See \dQuote{Details} for an explanation of why other columns are ignored.
#' 
#' @examples
#' \dontrun{
#'   library(oce)
#'   cm <- read.oce("cm_interocean_0811786.s4a.tab")
#'   summary(cm)
#'   plot(cm)
#' }
#' 
#' 
#' @author Dan Kelley
#' 
#' @references
#' Culkin, F., and Norman D. Smith, 1980. Determination of the concentration of
#' potassium chloride solution having the same electrical conductivity, at 15 C and
#' infinite frequency, as standard seawater of salinity 35.0000 ppt (Chlorinity
#' 19.37394 ppt). \emph{IEEE Journal of Oceanic Engineering}, \bold{5}, pp 22-23.
#' @family things related to \code{cm} data
read.cm <- function(file, from=1, to, by=1, tz=getOption("oceTz"),
                    type=c("s4"),
                    longitude=NA, latitude=NA,
                    debug=getOption("oceDebug"), monitor=FALSE, processingLog, ...)
{
    oceDebug(debug, "read.cm(file=\"",file,
              "\", from=", format(from),
              ", to=", if (missing(to)) "(missing)" else format(to), ", by=", by, "type=", type, ", ...) {\n", sep="", unindent=1)
    type <- match.arg(type)
    if (type == "s4")
        read.cm.s4(file=file, from=from, to=to, by=by, tz=tz,
                   longitude=longitude, latitude=latitude,
                   debug=debug-1, monitor=monitor, processingLog=processingLog, ...)
    else
        stop("unknown type of current meter")
}

read.cm.s4 <- function(file, from=1, to, by=1, tz=getOption("oceTz"),
                       longitude=NA, latitude=NA,
                       debug=getOption("oceDebug"), monitor=FALSE, processingLog, ...)
{
    if (debug > 1)
        debug <- 1
    oceDebug(debug, "read.cm.s4(file=\"",file,
              "\", from=", format(from),
              ", to=", if (missing(to)) "(missing)" else format(to), ", by=", by, ", ...) {\n", sep="", unindent=1)
    if (is.character(file)) {
        filename <- fullFilename(file)
        file <- file(file, "r")
        on.exit(close(file))
    }
    if (!inherits(file, "connection"))
        stop("argument `file' must be a character string or connection")
    if (!isOpen(file)) {
        filename <- "(connection)"
        open(file, "rb")
        on.exit(close(file))
    }
    ## Examine the first line of the file, to get serial number, etc.
    items <- scan(file, "character", nlines=1, sep="\t", quiet=TRUE) # slow, but just one line
    oceDebug(debug, "line 1 contains: ", paste(items, collapse=" "), "\n")
    serialNumber <- "unknown"
    version <- "unknown"
    type <- "unknown"
    for (i in 1:(-1 + length(items))) {
        if (length(grep("Serial", items[i])))
            serialNumber <- items[i+1]
        else if (length(grep("Version", items[i])))
            version <- items[i+1]
        else if (length(grep("Type", items[i])))
            type <- items[i+1]
    }
    ## Skip through the rest of the header, and start paying attention when
    ## row number is 1, 2, and then 3.  These first rows give us the time
    ## sequence.
    foundNames <- FALSE
    headerStart <- 0
    lines <- readLines(file, n=20)
    for (i in 2:20) {
        items <- strsplit(lines[i], "\t")[[1]]
        oceDebug(debug, "line", i, "contains: ", paste(items, collapse=" "), "\n")
        if (items[1] == "Sample #") {
            names <- sub('[ ]+$', '', sub('^[ ]+','', items))
            names <- ifelse(0 == nchar(names), paste("column", 1:length(names), sep=""), names)
            foundNames <- TRUE
            headerStart <- i
        } else if (items[1] == "1") {
            start.day <- items[2]
        } else if (items[1] == "2") {
            start.hms <- items[3]
        } else if (items[1] == "3") {
            t0 <- strptime(paste(start.day, start.hms), format="%m/%d/%Y %H:%M:%S", tz=tz)
            t1 <- strptime(paste(start.day, items[3]), format="%m/%d/%Y %H:%M:%S", tz=tz)
            deltat <- as.numeric(t1) - as.numeric(t0)
            break
        }
    }
    pushBack(lines, file)
    ## Now try to guess the meanings of column names. This really is guesswork, since I have no documentation that
    ## explains these things. See the help page for this function for some more thoughts on the problem.
    d <- read.table(file, skip=headerStart+1, sep='\t', stringsAsFactors=FALSE, fill=TRUE)
    col.north <- 5
    col.east <- 6
    col.conductivity <- 13
    col.temperature <- 13
    col.depth <- 14
    col.heading <- 17
    col.salinity <- 19
    if (foundNames) {
        names <- names[1:dim(d)[2]]
        col.east <- which(names == "Veast")
        if (length(col.east) > 0)
            col.east <- col.east[1]
        col.north <- which(names == "Vnorth")
        if (length(col.north) > 0)
            col.north <- col.north[1]
        col.heading <- which(names == "Hdg")
        if (length(col.heading) > 0)
            col.heading <- col.heading[1]
        col.conductivity <- which(names == "Cond")
        if (length(col.conductivity) > 0)
            col.conductivity <- col.conductivity[1]
        col.salinity <- which(names == "Sal")
        if (length(col.salinity) > 0)
            col.salinity <- col.salinity[1]
        col.temperature <- which(names == "T-Temp")
        if (length(col.temperature) > 0)
            col.temperature <- col.temperature[1]
        col.depth <- which(names == "Depth")
        if (length(col.depth) > 0)
            col.depth <- col.depth[1]
    }
    trimLines <- grep("[ a-zA-Z]+", d[,1])
    oceDebug(debug, "Trimming the following lines, which seem not to be data lines: ",
             paste(trimLines, collapse=" "), "\n")
    d <- d[-trimLines,]
    u <- d[, col.east] / 100
    v <- d[, col.north] / 100
    heading <- d[, col.heading]
    ## the 42.91754 value is electrical conductivity at SP=35, t=15, p=0
    conductivity <- d[, col.conductivity]
    temperature <- d[, col.temperature]
    depth <- d[, col.depth]
    pressure <- swPressure(depth, eos="gsw") # gsw is faster than unesco with essentially same results
    salinity <- d[, col.salinity]

    ## The sample file has lines at the end that contain statistical summaries. Recognize these as non-numeric samples.
    sample <- as.numeric(d[, 1])
    n <- length(u)
    time <- seq(t0, by=deltat, length.out=n)
    if (inherits(from, "POSIXt")) {
        if (!inherits(to, "POSIXt"))
            stop("if 'from' is POSIXt, then 'to' must be, also")
        if (!is.numeric(by) || by != 1)
            stop("sorry, 'by' must equal 1, in this version of read.cm.s4()")
        ##from.to.POSIX <- TRUE
        from.index <- which(time >= from)[1]
        if (is.na(from.index))
            from.index <- 1
        to.index <- which(to <= time)[1]
        if (is.na(to.index))
            to.index <- n
        oceDebug(debug, "Time-based trimming: from=", format(from), "to=", format(to), "yield from.index=", from.index, "and to.index=", to.index, "\n")
        keep <- seq(from.index, to.index)
    } else {
        if (!is.numeric(from))
            stop("'from' must be either POSIXt or numeric")
        
            to <- n
        if (!is.numeric(to))
            stop("'to' must be either POSIXt or numeric")
        keep <- seq(from, to)
    }
    keep <- keep[1 <= keep]
    keep <- keep[keep <= n]
    res <- new("cm", sample=as.numeric(sample[keep]), time=time[keep],
               u=u[keep], v=v[keep], heading=heading[keep],
               conductivity=conductivity[keep],
               salinity=salinity[keep], temperature=temperature[keep], pressure=pressure[keep])
    res@metadata$filename <- filename
    res@metadata$serialNumber <- serialNumber
    res@metadata$version <- version
    res@metadata$type <- type
    res@metadata$longitude <- longitude
    res@metadata$latitude <- latitude
    res@metadata$units$u <- list(unit=expression(m/s), scale="")
    res@metadata$units$v <- list(unit=expression(m/s), scale="")
    res@metadata$units$salinity <- list(unit=expression(), scale="PSS-78")
    res@metadata$units$temperature <- list(unit=expression(degree*C), scale="ITS-90")
    res@metadata$units$pressure <- list(unit=expression(dbar), scale="")
    res@metadata$units$heading <- list(unit=expression(degree), scale="")
    if (missing(processingLog)) processingLog <- paste(deparse(match.call()), sep="", collapse="")
    res@processingLog <- processingLogAppend(res@processingLog, processingLog)
    oceDebug(debug, "} # read.cm()\n", unindent=1)
    res
}


#' Plot CM data
#' 
#' Creates a multi-panel summary plot of data measured by a current meter.
#' 
#' The panels are controlled by the \code{which} argument, as follows.
#' 
#' \itemize{ 
#' 
#'   \item \code{which=1} or \code{which="u"} for a time-series graph of eastward
#'   velocity, \code{u}, as a function of time.
#' 
#'   \item \code{which=2} or \code{which="v"} for a time-series graph of
#'   northward velocity, \code{u}, as a function of time.
#' 
#'   \item \code{which=3} or \code{"progressive vector"} for progressive-vector
#'   plot
#' 
#'   \item \code{which=4} or \code{"uv"} for a plot of \code{v} versus \code{u}.
#'   (Dots are used for small datasets, and smoothScatter for large ones.)
#' 
#'   \item \code{which=5} or \code{"uv+ellipse"} as the \code{"uv"} case, but
#'   with an added indication of the tidal ellipse, calculated from the eigen
#'   vectors of the covariance matrix.
#' 
#'   \item \code{which=6} or \code{"uv+ellipse+arrow"} as the \code{"uv+ellipse"}
#'   case, but with an added arrow indicating the mean current.
#' 
#'   \item \code{which=7} or \code{"pressure"} for pressure
#' 
#'   \item \code{which=8} or \code{"salinity"} for salinity
#' 
#'   \item \code{which=9} or \code{"temperature"} for temperature
#' 
#'   \item \code{which=10} or \code{"TS"} for a TS diagram
#' 
#'   \item \code{which=11} or \code{"conductivity"} for conductivity
#' 
#'   \item \code{which=20} or \code{"heading"} for compass heading
#' 
#' }
#' 
#' @param x an \code{cm} object, e.g. as read by \code{\link{read.cm}}.
#' 
#' @param which list of desired plot types.  These are graphed in panels running
#' down from the top of the page.  See \dQuote{Details} for the meanings of various
#' values of \code{which}.
#' 
#' @param type type of plot, as for \code{\link{plot}}.
#'
#' @template adornTemplate
#' 
#' @param drawTimeRange boolean that applies to panels with time as the horizontal
#' axis, indicating whether to draw the time range in the top-left margin of the
#' plot.
#' 
#' @param drawZeroLine boolean that indicates whether to draw zero lines on
#' velocities.
#' 
#' @param mgp 3-element numerical vector to use for \code{par(mgp)}, and also for
#' \code{par(mar)}, computed from this.  The default is tighter than the R default,
#' in order to use more space for the data and less for the axes.
#' 
#' @param mar value to be used with \code{\link{par}("mar")}.
#' 
#' @param small an integer indicating the size of data set to be considered
#' "small", to be plotted with points or lines using the standard
#' \code{\link{plot}} function.  Data sets with more than \code{small} points will
#' be plotted with \code{\link{smoothScatter}} instead.
#' 
#' @param main main title for plot, used just on the top panel, if there are
#' several panels.
#' 
#' @param tformat optional argument passed to \code{\link{oce.plot.ts}}, for plot
#' types that call that function.  (See \code{\link{strptime}} for the format
#' used.)
#' 
#' @param debug a flag that turns on debugging.  Set to 1 to get a moderate amount
#' of debugging information, or to 2 to get more.
#' 
#' @param ... Optional arguments passed to plotting functions.
#' 
#' @examples
#'   library(oce)
#'   data(cm)
#'   summary(cm)
#'   plot(cm)
#' 
#' @author Dan Kelley
#' 
#' @family functions that plot \code{oce} data
#' @family things related to \code{cm} data
setMethod(f="plot",
          signature=signature("cm"),
          definition=function(x,
                              which=c(1:2, 7:9),
                              type="l",
                              adorn=NULL,
                              drawTimeRange=getOption("oceDrawTimeRange"),
                              drawZeroLine=FALSE,
                              mgp=getOption("oceMgp"),
                              mar=c(mgp[1]+1.5,mgp[1]+1.5,1.5,1.5),
                              small=2000,
                              main="",
                              tformat,
                              debug=getOption("oceDebug"),
                              ...)
          {
              oceDebug(debug, "plot.cm() {\n", unindent=1)
              oceDebug(debug, "  par(mar)=", paste(par('mar'), collapse=" "), "\n")
              oceDebug(debug, "  par(mai)=", paste(par('mai'), collapse=" "), "\n")
              if (!is.null(adorn))
                  warning("In plot() : the 'adorn' argument is defunct, and will be removed soon",call.=FALSE)
              if (!(is.null(x@metadata$have.actual.data) || x@metadata$have.actual.data)) {
                  warning("there are no profiles in this dataset")
                  return
              }
              opar <- par(no.readonly = TRUE)
              lw <- length(which)
              oceDebug(debug, "length(which) =", lw, "\n")
              if (lw > 1)
                  on.exit(par(opar))
              par(mgp=mgp, mar=mar)
              dots <- list(...)
              ##gave.ylim <- "ylim" %in% names(dots)
              ##ylim.given <- if (gave.ylim) dots[["ylim"]] else NULL

              oceDebug(debug, "later on in plot,adp-method:\n")
              oceDebug(debug, "  par(mar)=", paste(par('mar'), collapse=" "), "\n")
              oceDebug(debug, "  par(mai)=", paste(par('mai'), collapse=" "), "\n")
              oceDebug(debug, "which:", which, "\n")
              which <- oce.pmatch(which,
                                  list(u=1, v=2, "progressive vector"=3,
                                       "uv"=4, "uv+ellipse"=5, "uv+ellipse+arrow"=6,
                                       pressure=7, salinity=8, temperature=9, TS=10, conductivity=11,
                                       heading=20))
              oceDebug(debug, "which:", which, "\n")
              adorn.length <- length(adorn)
              if (adorn.length == 1) {
                  adorn <- rep(adorn, lw)
                  adorn.length <- lw
              }

              tt <- x@data$time
              class(tt) <- "POSIXct"              # otherwise image() gives warnings
              if (lw > 1) {
                  par(mfrow=c(lw, 1))
                  oceDebug(debug, "calling par(mfrow=c(", lw, ", 1)\n")
              }
              len <- length(x@data$u)
              for (w in 1:lw) {
                  oceDebug(debug, "which[", w, "]=", which[w], "; drawTimeRange=", drawTimeRange, "\n")
                  if (which[w] == 1) {
                      oce.plot.ts(x@data$time, x@data$u,
                                  type=type,
                                  xlab="", ylab=resizableLabel("u"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else if (which[w] == 2) {
                      oce.plot.ts(x@data$time, x@data$v,
                                  type=type,
                                  xlab="", ylab=resizableLabel("v"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else if (which[w] == 3) {     # or "progressive vector"
                      oceDebug(debug, "progressive vector plot\n")
                      dt <- as.numeric(difftime(x@data$time[2], x@data$time[1],units="sec")) # FIXME: assuming equal dt
                      m.per.km <- 1000
                      u <- x@data$u
                      v <- x@data$v
                      u[is.na(u)] <- 0        # zero out missing
                      v[is.na(v)] <- 0
                      x.dist <- cumsum(u) * dt / m.per.km
                      y.dist <- cumsum(v) * dt / m.per.km
                      plot(x.dist, y.dist,
                           xlab=resizableLabel("distance km"), ylab=resizableLabel("distance km"),
                           type='l', asp=1, ...)
                  } else if (which[w] %in% 4:6) {     # "uv" (if 4), "uv+ellipse" (if 5), or "uv+ellipse+arrow" (if 6)
                      oceDebug(debug, "\"uv\", \"uv+ellipse\", or \"uv+ellipse+arrow\" plot\n")
                      if (len <= small)
                          plot(x@data$u, x@data$v, type=type,
                               xlab=resizableLabel("u"), ylab=resizableLabel("v"),
                               asp=1, ...)
                      else
                          smoothScatter(x@data$u, x@data$v,
                                        xlab=resizableLabel("u"), ylab=resizableLabel("v"),
                                        asp=1, ...)
                      if (which[w] >= 5) {
                          oceDebug(debug, "\"uv+ellipse\", or \"uv+ellipse+arrow\" plot\n")
                          ok <- !is.na(x@data$u) & !is.na(x@data$v)
                          e <- eigen(cov(data.frame(u=x@data$u[ok], v=x@data$v[ok])))
                          major <- sqrt(e$values[1])
                          minor <- sqrt(e$values[2])
                          theta <- seq(0, 2*pi, length.out=360/5)
                          xx <- major * cos(theta)
                          yy <- minor * sin(theta)
                          theta0 <- atan2(e$vectors[2,1], e$vectors[1,1])
                          rotate <- matrix(c(cos(theta0), -sin(theta0), sin(theta0), cos(theta0)), nrow=2, byrow=TRUE)
                          xxyy <- rotate %*% rbind(xx, yy)
                          col <- if ("col" %in% names(dots)) col else "darkblue"
                          lines(xxyy[1,], xxyy[2,], lwd=5, col="yellow")
                          lines(xxyy[1,], xxyy[2,], lwd=2, col=col)
                          if (which[w] >= 6) {
                              oceDebug(debug, "\"uv+ellipse+arrow\" plot\n")
                              umean <- mean(x@data$u, na.rm=TRUE)
                              vmean <- mean(x@data$v, na.rm=TRUE)
                              arrows(0, 0, umean, vmean, lwd=5, length=1/10, col="yellow")
                              arrows(0, 0, umean, vmean, lwd=2, length=1/10, col=col)
                          }
                      }
                  } else if (which[w] == 7) {
                      ## an older version had depth stored
                      p <- if ("pressure" %in% names(x@data)) x@data$pressure else
                          swPressure(x@data$depth, eos="gsw")
                      oce.plot.ts(x@data$time, p,
                                  type=type,
                                  xlab="", ylab=resizableLabel("p", "y"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else if (which[w] == 8) {
                      oce.plot.ts(x@data$time, x[["salinity"]],
                                  type=type,
                                  xlab="", ylab=resizableLabel("S", "y"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else if (which[w] == 9) {
                      oce.plot.ts(x@data$time, x[["temperature"]],
                                  type=type,
                                  xlab="", ylab=resizableLabel("T", "y"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else if (which[w] == 10) {
                      plotTS(as.ctd(x[["salinity"]], x[["temperature"]], x[["pressure"]]), main=main, ...) 
                  } else if (which[w] == 11) {
                      cu <- x[["conductivityUnit"]]
                      if (is.list(cu))
                          cu <- as.character(cu$unit)
                      oce.plot.ts(x@data$time, x@data$conductivity,
                                  type=type,
                                  xlab="",
                                  ylab=if (0 == length(cu)) resizableLabel("C", "y") else
                                      if (cu=="mS/cm") resizableLabel("conductivity mS/cm", "y") else
                                          if (cu=="S/m") resizableLabel("conductivity S/m", "y") else
                                              "conductivity (unknown unit",
                                              main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                      tformat=tformat)
                  } else if (which[w] == 20) {
                      oce.plot.ts(x@data$time, x@data$heading,
                                  type=type,
                                  xlab="", ylab=resizableLabel("heading"),
                                  main=main, mgp=mgp, mar=c(mgp[1], mgp[1]+1.5, 1.5, 1.5),
                                  tformat=tformat)
                  } else {
                      stop("unknown value of which (", which[w], ")")
                  }
                  if (w <= adorn.length) {
                      t <- try(eval(adorn[w]), silent=TRUE)
                      if (class(t) == "try-error")
                          warning("cannot evaluate adorn[", w, "]\n")
                  }
              }
              oceDebug(debug, "} # plot.cm()\n", unindent=1)
              invisible()
          })

