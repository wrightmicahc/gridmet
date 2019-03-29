################################################################################
# This function loads gridmet data from the university of Idaho and saves it to
# a destination file
#
# minyear: minimum year of range
# maxyear: maximum year of range
# variable: which variable to download
# dest: destination folder
#
# Author: Micah Wright, Humboldt State University
################################################################################
get_gridmet <- function(minyear, maxyear, variable, dest) {
  
  year_seq <- seq(minyear, maxyear, 1)
  
  future_lapply(year_seq, function(i) {
    
    to_download <- paste0("https://www.northwestknowledge.net/metdata/data/", variable, "_", i, ".nc")
    
    destname <- paste0(dest,"/", variable, i, ".nc")
    
    download.file(url = to_download,
                  destfile = destname)
    
  })
}
