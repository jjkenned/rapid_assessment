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

# Specify directory where files are kept:

orig_dir = "D:/MKVI/" # where files are kept and not modified

cop_dir = "D:/TEMP/MKVI/" # where files are copied to and modified there

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


# Set directory to where your recordings are
setwd(cop_dir)

file.rename(list.files(pattern = "*.wav"), str_replace(list.files(pattern = "*.wav"),pattern = ".wav",replacement = "-0700.wav"))


