#######################################
#### Making Spectrograms with SoX ##### 
#######################################

# Re-set  your script when needed
dev.off()
rm(list=ls())


# Library required packages
library(seewave)
library(tuneR)
library(readxl)
library(lubridate)
library(av)
library(tidyverse)
library(magick)
# set functions you will want to use 

# use function to convert day to night ID
d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}



# Set locations for source folder and destination folder 
# you may also want to have a temporary folder 


SourceFolder = "S:/ProjectScratch/398-173.07/PMRA_WESOke/recordings/MKSC" #where your recording files are kept
OutputFolder = "S:/ProjectScratch/398-173.07/PMRA_WESOke/Spectrograms/MKSC" # where saving images


# list the files you want
full.file = list.files(SourceFolder,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)


# Get metadata for looping
meta = songmeter(file.name)
meta$file.name = full.file

#### Add selection list of files or nights #### 

# if you have a list of nights to process import here
night.use = read.csv(file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/indices/MKSC/MKSC-U01/only_visualizations/TimelapseData_merged.csv",stringsAsFactors = F)
night.use = night.use[c("File","RelativePath","Process")] # remove what isnt required 


### Check if playback surveys are from the same night ##### 

# if you have survey night data from playbck sessions, include it here
playback = read_xlsx(path = "S:/Projects/106381-01/06 Data/HSP&PMRA/Playback_Surveys/2021/MKVI_2021_Visit_Data.xlsx",sheet = 1)


# let's use these to filter our data
playback = playback[c("Full_Station_ID","Date","Start_Time")] # playback surveys

playback$or.day = yday(playback$Date) # set ordinal date values

playback$hour = hour(playback$Start_Time) # get hour 

playback<-playback[!is.na(playback$Full_Station_ID),] # remove nas

playback = playback[c("Full_Station_ID","Date","or.day","hour")] # removed what isnt needed

# get site nights for the playback sessions 
playback$site = gsub(x = substr(playback$Full_Station_ID,1,8),pattern = "T",replacement = "U")  # site ID

playback$or.night = mapply(d2n.func,playback$or.day,playback$hour,12)


# now convert back to date
playback$new.date = as.character(as.Date(playback$or.night,origin = "2020-12-31"))
playback$new.date = gsub("-","",playback$new.date)

dont_use = unique(playback[c("site","new.date")])

##### back to filtered nights #####
uses = night.use[night.use$Process=="x",c("station","night")]
uses$site = substr(uses$station,1,8)
uses = uses[c("night","site")]
colnames(dont_use) = c("site","night")


# moment of truth
check = merge(uses,dont_use,by = c("site","night"))





### NOW  continue

## work with time carefuly 
meta$date = paste(meta$year,formatC(meta$month,width = 2,flag = 0),formatC(meta$day,width = 2,flag = 0),sep = "-")


meta$or.day = yday(as.Date(meta$date,format = "%Y-%m-%d")) # get ordinal date



# summarize recordings per day and days per station
unique(meta$prefix) # what stations are available?

meta$size = as.numeric(file.size(meta$file.name)) #  size of the files

# Now let's see what's gonna get processed 
night.use$or.night = yday(as.Date(as.character(substr(night.use$File,14,22)),format = "%Y%m%d"))

uses = night.use[night.use$Process=="Process",]
uses$station.night = paste0(uses$RelativePath,"_",uses$or.night)

# convert to night ID and other for recordings
meta$or.night = mapply(d2n.func,meta$or.day,meta$hour,12)

meta$station.night = paste0(meta$prefix,"_",meta$or.night)# make night ID

# now filter by the chosen night IDs
meta = meta[meta$station.night %in% uses$station.night,]


# check
# meta[!yday(meta$Date)==meta$or.day,]


# Get file duration in seconds for looping across appropriate time frames
meta$duration = av_media_info(meta$file.name)$duration




# some QAQC
# missing.dat = meta[meta$size == 0,]
# write.table(missing.dat,"C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/missing_any_data.txt",sep = " ")

# remove empty files from list
# meta = meta[meta$size>0,]

# Dplyr for ordering recordings within day 
meta_2 = meta %>% group_by(station.night) %>% mutate(night.seq = order(time)) %>% arrange(prefix,or.night,night.seq) 

# write.csv(meta_2,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/Tracking/Chosen_Nights_meta_MKVI_2021.csv",row.names = F)







# Basic Loop for making specs


# pre-loop, spectrogram settings/specifications
Interval <- 60 # x-axis length in seconds 

# the following can be set specifically in the loops if need be (see other write spectrograms scrpt)
Length=180 # total length of recording in seconds
Breaks=seq(0,Length,Interval) # sequence of break locations 




# pb <- txtProgressBar(min = 0, max = length(data), style = 3)





# site = unique(meta_2$prefix)[1]
for (site in unique(meta_2$prefix)){
  
  # What site we working with 
  print(paste0("started site ~ ",site))
  
  
  # Keep only appropriate site data
  dat_in = meta_2[meta_2$prefix==site,]
  
  all_nights = unique(dat_in$or.night)
  
  # Loop through recording nights 
  # j = 1
  for (j in 1:length(all_nights)){
    
    grp_night = all_nights[j]
    
    
    dat_ret = dat_in[dat_in$or.night %in% grp_night,]
    
    print("ordinal dates")
    print(unique(dat_ret$or.day))
    
    
    # Create directory for site specs
    dir.out = paste0(OutputFolder,"/",site,"/",grp_night,"/")
    if(!dir.exists(dir.out)){
      dir.create(dir.out,recursive = T)
    } 
    
    # through sessions within night
    # i=1
    for (i in 1:nrow(dat_ret)){
      
      # all info for recording
      dat_use = dat_ret[i,]
      
      # the following can be set specifically in the loops if need be (see other write spectrograms scrpt)
      Length=dat_use$duration # total length of recording in seconds
      Breaks=seq(0,Length,Interval) # sequence of break locations 
      
      ptm = proc.time()
      
      # loop through 30 sec periods
      # k=1
      for (k in 1:(length(Breaks)-1)){
        
        ### processing time
       
        ### 
        
        # set start and end of segment within recordings
        Start = Breaks[k]
        End = Breaks[k+1]
        
        
        # create name for each time image
        
        name=paste0(gsub(pattern = "*.wav",replacement = "",x = basename(dat_use$file.name)),"_",formatC(Start, width = 3,flag = 0))
        
        name=paste(name,"png",sep = ".")
        
        name=gsub(pattern = "_0\\+1_",replacement = "_", name) # final name
        full.name = paste0(dir.out,name) # full name
        
    
        
        # 
        recording = dat_use$file.name # Identify file name required here
        
          
          # create sox command line
          args_command = paste0(recording,
                                " -n remix 1 rate 16k trim ", Start," ", Interval, " spectrogram -r -z 90 -x 1500 -y 1200 -o ", # -o always goes at the end
                full.name)
          
          
          
          system2("sox",
                  args = args_command)
          
          
          
          
          
          
          
          
        
        
        
        
      }
      
      print(proc.time() - ptm)
      
    }
    
    
    
    
    # Track sessions
    # 
    print(paste0("Session ",i," of ", max(dat_in$night.seq)," site ",site))    
  }
  
  
  
  
  
}


# NOw it's time to clip those nasty sox images to the right size



images = list.files("S:/ProjectScratch/398-173.07/PMRA_WESOke/Spectrograms/MKSC/raw",full.names = T,recursive = T,pattern = "*.png")

image.frame = data.frame(images)
image.frame$size = file.info(image.frame$images)$size

image.frame = image.frame[image.frame$size>0,]

image_use = image.frame$images

for (image in image_use){
  
  pic = image_read(image)
  out = image_crop(pic,"1500x600+0+600")
  nameout = gsub(pattern = ".png",replacement = ".jpg",image)
  nameout = gsub(pattern = "/Spectrograms/MKSC/raw",replacement = "/Spectrograms/MKSC/clipped",nameout)
  
  if (!dir.exists(dirname(nameout))){
    
    dir.create(dirname(nameout),recursive = T)
    
  } 
  image_write(out,path = nameout)
  
}

for(image in images){
  
  pic = image_read(image)
  out = gsub(pattern = ".png",replacement = ".jpg",image)
  image_write(pic,path = out)
  
}























for(i in 1:length(data)){
  
  FileLoc=data[i] 
  FileOutput=basename(FileLoc)
  FileOutput=paste0(TempFolder,FileOutput)
  
  
  
  wave <- readWave(FileLoc) #this is where Laura's is broken - if you're getting no read permission error come see us. might be a package version issue.
  duration <- 60 #duration(wave) - this is where I only use the first minute of each recording -- better solution?
  intervals <- ceiling(as.integer(duration)/x) 
  
  filename <- WavData
  filename=basename(filename) #trying as.character(filename) to get around the $ issue didn't work
  j=1 #j is the image number. So I have 1-6.
  for(j in 1:intervals){ #using sox to make pngs ##play with (j-1) to adjust for where in recording to start ###prettiness: extent of yaxis, colours
    
    
    sox (paste(WavData, " -n trim ", (j-1)*x, " ", x, " rate 44k spectrogram -z 90 -o ", # -o always goes at the end
               OutputFolder,
               substr(filename, 1, nchar(filename)-4), "_", (j-1)*10, ".png", sep = ""), #naming png file names (removing the .wav)
         path2exe = "/Users/JillianCameronold/Documents/Grad School/Sox") #this is where sox program is saved
  }
  
  
  setTxtProgressBar(pb, i)
}

close(pb)

