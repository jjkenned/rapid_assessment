###########################################
#### Summarizing Spectrogram Scanning ##### 
###########################################

# Re-set  your script when needed
dev.off()
rm(list=ls())


# Library required packages
library(tidyverse)
library(RSQLite)


## Read data from database
# Database connection
detections = DBI::dbConnect(RSQLite::SQLite(), "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/TimelapseData_merged.ddb")

night.use = tbl(detections,"DataTable") 
night.use = data.frame(night.use)


##### Keep nights that are required for processing #####
uses = night.use[night.use$Process=="Process",]
uses$station = substr(uses$File,1,7) # get station from file name
