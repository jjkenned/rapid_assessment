########################################################################################
##### Build Grid Spectrograms ~ Arrays without patterns and schedules unmatched ########
########################################################################################

#### prep ####
# clear work space
rm(list=ls())
dev.off()


# library required packages
library(stringr)
library(seewave)
library(suncalc)
library(tidyr)
library(lubridate)
library(sound)
library(tuneR)
library(oce)

# Combination of:
# 1) append_dates&select....R
# 2) getdatefordays...R
# 3) Create_jpegs_owgr....R

## To convert ## 
# - Change reference of sites to process from long files to list created earlier on
# - Loop through full file names as apposed to doing site at a time
# - Convert to function Form


# Set directories 
in.root = "//hemmera.com/Shared/ProjectScratch/106242-01 Bird and Bat Data/Rayrock Bird Data - RAW" # recording files location
out.root="C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Spectrograms" # output directory where results are kept


# Get files
full.file = list.files(in.root,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)



# Metadata  and sorting
meta = songmeter(file.name) # get metadata

meta$file.name = full.file

meta$or.day = yday(meta$time) # get ordinal date

meta$station_date = paste0(meta$prefix,"-",meta$or.day)# make station date ID

# summarize recordings per day and days per station
unique(meta$prefix) # what stations are available?


meta$size = as.numeric(file.size(meta$file.name))


# some QAQC
# missing.dat = meta[meta$size == 0,]
# write.table(missing.dat,"C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/missing_any_data.txt",sep = " ")

# remove empty files from list
meta = meta[meta$size>0,]

# Dplyr for ordering recordings within day 
meta_2 = meta %>% group_by(station_date) %>% mutate(night.seq = order(time)) %>% arrange(station_date,night.seq) 




station = unique(meta$prefix)[1]
for (station in unique(meta$prefix)){
  
  stn.dat = meta[meta$prefix == station,]
  
  for (night in )
  
}















