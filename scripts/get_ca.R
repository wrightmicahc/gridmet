################################################################################
# This script subsets the CA shapefile from Natural Earth
#
# Author: Micah Wright, Humboldt State University
################################################################################

# load packages
library(sf)
library(dplyr)

# load natty earth states etc.
ne <- st_read("data/natural_earth/ne_10m_states/ne_10m_admin_1_states_provinces.shp")

# filter CA
ca <- filter(ne, name == "California")

# save to a file
st_write(ca, "data/natural_earth/ne_10m_states/ca.shp")
