#######################################################################################
########### Re-name files for Swift type data that is coppied ##################
#######################################################################################

## IMPORTANT ~ READ BEFORE RUNNING Script ##
# This script re-names files and could irreversibly change your files if done wrong
# Make sure that you are running this script on a copy of your data
# You can move the data manually (see 1_rename_and_copy_recordings.R) or run this on a pre-exsisting copy
# 


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



# Specify directory where recording files are kept:
dir = "E:/processing/output.index.values/BIRD/2022/MKVI" # where files are kept

# list png files 
dat = data.frame(Full = list.files(dir,pattern = ".png",recursive = T,full.names = T))


# now get filename for confirmation 
dat$name=basename(dat$Full)

# for (i in 1:nrow(dat)){
  
 # unlink(dat$Full[i])
  
  if (i%%1000==0){print(i)}
  
}

