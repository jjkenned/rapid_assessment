#######################################################################################
########### Re-name files for processing in Analysis Programs script ##################
#######################################################################################

## IMPORTANT ~ READ BEFORE RUNNING Script ##
# This script re-names files and could irreversibly change your files if done wrong
# Make sure that you are running this script on a copy of your data
# You can move the data manually or, provided below, use the first part of this script


# Re-set  your script when needed
dev.off()
rm(list=ls())
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)

##############################
#### Part 1 ~ Copy Files######
##############################



# Specify directory where files are kept:

orig_dir = "D:/MUCH/" # where files are kept and not modified

cop_dir = "D:/TEMP/MUCH/" # where files are copied to and modified there

# create directory 
if (!dir.exists(cop_dir)){dir.create(cop_dir,recursive = T)}


# Copy files
files<-list.files(orig_dir,pattern = "*.wav",recursive = T,full.names = T) # list
i=1
for (i in 1:length(files)){
  
  new_dir = paste0(dirname(gsub(pattern = orig_dir,replacement = cop_dir,files[i])),"/")
  
  if(!dir.exists(new_dir)){dir.create(new_dir,recursive = T)}
  
  file.copy(files[i], new_dir, recursive = T) # copy
  
  if (i%%100==0){print(i)}
  
}


##############################
#### Part 2 ~ Name Files######
##############################

# Specify directory 
cop_dir = "D:/TEMP/MUCH" # where files are copied to and modified there

# Set directory to where your recordings are
setwd(cop_dir)

dat = data.frame(Full = list.files(cop_dir,pattern = "*.wav",recursive = T,full.names = T))
dat$new.name = paste0(cop_dir,"/",basename(dat$Full))

file.rename(from = dat$Full,to=dat$new.name)

file.rename(list.files(pattern = "*.wav",recursive = T), str_replace(list.files(pattern = "*.wav",recursive = T),pattern = ".wav",replacement = "-0700.wav"))


# Next step is to change percieved time for binding
# loop through stations and nights to group data by night and then visualize it across the nights 
# you will need to change the names to reflect these occuring in the daytime


# read files
files = data.frame(Full = list.files(cop_dir,pattern = "*.wav",recursive = T,full.names = T))
files$name = basename(files$Full)

# extract metadata
Meta = songmeter(files$Full)
Meta$Full = files$Full # transfer full name to new DF
Meta$name = files$name # transfer basename
Meta$station = basename(Meta$prefix) # get rid of some dumn parent directories 

# get rid of extraneous columns
keep = c("Full","name","station","time","year","month","day","hour","min","sec")
files = Meta[keep]


###### Dates are frustrating ###### 

# let's do it the hard way !
file.grps = files %>% group_by(station,year,month,day) %>% mutate(group_id = cur_group_id()) # group by date
# quick function for translating day number into night number 
# day = night ID, hr = hour in 24 hr clock (as integer), split = when to cut off the nights from one another (usually 12...noon)
d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}




# apply function accross the dataframe 
file.grps$night.ID = mapply(d2n.func,file.grps$group_id,file.grps$hour,12) 

plot(file.grps$group_id,file.grps$night.ID) # visualize to make sure it makes sense

# Make new name column for renaming
# you will need to remove some things before processing anyway if this is an SM3 set of recordings 

file.grps$new_name = gsub(pattern = "*_0\\+1_*",replacement = "_",file.grps$name) # SM3s can get merked 

# Now we can loop through the files to rename their asses!! 
# You will need to start by setting the start time you wanna use
start.hr = 8
start.min = 0
start.sec = 0


# night = unique(file.grps$night.ID)[1]
for (night in unique(file.grps$night.ID)){
  
  
  # night filter
  night_dat = file.grps[file.grps$night.ID == night,]
  
  # sort by time
  night_dat = night_dat[order(night_dat$time),]
  
  # loop across to rename each individually
  # i=3
  for (i in 1:nrow(night_dat)){
    
    
    if(i==1) {
      night_dat$hour[i]=start.hr
      night_dat$min[i]=start.min
      night_dat$sec[i]=start.sec 
    } else {
      start.time.seconds=(night_dat$hour[i-1]*60*60)+(night_dat$min[i-1]*60)+(night_dat$sec[i-1]) # get start time in seconds
      add.time = av_media_info(night_dat$Full[i-1])$duration # recording duration
      new.time.seconds = start.time.seconds + add.time # add times to see what it should start as
      night_dat$hour[i] = floor(new.time.seconds/3600)# convert back to hours minutes seconds with NO PACKAGE BECAUSE FUCK TIME! 
      night_dat$min[i] = floor(new.time.seconds/60)-(night_dat$hour[i]*60) # mintues 
      night_dat$sec[i] = new.time.seconds - (night_dat$hour[i]*3600+night_dat$min[i]*60) # seconds
      
      # and assign dates so we dont get no problems corsssssssssing across the nightssssss
      night_dat$year[i]=night_dat$year[1]
      night_dat$month[i]=night_dat$month[1]
      night_dat$day[i]=night_dat$day[1]
      }
    
    
  }
  
  # save as some other dataframe  
  if (night == unique(file.grps$night.ID)[1]) {dat_out = night_dat} else (dat_out = rbind(dat_out,night_dat))
  
  print(paste0("complete night ",night," of ",max(unique(file.grps$night.ID)))) # nights may not line up proppertly 
  
}


# Let's fucking get it going 


dat_out$new_name_final = paste0(dat_out$station,"_",dat_out$year,
                                formatC(dat_out$month,width = 2,flag = 0),
                                formatC(dat_out$day,width = 2,flag = 0),"_",
                                formatC(dat_out$hour,width=2,flag = 0),
                                formatC(dat_out$min,width = 2, flag = 0),
                                formatC(dat_out$sec,width=2,flag=0),"-0700.wav")



# make new full path
dat_out$new.Full = paste0(dirname(dat_out$Full),"/",dat_out$new_name_final)


# Rename everything 
file.rename(from = dat_out$Full, to = dat_out$new.Full)






















































