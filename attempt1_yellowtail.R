library(dplyr)
library(rgbif)

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
  filter(eventDate != "")
nrow(occ_clean)
# now 69363 occurrences

# downloaded the MBON occurrence data from OBIS so I can pull those datasetIDs to match to what we grabbed from GBIF
mbon <- read_csv("MBONdata/Occurrence.csv")

#matching the column name to the one in occ_clean to facilitate matching
names(mbon)[names(mbon) == "datasetid"] <- "datasetID"

# grabbing all of the unique & not empty datasetIDs from the MBON occurrence data frame
# you can find these data here: https://mapper.obis.org/?instituteid=23070
mbondatasets <- mbon %>%
  filter(!is.na(datasetID)) %>%
  distinct(datasetID)

# matching datasetIDs across the two data frames to determine what proportion of the occurrence data we grabbed comes from U.S. MBON projects
occ_ioos <- occ_clean %>%
  semi_join(mbondatasets, by = "datasetid")
(nrow(occ_ioos)/nrow(occ_clean))*100
# 68.7% of the occurrence records are from U.S. MBON projects
