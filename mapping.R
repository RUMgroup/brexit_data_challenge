library(tidyverse)
library(sf)
library(leaflet)

EU_referendum_result_data <- read.csv(file.choose())

#read ethnicity data
ee_aao9817_gisruk <- read.csv(file.choose())

#create measure of interest
ee_aao9817_gisruk$economist_98to2016 <- (ee_aao9817_gisruk$y2016 - ee_aao9817_gisruk$y1998)*100


#check number of missing values
nrow(ee_aao9817_gisruk %>%
  filter(is.na(y1998)))

#get boundary data from https://borders.ukdataservice.ac.uk/easy_download.html

#read in shape file
lsoas <- st_read(file.choose())

#look at data in shapefile
View(lsoas)

#plot the geometry (outline)
plot(st_geometry(lsoas))

#struggle with factors/strings and eventually convert to string
class(lsoas$code)

lsoas$code <- as.character(lsoas$code)
ee_aao9817_gisruk$geographycode <- as.character(ee_aao9817_gisruk$geographycode)
class(ee_aao9817_gisruk$geographycode)

#join data to shapefile
aao_lsoa <- left_join(lsoas, ee_aao9817_gisruk, by = c("code"="geographycode"))


#map data

plot(aao_lsoa[23])


#map with leaflet


#check coordinate reference system
st_crs(aao_lsoa_WGS84)

#transform to WGS8
aao_lsoa_WGS84 <- st_transform(aao_lsoa, 4326)


# leaflet widget
m <- leaflet() %>%
  addProviderTiles(providers$Stamen.Toner) %>%
  addPolygons(data = aao_lsoa_WGS84, weight = 1, smoothFactor = 0.75,
              opacity = 0, fillOpacity = 0.75,
              color = "#000000",
              fillColor = ~colorBin("YlOrRd", economist_98to2016)(economist_98to2016),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE), 
              popup = paste0("Name:", aao_lsoa_WGS84$name, "<br> Value: ", aao_lsoa_WGS84$economist_98to2016)) 


#print the object
m