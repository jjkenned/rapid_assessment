#######################################################################################
########### Re-name files for SM3 type data that is coppied ##################
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

# list wav files 
dat = data.frame(Full = list.files(dir,pattern = ".png",recursive = T,full.names = T))

##### Naming patterns you want to change ####
# REMOVE
# 1) _0+1_ from SM3 standard recordings - Remove this and replace with _
# ADD
# 2)  -0800 for time offset. Not entirely sure if needed, but we will see if it doesn't work

# Remove 0+1
dat$new_name = gsub(pattern = "*_0\\+1_*",replacement = "_",dat$Full) 

# add timezone offset 
dat$new_name = gsub(pattern = ".wav",replacement = "-0800.wav",dat$new_name)

# Rename files from above list of changes
# file.rename(from = dat$Full,to=dat$new_name)



# you should now be ready to move on
