#################################################################
########### Combine LDFCS for rapid assessment ##################
#################################################################


# Re-set  your script when needed
# dev.off()
rm(list=ls())

# packages
library(OpenImageR)

## Required settings ##
dir_sep = "C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Check 2/SB02/index_nights" # where the files are kept
dir_comb = "C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Check 2/Combined/SB02" # where the combined files are to go
station = "RB01" # set station where recordings are from
nights = 18 # number of nights/days to combine
cols = 3 # number of columns to organize results into


# create directory for output
dir.create(dir_comb,recursive = T)

# list in files to make into jpg
img<-list.files(path = dir_sep,pattern = "*2Maps.png",recursive = T,full.names = T)


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
  text(x=0.07,y=0.07,labels = id,col="white",cex=0.3)
}

dev.off()



