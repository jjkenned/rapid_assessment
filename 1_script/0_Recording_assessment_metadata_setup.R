###################################################
#### Recording Assessment and Meta-data Setup ##### 
###################################################

# Re-set  your script when needed
dev.off()
rm(list=ls())

# Library required packages
library(seewave)
library(tuneR)
library(av)

##### set ID for working directories to be used during analysis #### 
dir.dat="D:/" # where frame data is kept
setwd(dir.dat) # set working directory 


##### recording listing and sorting ####
# List all files and extract metadata
Server=data.frame(File=list.files(recursive=T, pattern='*.wav',full.names = F)) # read all recording names
Server$Full_name=paste0(dir.dat,Server$File) # just basename
Server$File<-as.character(Server$File) # 

Meta=songmeter(Server$File) #extract metadata
Meta$name<-Server$File# re-combine so metadata is associated with file name
Meta$full_name<-as.character(Server$Full_name)
Meta$length=NA

# extract recording lengths

# make simple function to apply across iterations
# gt.lngth = function(x){
#   
#   dat = av_media_info(x)$duration
#   
#   return(dat)
#   }
# 
# # apply on column you want
# Meta$length = lapply(Meta$full_name, gt.lngth)


# LOOP till I can figure out how function fucking work

for (i in 1:nrow(Meta)){
  
  Meta$length[i] = av_media_info(Meta$full_name[i])$duration
  
  if(i%%100==0){
    print(i)
  }
}


# save we dont have to do again
colnames(Meta) # check colnames 
keep = c("time","name","full_name","length")

meta_save = Meta[keep]


# Make sure basename is really basename
meta_save$name = basename(meta_save$name)


# full rec list save
#dir.create("C:/Users/jeremiah.kennedy/Documents/Working/PMRA/tracking/",recursive = T)
#write.csv(meta_save,file = "C:/Users/jeremiah.kennedy/Documents/Working/PMRA/tracking/full_rec_list_Nov.csv")
























