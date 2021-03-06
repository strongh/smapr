## TODO: figure out how these version strings are constructed
DEFAULT_VERSION    <- "R12170_002"
DEFAULT_DATA_DIR   <- "smap_ap"

#' SMAP filename
#'
#' Generates the filenames for HDF5. Incomplete.
#' @param date
#' @keywords download
#' @export
#' @examples
#' smap.filename("2015-09-11")
smap.filename <- function(date, dataset.id = "SM_AP", gzip = TRUE){
  dot.date <- strftime(date, "%Y.%m.%d")
  no.dot.date <- gsub("\\.", "" , dot.date)
  filename <- paste0("SMAP_L3_", dataset.id, "_", no.dot.date, "_", DEFAULT_VERSION, ".h5",
                     if (gzip) ".gz" else "")
  filename
}

#' SMAP URL
#'
#' Returns the FTP URL from which SMAP can be downloaded. By default fetches gzip compressed file.
#' @param date
#' @keywords download
#' @export
#' @examples
#' smap.url("2015-09-11")
smap.url <- function(date, dataset.id = "SM_AP", gzip = TRUE){
  filename <- smap.filename(date, dataset.id, gzip = gzip)
  dot.date <- strftime(date, "%Y.%m.%d")
  dataset.id.no.underscore <- gsub("_", "", dataset.id)
  paste0("ftp://n5eil01u.ecs.nsidc.org/SAN/SMAP/SPL3", dataset.id.no.underscore, ".002/", dot.date, "/", filename)
}

#' Download SMAP data for date
#'
#' Checks whether download already exsts in data directory. If local copy does not exist,
#' then performs FTP download.
#'
#' @param date
#' @keywords download
#' @export
#' @examples
#' download.smap.l3("2015-09-11")
download.smap.l3 <- function(date, data.dir = "smap_ap", dataset.id = "SM_AP", gzip = TRUE){

  h5.filename <- smap.filename(date, dataset.id, gzip = FALSE)
  h5.filepath <- paste0(data.dir, "/", h5.filename)

  ## the difference in these paths is that they are possibly .gz
  filename <- smap.filename(date, dataset.id, gzip)
  filepath <- paste0(data.dir, "/", filename)

  url <- smap.url(date, dataset.id, gzip)

  downloaded <- 0==system(paste0("ls ", h5.filepath), ignore.stdout = TRUE)
  if (!downloaded){
    res <- download.file(url, filepath)
    if (res > 0){
      # clean up any leftover files
      system(paste0("rm ", filepath), ignore.stdout = TRUE)
      stop("File not found. Check that data is available for that date.")
    }

    if (gzip) {
      system(paste("gunzip", filepath))
    }
  }
}

#' Read SMAP data for date
#'
#' Returns a dataframe withe SMAP data. Will download if necessary.
#'
#' @param date
#' @param reproject
#' @keywords download
#' @export
#' @examples
#' download.smap.l3("2015-09-11")
read.smap.l3 <- function(date, data.dir = "smap_ap", bounding.box = NULL, reproject = TRUE, ...){

  download.smap.l3(date, data.dir = data.dir, ...)

  fl <- paste0(data.dir, "/", smap.filename(date, gzip = FALSE, ...))
  lats.raw <- rhdf5::h5read(fl, "/Soil_Moisture_Retrieval_Data/latitude")
  longs.raw <- rhdf5::h5read(fl, "/Soil_Moisture_Retrieval_Data/longitude")
  longs.raw[longs.raw< -900] <- NA
  lats.raw[lats.raw< -900] <- NA


  lats <- apply(lats.raw, 2, function(x) {
    rep(x[which.min(is.na(x))], length(x))
  })


  longs <- apply(longs.raw, 1, function(x) {
    rep(x[which.min(is.na(x))], length(x))
  })

  mydata <- rhdf5::h5read(fl,
                          "/Soil_Moisture_Retrieval_Data/soil_moisture")
  mydata[mydata< -900] <- NA

  rownames(mydata) <- longs[1,]
  colnames(mydata) <- lats[1,]

  smap <- reshape2::melt(mydata, na.rm=TRUE)
  names(smap) <- c("lon", "lat", "soil.moisture")
  ## taken from http://nsidc.org/data/atlas/epsg_3410.html
  ease_proj <- "+proj=cea\n+lat_0=0\n+lon_0=0\n+lat_ts=30\n+a=6371228.0\n+units=m"

  if (!is.null(bounding.box)){
    smap <- subset(
      smap,
      lat < bounding.box$latMax & lat > bounding.box$latMin & lon < bounding.box$lonMax & lon > bounding.box$lonMin)
  }

  if (reproject){
    smap[, 1:2] <- proj4::project(smap[, 1:2], ease_proj)
  }


#  ca.smap <- subset(smap, lat < 45 & lat > 30  & lon < -115 & lon > -125)
  smap$date <- date
  smap
}


#' Download SMAP for a timerange
#'
#' Checks whether download already exsts in data directory.
#' If local copy does not exist, then performs FTP download.
#'
#' @param start
#' @param end
#' @keywords download
#' @export
#' @examples
#' timerange.smap.l3("2015-09-11","2015-09-15")
timerange.smap.l3 <- function(begin, end, bounding.box = NULL, ...){
  begin.date <- as.Date(begin)
  end.date <- as.Date(end)
  dates <- seq(from=begin.date, to=end.date, by="day")
  all.dates <- list()
  for(dt in 1:length(dates)){
    i <- dates[dt]
    date.df <- read.smap.l3(strptime(i, "%Y-%m-%d"), ...)
    if(!is.null(bounding.box)){
      date.df <- subset(date.df, lat < bounding.box$latMax & lat > bounding.box$latMin  & lon < bounding.box$lonMax & lon > bounding.box$lonMin)
    }
    if (nrow(date.df) > 0) date.df$date <- i

    all.dates[[i]] <- date.df
  }
  do.call('rbind', all.dates)
}

#' Download global SMAP data beginning at date
#'
#' It takes several days for SMAP to cover the entire globe. This function provides global
#' coverage beginning at given date.
#'
#' @param start
#' @keywords download
#' @export
#' @examples
#' global.smap.l3("2015-09-11")
global.smap.l3 <- function(begin, bounding.box = NULL, ...){
  begin.date <- as.Date(begin)
  end.date <- begin.date + 3
  timerange.smap.l3(begin, end.date, ...)
}
