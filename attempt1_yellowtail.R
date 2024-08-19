library(readr)
library(dplyr)
library(rgbif)
library(voluModel)
library(tibble)
library(ggplot2)
library(fields)
library(terra)

# we will use the download ID to download the occurrences using rgbif
occurrence <- occ_download_get("0020688-240626123714530") %>% 
  occ_download_import()
nrow(occurrence)
# start with 72065 occurrences

# remove occurrences without depth information
occ_clean <- occurrence %>%
  filter(depth != "NA")
nrow(occ_clean)
# now we have 69385 occurrences

# remove occurrences without date information
occ_clean <- occ_clean %>%
  filter(year != "")
nrow(occ_clean)
# now 69363 occurrences

# downloaded the MBON occurrence data from OBIS so I can pull those datasetIDs to match to what we grabbed from GBIF
# you can find these data here: https://mapper.obis.org/?instituteid=23070
mbon <- read_csv("MBONdata/Occurrence.csv")

# matching the column name to the one in occ_clean to facilitate matching
names(mbon)[names(mbon) == "datasetid"] <- "datasetID"

# grabbing all of the unique & not empty datasetIDs from the MBON occurrence data frame
mbondatasets <- mbon %>%
  filter(!is.na(datasetID)) %>%
  distinct(datasetID)

# matching datasetIDs across the two data frames to determine what proportion of the occurrence data we grabbed comes from U.S. MBON projects
occ_ioos <- occ_clean %>%
  semi_join(mbondatasets, by = "datasetID")
(nrow(occ_ioos)/nrow(occ_clean))*100
# 68.7% of the occurrence records are from U.S. MBON projects

# map occurrences
pointMap(occs = occ_clean, land = land, landCol = "black", spName = "Ocyurus chrysurus", 
         ptSize = 2, ptCol = "orange")

# open the .shp file from WOA
# file was downloaded from https://www.ncei.noaa.gov/access/world-ocean-atlas-2023/bin/woa23.pl
temperature <- "woa23_decav_t00mn01.shp"
temp <- vect(temperature)

head(temp)
