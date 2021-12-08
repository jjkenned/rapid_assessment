#################################################################
########### Combine LDFCS for rapid assessment ##################
#################################################################


# Re-set  your script when needed
# dev.off()
rm(list=ls())
dev.off()
# packages
library(OpenImageR)
library(tidyverse)

##################################
#### Step 1 - Combine Indices#####
##################################


## Required settings ##
dir_sep = "D:/TEMP/LDFS/by night/" # where the files are kept
dir_comb = "D:/TEMP/LDFS/Combined/" # where the combined files are to go
station = "MKVI-U03-010" # set station where recordings are from
nights = 35 # number of nights/days to combine
cols = 7 # number of columns to organize results into


# create directory for output
dir.create(paste0(dir_comb),recursive = T)

# list in files to make into jpg
img<-list.files(path = paste0(dir_sep,station),pattern = "*2Maps.png",recursive = T,full.names = T)


# create the name to be given to the file being written
out.name=file.path(dir_comb,paste0(station,"_indices_grid",".jpg"))

jpeg(filename = out.name, width = 3000, height = 2000, res = 1200)
par(mai=rep(0,4)) # no margins required 
# You can change 25 to length img, but if it's not divisable by ncol then you're pooched
layout(matrix(1:nights, ncol=cols, byrow=TRUE)) # set layout of your plots depending on howmany recordings etc


# loop for filling in layout
# i=1
for(i in 1:length(img)) { # complete for all images in list-img
  # subset to get night ID (ynight)
  id<-basename(dirname(img[i])) # personalize depending on name
  plot(NA,xlim=0:1,ylim=0:1, bty="n", xaxt='n', yaxt='n') # get rid of xy values and marks
  rasterImage(readImage(img[i]),0,0,1,1) # print image
  text(x=0.2,y=0.9,labels = id,col="white",cex=0.15)
}

dev.off()

################################################
#### Step 2 - Make datasheet for processing#####
################################################

# Re-set  your script when needed
# dev.off()
rm(list=ls())
dev.off()

# set directories 
dirs_in = "D:/TEMP/LDFS/by night/"

nights = data.frame(dir = dirname(list.files(dirs_in,full.names = T,pattern = "*2Maps.png",recursive = T)))

night = separate(data = nights,col = dir,into = c("base_rem","base2_rem","base3_rem","base4_rem","empty_rem","station","night"),sep = "/")
night = night[!grepl("rem",colnames(night))]



# save all data
write.csv(night,file = "D:/TEMP/LDFS/Combined/processing_nights_updated.csv",row.names = F)

############################################################
#### Step 3 - Convert back to days to choose recordings#####
############################################################

# packages
library(seewave)
# Re-set  your script when needed

rm(list=ls())
dev.off()

# read data
night = read.csv(file = "D:/TEMP/LDFS/Combined/processing_nights.csv")


# keep only keep nights
night <- night[night$chosen %in% "Y",]

# now let's check out the recordings we wanna choose from 
in.root = "D:/MKVI/" # recording files location


# Get files
full.file = list.files(in.root,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)


# Metadata  and sorting
meta = songmeter(file.name) # get metadata
meta$name = file.name
meta$full = full.file

# Keep those that apply 
meta_2 = meta[meta$prefix %in% night$station,]

# group by so you can run order across it
file.grps = meta_2 %>% group_by(prefix,year,month,day) %>% mutate(group_id = cur_group_id())

d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}


file.grps$night.ID = mapply(d2n.func,file.grps$group_id,file.grps$hour,12) 

# now we can filter by night 
# group out date
night$day = as.numeric(substr(night$date,7,8))
night$month = as.numeric(substr(night$date,5,6))
night$year = as.numeric(substr(night$date,1,4))

# order it up 
i=1
for (i in 1:nrow(night)){
  
  dat_in = night[i,]
  
  grps_in = unique(file.grps[file.grps$year %in% dat_in$year &
                        file.grps$month %in% dat_in$month &
                        file.grps$day %in% dat_in$day &
                        file.grps$hour<12,]$night.ID)
  
  # now sort by this night ID
  dat_mid = file.grps[file.grps$prefix %in% dat_in$station & file.grps$night.ID %in% grps_in,]
  
  # re3turn
  if (i == 1){dat_out = dat_mid} else (dat_out = rbind(dat_out,dat_mid))
  
  
}

# save this file for next scritpt
# write.csv(dat_out,file = "D:/TEMP/LDFS/Combined/chosen_recordings_trial.csv", row.names=F)




