#################################################################
########### Combine LDFCS for rapid assessment using timelapse ##################
#################################################################


# Re-set  your script when needed

rm(list=ls())
dev.off()
# packages
library(OpenImageR)
library(tidyverse)

##################################
#### Step 1 - Combine Indices#####
##################################


## Required settings ##

dir_sep = "P:/PMRA_processing/output.index.values/BIRD/2022/MKVI/by_night/MKVI-U-14" # where the files are kept
dir_return = "P:/PMRA_processing/Time_Lapse_Files/LDFCS/BIRD/2022/MKVI/MKVI-U-14"  # where the combined files are to go

# list in files to make into jpg
img<-list.files(path = dir_sep,pattern = "2Maps.png",recursive = T,full.names = T)
# img = img[file.size(img)>80000]

# set file path for keeping the images in a place that can be referenced by the timelapse database
imgs = data.frame(full.name = img) # turn into dataframe
imgs$full.directory = dirname(imgs$full.name) # get directory for visualization

imgs$date = basename(imgs$full.directory) # date for name
imgs$station = basename(dirname(imgs$full.directory)) # station ID for reference

# Make new dir name from extracted info
imgs$new.dir = dir_return
imgs$new.name = paste0(imgs$new.dir,"/",imgs$station,"_",imgs$date,".jpg")

# copy file to new location
for(i in 1:nrow(imgs)){
  
  if (!dir.exists(imgs$new.dir[i])){dir.create(imgs$new.dir[i],recursive = T)}
  
}

file.copy(from = imgs$full.name,to = imgs$new.name,recursive = T)


