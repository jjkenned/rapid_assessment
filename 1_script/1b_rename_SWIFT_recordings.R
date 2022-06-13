#######################################################################################
########### Re-name SWIFT files for processing in Analysis Programs script ############
#######################################################################################

## IMPORTANT ~ READ BEFORE RUNNING Script ##
# This script re-names files and could irreversibly change your files if done wrong
# Make sure that you are running this script on a copy of your data
# You can move the data manually or, provided below, use the first part of this script


# Re-set  your script when needed
dev.off()
rm(list=ls())

# libraries
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)

##############################
#### Part 1 ~ Copy Files######
##############################



# Specify directory where files are kept:

orig_dir = "F:/processing/trimmed_recordings/BIRD/2022/REN" # where files are kept and not modified
cop_dir = "F:/processing/copied_recordings/BIRD/2022/REN" # where files are copied to and modified there

# create directory 
if (!dir.exists(cop_dir)){dir.create(cop_dir,recursive = T)}


# List files
files<-list.files(orig_dir,pattern = ".wav",recursive = T,full.names = T) # list

## SWIFT specific Section 
# List all files in directories and remove anything from the base file name that isn't x folders deep
files=data.frame(full=files)
files$name = basename(files$full) # get file name
files$station = substr(files$name,1,6)

# now build directory
files$new.dir = paste0(cop_dir,"/",files$station,"/",files$name)

for (i in 1:nrow(files)){
  
  if(!dir.exists(dirname(files$new.dir[i]))){dir.create(dirname(files$new.dir[i]))}
  
  file.rename(from = files$full[i], to = files$new.dir[i])
  
  
  if (i%%100==0){print(i)}
  
}



# New directory copy function
move_rec = function(orig_dir,cop_dir,files){
  
  new_dir = paste0(dirname(gsub(pattern = orig_dir,replacement = cop_dir,files)),"/")
  
  if(!dir.exists(new_dir)){dir.create(new_dir,recursive = T)}
  
  file.copy(files, new_dir, recursive = T) # copy
  
}

#lapply(files, FUN = function(x) 
 # move_rec(orig_dir = orig_dir,cop_dir = cop_dir,files = x))



# i=1

# 
# 
# for (i in 1:length(files)){
#   
#   new_dir = paste0(dirname(gsub(pattern = orig_dir,replacement = cop_dir,files[i])),"/")
#   
#   if(!dir.exists(new_dir)){dir.create(new_dir,recursive = T)}
#   
#   file.copy(files[i], new_dir, recursive = T) # copy
#   
#   if (i%%100==0){print(i)}
#   
# }


##############################
#### Part 2 ~ Name Files######
##############################

# Specify directory 
# cop_dir = "D:/TEMP/MUCH" # where files are copied to and modified there



# read files
files = data.frame(Full = list.files(cop_dir,pattern = ".wav",recursive = T,full.names = T))
files$name = basename(files$Full)


### comment ####
# Make sure you use the songmeter command on your basename and not the full filename
# The command get's confused with the full path

## replace "_" with "-"
#substr(files$name,4,4)="-"
#files$new.name = paste0(dirname(files$Full),"/",files$name)

#file.rename(from = files$Full,to = files$new.name)

# extract metadata
Meta = songmeter(files$name)
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





# Now we can loop through the files to rename
# You will need to start by setting the start time you wanna use
start.hr = 4
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
      add.time = ceiling(av_media_info(night_dat$Full[i-1])$duration) # recording duration
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
  
  print(paste0("complete night ",night," of ",max(unique(file.grps$night.ID)))) # nights may not line up properly 
  
}



# manually recreate the names based on recording times etc
dat_out$new_name_final = paste0(dat_out$station,"_",dat_out$year,
                                formatC(dat_out$month,width = 2,flag = 0),
                                formatC(dat_out$day,width = 2,flag = 0),"_",
                                formatC(dat_out$hour,width=2,flag = 0),
                                formatC(dat_out$min,width = 2, flag = 0),
                                formatC(dat_out$sec,width=2,flag=0),"-0700.wav")




### SongMeter 3 Only #### 
dat_out$new_name_final = gsub(pattern = "*_0\\+1_*",replacement = "_",dat_out$new_name_final) # SM3s can get merked 

# make new full path
dat_out$new.Full = paste0(dirname(dat_out$Full),"/",dat_out$new_name_final)


# check if you have extras
dat_check = dat_out[nchar(dat_out$new.Full) > nchar(dat_out$new.Full[1]),]

# remove if you need to
dat_return = dat_out[!dat_out$new.Full %in% dat_check$new.Full,]

# Rename everything 
file.rename(from = dat_return$Full, to = dat_return$new.Full)






















































