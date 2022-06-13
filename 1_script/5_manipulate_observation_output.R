#################################################################
##### Read and Format Processed Spectrogram Species Data ########
#################################################################

#### prep ####
# clear work space
rm(list=ls())
dev.off()

library(tidyverse)
library(seewave)
library(lubridate)


################
### OPTION 1 ###
################

# combine processed species and frames output
# from full comunity analysis 



## If data kept elsewhere
# Read processed observation data
obs = read.csv(file = "C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Spectrograms/tracking.csv")
in.root = "//hemmera.com/Shared/ProjectScratch/106242-01 Bird and Bat Data/Rayrock Bird Data - RAW" # recording files location
chosen = read.csv(file = "C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/Process_Spec_Vis_2.csv")


# Keep only timeframes wanted
obs_hr1 = obs[substr(obs$Image,10,11) == "01",]
# table(substr(obs_hr1$Image,1,8)) # Check that we have 60 for each



# remove sessions without data for loop
sessions = obs_hr1$Image # keep track of processed sessions
obs_hr1 = obs_hr1[!(is.na(obs_hr1$X) | obs_hr1$X==""),]



# i = 1
for (i in 1:nrow(obs_hr1)){
  
  frame = obs_hr1[i,] # per frame observation
  img = frame$Image # get image ID for this frame
  sp = as.character(frame[2:ncol(frame)]) # convert species obs into Character vector
  sp = sp[!sp==""] # remove blank species observations 
  
  
  # DF to keep results from next loop
  out = data.frame(matrix(NA,nrow = length(sp),ncol = 2))
  colnames(out) = c("Image","sp_cnt")
  
  # loop through observations to find species counts
  for (j in 1:length(sp)){
    
    # fill in df 
    out$Image[j] = img
    out$sp_cnt[j] = sp[j]
    
    
  }
  
  
  # split by "_"
  out = separate(out,col = sp_cnt,into = c("species","days"),sep = "_")
  
  # assign to sessions 
  # j = 1
  for (j in 1:nrow(out)){
    
  # check which character values (1,2,3,4) are present in the session column
    have = str_extract(out$days[j],c("1","2","3","4"))
    have = have[!is.na(have)]
    
    out_keep = data.frame(matrix(NA,nrow = length(have),ncol = 3))
    colnames(out_keep) = c("Image","session","species")
    
    # return into dataframe
    out_keep$Image = out$Image[j]
    out_keep$species = out$species[j]
    out_keep$session = have
    
    if (i==1 & j==1){
      
      dat_out = out_keep
      
    } else (dat_out = rbind(dat_out,out_keep))
    
    
  }
  
  
  
}
 
## Now let's pull in the meta dta from the recording files and combine it with the spectrogram images 
## 




# Get files
full.file = list.files(in.root,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)



# Metadata  and sorting
meta = songmeter(file.name) # get metadata

meta$file.name = full.file

meta$or.day = yday(meta$time) # get ordinal date
meta$Date = as.Date(meta$time,format = "%d%b%Y",tz = "MST") # get date for visually helpful processing
meta$station_date = paste0(meta$prefix,"-",meta$or.day)# make station date ID

meta$size = as.numeric(file.size(meta$file.name)) # get file size


# remove empties
meta = meta[meta$size>0,]

# Dplyr for ordering recordings within day 
meta_2 = meta %>% group_by(station_date) %>% mutate(night.seq = order(time)) %>% arrange(station_date,night.seq) 

used = meta_2[meta_2$night.seq == 1,]


# now to the chosen recordings 
chosen = chosen[chosen$Use == "y",]
used = used[used$station_date %in% chosen$station_date,]

# now get rid of shit un-needed
used = used[c("prefix","time","file.name","Date","station_date")]

# now get date sequence 
used_2 = used %>% group_by(prefix) %>% mutate(session = order(time))


## Back to dat_out to format it for combination
dat_out$prefix = substr(dat_out$Image,1,8)

# group by station and day of recording 

dat = merge(dat_out,used_2,by=c("prefix","session"))

