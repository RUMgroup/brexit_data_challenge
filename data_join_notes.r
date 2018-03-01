####  

## working directory has a folder called gisruk_data with all csv data files in it
# setwd()
getwd()


## get ethnicity data ####

ee.files <- list.files("gisruk_data", pattern = "ee",full.names = T)
ee.list <- lapply(ee.files, read.csv, stringsAsFactors = F)

head(ee.list[[1]])
str(ee.list[[1]])


## Brexit data is at Local Authority level (LAD...)
# LAD16CD (LSOA look up) == Area Code (Brexit data)
brexit <- read.csv("gisruk_data/EU-referendum-result-data.csv", stringsAsFactors = F)
str(brexit)
head(brexit)

## Bring in look up table
lsoa.lu <- read.csv("gisruk_data/Lower_Layer_Super_Output_Area_2011_to_Ward_to_Local_Authority_District_December_2016_Lookup_in_England_and_Wales.csv",
                    stringsAsFactors = F, fileEncoding = "UTF-8-BOM")
head(lsoa.lu)
str(lsoa.lu)



## To match Ethnicity with LSOA, needs to be aggregated to LA
# merge Local Authority to Ethnicity data
head(lsoa.lu)
head(ee.list[[1]])
sapply(ee.list, nrow); sapply(ee.list, ncol) 
ee.list <- lapply(ee.list, function(x) merge(x, lsoa.lu[c("LSOA11CD", "LAD16CD")], by.x = "geographycode", by.y = "LSOA11CD", sort = F, all = T))

# Aggregate data to LA level
str(ee.list[[1]])
ee.LAD <- lapply(ee.list, function(x) aggregate(x[,!colnames(x) %in% c("LAD16CD", "geographycode")], list(x[,"LAD16CD"]), mean, na.rm = T))
