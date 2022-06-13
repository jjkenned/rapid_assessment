#######################################################################################
########### Combine files by night for running LDFCS Script ##################
#######################################################################################


# Re-set  your script when needed
dev.off()
rm(list=ls())
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)
library(parallel)
library(tuneR)
library(phonfieldwork)
library(sound)


#### This script is helpful for processing Swift recordings that tend to start with the most annoying sounds. 

# set directory 

# Specify directory 
cop_dir = "D:/TEMP/MUCH" # where files are copied to and modified there


# read files
files = data.frame(Full = list.files(cop_dir,pattern = "*-0700.wav",recursive = T,full.names = T))
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


# start by renaming your files so that they are all in folders that represent each night 
# file.grps = file.grps[file.grps$night.ID>61,]
file.grps$directory = dirname(file.grps$Full)
#file.grps$new.full = paste0(file.grps$directory,"/",formatC(file.grps$night.ID,width = 2,flag = 0),"/",file.grps$name)
#file.grps$new.full = gsub(pattern = "*.wav",replacement = "-0700.wav",x = file.grps$new.full)

# now rename

make.paths = paste0(unique(dirname(file.grps$Full)),"/") # list of directories to transfer to

#lapply(make.paths, function(x) dir.create(x,recursive = T)) # function to create directories

#file.rename(from = file.grps$Full,to = file.grps$new.full) # rename all files


# now we can combine within folders 
#lapply(X = make.paths,function(x) concatenate_soundfiles(x))


### rename ####
#recs = list.files(night,pattern = "*wav",full.names = T, recursive = T)




for (i in 74:length(make.paths)){
  
  recs = list.files(make.paths[i],pattern = "*.wav",full.names = T, recursive = T)
  sounds = lapply(recs, function(x) readWave(x,from = 6, to = Inf,units = 'seconds'))
  sound_out = do.call(bind,sounds)
  callit = paste0(dirname(recs[1]),"/","combined_",basename(recs[1]))
  writeWave(sound_out,filename = callit)
    
  print(i)
  
}

## now move them to their own folders
comb = data.frame(Full = list.files(path = cop_dir,pattern = "combined", recursive = T,full.names = T))
comb$new.full = paste0("D:/TEMP/MUCH/combined/",basename(comb$Full))

dir.create(dirname(comb$new.full[1]))
file.rename(from = comb$Full,to = comb$new.full)







