dat$frame = gsub("*.jpeg","",dat$Image) # remove jpeg 

# separate by "_" to get seconds in session
dat = separate(dat,col = frame,into = c("station","night_order","seconds"),sep = "_")

dat = dat[,-which(names(dat) %in% c("station","night_order"))] # remove extras

# add seconds to time for frame tiome
dat$seconds=as.numeric(dat$seconds)

dat$frame_time = dat$time+dat$seconds
names(dat)[names(dat) == "time"] <- c("rec_time")

# now save it! 

# write.csv(dat,file = "C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Spectrograms/RAYROCK_Bird_Observations.csv",row.names = F)



# now let's take a look at effort 
used_2 = used_2[,-which(names(used_2) %in% c("session","file.name","station_date"))]


used_2$time_short = strftime(used_2$time, format = "%H:%M")

used_2 = used_2[,-which(names(used_2) %in% c("time"))]

colnames(used_2)<-c("Station.ID","Date","Start.Time")
used_2$Session.Length = "60 mins"

# save it all up 
# write.csv(used_2,file = "S:/Projects/106242-01/07a Working Folder/BBS Analysis/211123_AECOM_Rayrock_ARU_Processed_Times_v0.1.csv",row.names = F)

# Let's get some volumes of data collected 
ind_track = read.csv(file = "C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/Process_Spec_Vis.csv")

# get max days for all this 
days = ind_track %>% group_by(prefix) %>% summarise(first_day = min(Date),
                                                    last_day = max(Date))

# write.csv(days,file = "S:/Projects/106242-01/07a Working Folder/BBS Analysis/211123_AECOM_Rayrock_Total_ARU_Days_v0.1.csv",row.names = F)

# get sixes of folder
folders = unique(dir(meta$file.name,recursive = T,full.names = T,include.dirs = T))
list.dirs(in.root)










################
### OPTION 2 ###
################





# combine meta data and frames for real time processing 
# where required for tracking exact files to open

meta_2 = read.csv("S:/ProjectScratch/398-173.07/ARUs - 2021/rw/jck_processing/full_meta.csv")

imgs = read.csv("S:/ProjectScratch/398-173.07/ARUs - 2021/rw/jck_processing/site_C_JPGs.csv")

# manipulate for combining

# clean and separate imgs
colnames(imgs) = c("order_rem","img")

# separate image back into it's base components 
imgs$img_base = gsub(".jpeg","",imgs$img) # remove jpeg and create new ID from it to keep the origional ID 
imgs_parts = separate(imgs,col = img_base, into = c("prefix","session_rem","session_ID","nights_rem","nights_ID","seconds"),sep = "_") # separate

# now the 'SMART' part! 
imgs_parts = imgs_parts[!grepl("rem",names(imgs_parts))] # remove all columns that contain 'rem'

imgs_parts$session_ID = as.numeric(imgs_parts$session_ID)
imgs_parts$nights_ID = as.numeric(imgs_parts$nights_ID)


# need to keep in meta data
keep = c("base.name","file.name","prefix","or.day","night.seq")
meta = meta_2[keep]

# change names etc
colnames(meta) = c("base.name","file.name","prefix","or.day","session_ID","nights_ID")

# group days into day groups 
## CAUTION: CURRENTLY THIS ONLY WORKS IF YOU ARE ONLY WORKING ON ONE SITE
all_nights = unique(meta$or.day)

# order nights 
meta$order = (meta$or.day - min(meta$or.day))+1


j=1
for (j in 1:floor((length(unique(dat_mid$or.day)))/ncells)){
  
  
  start_night = (j-1)*4+1
  end_night = start_night+3
  grp_night = all_nights[start_night:end_night]
  
  
  dat_ret = meta[meta$or.day %in% grp_night,]
  
  img_ret = imgs_parts[imgs_parts$session_ID %in% dat]
  
  
  
  if (j == 1){
    
    met_out = dat_ret
    
  } else (met_out = rbind(met_out,dat_ret))
  
  
}



































