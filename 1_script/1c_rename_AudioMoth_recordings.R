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

# libraries
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)
library(lubridate)

# Specify directory where files are kept:

orig_dir = "F:/PMRA_SAR/Recordings/BIRD/2022/MKBI" # where files are kept and not modified

cop_dir = "F:/PMRA_SAR/Processing//BIRD/2022/MKBI/Copied_recordings/BIRD/2022/MKBI" # where files are copied to and modified there


##############################
#### Part 1 ~ Copy Files######
##############################


# create directory 
if (!dir.exists(cop_dir)){dir.create(cop_dir,recursive = T)}


# Copy files (WAV for audiomoth)
files<-data.frame(Full_name = list.files(orig_dir,pattern = ".WAV",recursive = T,full.names = T))# list
files$base = basename(files$Full_name) # basename with no prefix
files$station = basename(dirname(files$Full_name)) # station name from enclosing folder
unique(files$station)# check what prefixes you're using for station ID
files$new_base = gsub(".WAV",".wav",files$base)

# loop to add prefix (station ID)
for (i in 1:nrow(files)) {
  
  files$new_base_final[i] = paste0(files$station[i],"_",files$new_base[i])
  
  
}

# loop to create final name

for (i in 1:nrow(files)){
  
  files$Full_new[i] = gsub(files$base[i],files$new_base_final[i],files$Full_name[i]) 
  
  
  
}

# loop to rename 

for (i in 1:nrow(files)){
  
  file.rename(files$Full_name[i],files$Full_new[i])
  
}




















































