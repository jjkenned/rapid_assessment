###################################################
#### Recording Assessment and Meta-data Setup ##### 
###################################################

# Re-set  your script when needed
dev.off()
rm(list=ls())

# Library required packages
library(seewave)
library(tuneR)

##### set ID for working directories to be used during analysis #### 
dir.dat="C:/Users/jeremiah.kennedy/Documents/PMRA/Code/rapid_assessment/0_data/" # where frame data is kept
setwd(dir.dat) # set working directory 


##### recording listing and sorting ####
# List all files and extract metadata
Server=data.frame(File=list.files(recursive=T, pattern='*.wav',full.names = F)) # read all recording names
Server$Full_name=paste0(dir.dat,Server$File) # just basename
Server<-as.character(Server) # 

Meta=songmeter(Server$File) #extract metadata
Meta$name<-Server$File# re-combine so metadata is associated with file name
Meta$full_name<-Server$Full_name
Meta$length=NA

# extract recording lengths

for (i in 1:nrow(Meta)){
  sound=readWave(Meta$full_name[i]) # read recordings
  length=round(length(sound@left)/sound@samp.rate,2)/60 # get recording length in seconds and convert to minutes
  Meta$length[i]=length
}

# 


# 







