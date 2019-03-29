library(raster)
library(sf)
library(data.table)

get_days_since_rain <- function(year, mask_region, fire_type) {
  
  # specify filename
  fname <- paste0("pr", year, ".nc")
  
  # load the net cdf file
  b <- brick(paste("data/pr", fname, sep = "/"))
  
  # crop and mask to CA
  cb <- crop(b, mask_region)
  mb <- mask(cb, mask_region)
  
  # get the number of days
  days <-  1:nbands(mb)
  
  # update the band names 
  names(mb) <- paste("day", days, sep = "_")
  
  # create a vector of months accounting for leap years
  if(year %in% seq(2000, 2016, 4)) {
    months <- cumsum(c(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
  } else {
    months <- cumsum(c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
  }
  
  # subset to specific season. Keep the preceeding month to avoid edge effects, 
  # will be removed later
  if(fire_type == "wildfire") {
    mb <- dropLayer(mb, i = c(1:(months[5] - 1),
                            months[10]:max(days)))
  } else {
    mb <- dropLayer(mb, i = c(1:(months[8] - 1),
                            months[11]:max(days)))
  }
  
  # define reclassification matrix
  recl <- matrix(c(0, 6.35, 0, 6.36, 9999, 1), ncol = 3, byrow = TRUE)
  
  # reclassify 0.25" rain as 1, otherwise 0
  is_wet <- reclassify(mb, recl)
  
  # get df and change to DT
  dt <- as.data.frame(is_wet, xy = TRUE,na.rm = TRUE)
  dt <- as.data.table(dt)
  
  # make the data long
  dtm <- melt(dt,
              id.vars = c("x", "y"),
              variable.name = "day",
              variable.factor = FALSE,
              value.name = "wetting_rain")
  
  # create a day sequence 
  dtm[, day_seq := as.integer(sub(".*\\.", "", day))]
  
  # make sure order is correct
  setkey(dtm, x, y, day_seq)
  
  # get days since rain
  dtm[, days_since_rain := rowid(cumsum(wetting_rain == 1)) - 1L, by = c("x", "y")]

  # calculate the average
  dtm[, mean_dsr := mean(days_since_rain, na.rm = TRUE), by = c("x", "y")]
  
  dtm <- dtm[day_seq > 31]
  
  # make a raster again
  dsr <- rasterFromXYZ(dtm[, .(x, y, mean_dsr)], res = res(mb), crs = 4326)
  
  return(dsr)
}
  