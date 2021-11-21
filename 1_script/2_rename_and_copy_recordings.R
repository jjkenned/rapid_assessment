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



orig_dir = "//hemmera.com/Shared/ProjectScratch/106242-01 Bird and Bat Data/Rayrock Bird Data - RAW/Check 2/SB02" # where files are kept and not modified

cop_dir = "C:/Users/jeremiah.kennedy/Documents/Rayrock/Check 2/SB02/Data" # where files are copied to and modified there

# create directory 
dir.create(cop_dir,recursive = T)

# Copy files
files<-list.files(orig_dir,pattern = "*.wav",recursive = T,full.names = T) # list
file.copy(files,cop_dir,recursive = T) # copy

# Set directory to where your recordings are
setwd(cop_dir)

file.rename(list.files(pattern = "*.wav"), str_replace(list.files(pattern = "*.wav"),pattern = ".wav",replacement = "-0700.wav"))


