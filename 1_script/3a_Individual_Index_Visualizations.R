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
dir_sep = "S:/ProjectScratch/398-173.07/PMRA_WESOke/indices/MKSC/MKSC-U01/by_night" # where the files are kept
dir_return = "S:/ProjectScratch/398-173.07/PMRA_WESOke/indices/MKSC/MKSC-U01/only_visualizations" # where the combined files are to go

# list in files to make into jpg
img<-list.files(path = paste0(dir_sep),pattern = "*2Maps.png",recursive = T,full.names = T)
img = img[file.size(img)>80000]

# set file path for keeping the images in a place that can be referenced by the timelapse database
imgs = data.frame(full.name = img) # turn into dataframe
imgs$full.directory = dirname(imgs$full.name) # get directory for visualization

imgs$date = basename(imgs$full.directory) # date for name
imgs$station = basename(dirname(imgs$full.directory)) # station ID for reference

# Make new dir name from extracted info
imgs$new.dir = gsub("by_night","only_visualizations",dirname(imgs$full.directory))
imgs$new.name = paste0(imgs$new.dir,"/",imgs$station,"_",imgs$date,".jpg")

# copy file to new location
for(i in 1:nrow(imgs)){
  
  if (!dir.exists(imgs$new.dir[i])){dir.create(imgs$new.dir[i],recursive = T)}
  
}

file.copy(from = imgs$full.name,to = imgs$new.name,recursive = T)


