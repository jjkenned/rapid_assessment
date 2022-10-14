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
detect.db = DBI::dbConnect(RSQLite::SQLite(), "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/TimelapseData_merged.ddb")

raw.detect = tbl(detect.db,"DataTable") 
detect= data.frame(raw.detect)


#### Start by summarizing what was processed ####

# get station IDs
detect$station = substr(detect$RelativePath,1,7)
unique(detect$station) # check that this worked

# get night ID
detect$night = substr(detect$RelativePath,9,11)
unique(detect$night)

# minutes processed or unprocessed 
effort = detect %>% group_by(station,Processed) %>% summarise(minutes = n())

pos.effort = detect[detect$Processed == "true",] %>% group_by(station) %>% summarise(minutes = n(),nights = n_distinct(night))

detect$LEYE = as.numeric(detect$LEYE)
detect$OSFL = as.numeric(detect$OSFL)
detect$HOGR = as.numeric(detect$HOGR)
detect$PEFA = as.numeric(detect$PEFA)
detect$RNPH = as.numeric(detect$RNPH)
detect$RUBL = as.numeric(detect$RUBL)
detect$SEOW = as.numeric(detect$SEOW)
detect$YERA = as.numeric(detect$YERA)

detect$BANS = as.numeric(detect$BANS)
detect$BARS = as.numeric(detect$BARS)
detect$CONI = as.numeric(detect$CONI)
detect$EVGR = as.numeric(detect$EVGR)
detect$HASP = as.numeric(detect$HASP)



# let's do detections
detections = detect[detect$Processed=="true",] %>% group_by(station) %>% summarise(LEYE = n_distinct(night[LEYE>0]),
                                                                                         OSFL = n_distinct(night[OSFL>0]),
                                                                                         HOGR = n_distinct(night[HOGR>0]),
                                                                                         PEFA = n_distinct(night[PEFA>0]),
                                                                                         RNPH = n_distinct(night[RNPH>0]),
                                                                                         RUBL = n_distinct(night[RUBL>0]), 
                                                                                         SEOW = n_distinct(night[SEOW>0]),
                                                                                   BANS = n_distinct(night[BANS>0]),
                                                                                   BARS = n_distinct(night[BARS>0]),
                                                                                   CONI = n_distinct(night[CONI>0]),
                                                                                   EVGR = n_distinct(night[EVGR>0]),
                                                                                   HASP = n_distinct(night[HASP>0]),
                                                                                   YERA = n_distinct(night[YERA>0]))

# combine effort and detections
results = merge(pos.effort,detections,by = "station")



SongCounts.per.min = detect[detect$Processed=="true",] %>% group_by(File) %>% summarise(   LEYE = sum(LEYE),
                                                                                   OSFL = sum(OSFL),
                                                                                   HOGR = sum(HOGR),
                                                                                   PEFA = sum(PEFA),
                                                                                   RNPH = sum(RNPH),
                                                                                   RUBL = sum(RUBL), 
                                                                                   SEOW = sum(SEOW),
                                                                                   BANS = sum(BANS),
                                                                                   BARS = sum(BARS),
                                                                                   CONI = sum(CONI),
                                                                                   EVGR = sum(EVGR),
                                                                                   HASP = sum(HASP),
                                                                                   YERA = sum(YERA))




# start by pulling out site, date and time
SongCounts.per.min$station = substr(SongCounts.per.min$File,1,7)
SongCounts.per.min$date = substr(SongCounts.per.min$File,9,16)
SongCounts.per.min$hour = substr(SongCounts.per.min$File,18,23)




SongRate.per.hour = SongCounts.per.min %>% group_by(station,date,hour) %>% summarise( LEYE = 60*sum(LEYE)/n(),
                                                                                        OSFL = 60*sum(OSFL)/n(),
                                                                                        HOGR = 60*sum(HOGR)/n(),
                                                                                        PEFA = 60*sum(PEFA)/n(),
                                                                                        RNPH = 60*sum(RNPH)/n(),
                                                                                        RUBL = 60*sum(RUBL)/n(), 
                                                                                        SEOW = 60*sum(SEOW)/n(),
                                                                                        BANS = 60*sum(BANS)/n(),
                                                                                        BARS = 60*sum(BARS)/n(),
                                                                                        CONI = 60*sum(CONI)/n(),
                                                                                        EVGR = 60*sum(EVGR)/n(),
                                                                                        HASP = 60*sum(HASP)/n(),
                                                                                        YERA = 60*sum(YERA)/n(),
                                                                                        min_per_hr = n())




for (i in 1:nrow)







# check individual records
SongCounts.per.hour_4 = SongCounts.per.hour[SongCounts.per.hour$station=="SUBBS04",]









# save the data
write.csv(results,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/results.csv",row.names = F)

write.csv(SongCounts.per.min,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/results_song_counts_per_minute.csv",row.names = F)

write.csv(SongCounts.per.hour,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/results_song_counts_per_hour.csv",row.names = F)

write.csv(SongRate.per.hour,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/RayRock_Specs/results_song_Rate_per_hour.csv",row.names = F)

