########################################################################################
##### Build Grid Spectrograms ~ Arrays without patterns and schedules unmatched ########
########################################################################################

#### prep ####
# clear work space
rm(list=ls())
dev.off()


# library required packages
library(stringr)
library(seewave)
library(suncalc)
library(tidyverse)
library(lubridate)
library(sound)
library(tuneR)
library(oce)
library(av)
library(readxl)
library(viridis)

# Combination of:
# 1) append_dates&select....R
# 2) getdatefordays...R
# 3) Create_jpegs_owgr....R

## To convert ## 
# - Change reference of sites to process from long files to list created earlier on
# - Loop through full file names as apposed to doing site at a time
# - Convert to function Form


# Set directories 
in.root = "D:/TEMP/trial/recs" # recording files location
out.root="D:/TEMP/trial/spectrograms/" # output directory where results are kept

# Sound segment selection settings
Interval=60 # interval of frame segments in seconds
spec.max=2 # spectrogram max frequency in khz
spec.min=0 # spectrogram min frequency in khz
transf = 4096 # Forrier transformation to use (wl in spectro function)


# Get files
full.file = list.files(in.root,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)


# Metadata  and sorting
meta = songmeter(file.name) # get metadata

meta$file.name = full.file

###### STOP ##### 


# if you have a preset set of values for the files from the last script, then use this here
# meta = read.csv(file = "D:/TEMP/LDFS/Combined/chosen_recordings_trial.csv")

# if you have a list of nights to process import here
night.use = read.csv(file = "D:/TEMP/LDFS/Combined/processing_nights_updated.csv",stringsAsFactors = F)

# if you have survey night data from playbck sessions, include it here
playback = read_xlsx(path = "S:/Projects/106381-01/06 Data/HSP&PMRA/Playback_Surveys/2021/MKVI_2021_Visit_Data.xlsx",sheet = 1)


# let's use these to filter our data
# remove what isnt required 
night.use = night.use[c("station","night","Process")] # LDFCS results

playback = playback[c("Full_Station_ID","Date","Start_Time")] # playback surveys

playback$or.day = yday(playback$Date) # set ordinal date values

playback$hour = hour(playback$Start_Time) # get hour 

playback<-playback[!is.na(playback$Full_Station_ID),] # remove nas

playback = playback[c("Full_Station_ID","Date","or.day","hour")] # removed what isnt needed

# get site nights for the playback sessions 
playback$site = gsub(x = substr(playback$Full_Station_ID,1,8),pattern = "T",replacement = "U")  # site ID

# use function to convert day to night ID
d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}

playback$or.night = mapply(d2n.func,playback$or.day,playback$hour,12)


# now convert back to date
playback$new.date = as.character(as.Date(playback$or.night,origin = "2020-12-31"))
playback$new.date = gsub("-","",playback$new.date)

dont_use = unique(playback[c("site","new.date")])

# back to use nights
uses = night.use[night.use$Process=="x",c("station","night")]
uses$site = substr(uses$station,1,8)
uses = uses[c("night","site")]
colnames(dont_use) = c("site","night")


# moment of truth
check = merge(uses,dont_use,by = c("site","night"))



### if the above check doesnt come up with anything problematic you can continue #### 


### NOW  continue

## work with time carefuly 
meta$date = paste(meta$year,formatC(meta$month,width = 2,flag = 0),formatC(meta$day,width = 2,flag = 0),sep = "-")


meta$or.day = yday(as.Date(meta$date,format = "%Y-%m-%d")) # get ordinal date



# summarize recordings per day and days per station
unique(meta$prefix) # what stations are available?

meta$size = as.numeric(file.size(meta$file.name)) #  size of the files

# Now let's see what's gonna get processed 
night.use$or.night = yday(as.Date(as.character(night.use$night),format = "%Y%m%d"))

uses = night.use[night.use$Process=="x",c("station","night","or.night")]
uses$station.night = paste0(uses$station,"_",uses$or.night)

# convert to night ID and other for recordings
meta$or.night = mapply(d2n.func,meta$or.day,meta$hour,12)

meta$station.night = paste0(meta$prefix,"_",meta$or.night)# make night ID

# now filter by the chosen night IDs
meta = meta[meta$station.night %in% uses$station.night,]


# check
# meta[!yday(meta$Date)==meta$or.day,]


# Let's check what we know about these recordings (SKIP IF YOU ALREADY KNOW)
# How long are the recordings 

av_media_info(meta$full[1])




# some QAQC
# missing.dat = meta[meta$size == 0,]
# write.table(missing.dat,"C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/missing_any_data.txt",sep = " ")

# remove empty files from list
# meta = meta[meta$size>0,]

# Dplyr for ordering recordings within day 
meta_2 = meta %>% group_by(station.night) %>% mutate(night.seq = order(time)) %>% arrange(prefix,or.night,night.seq) 

#write.csv(meta_2,file = "S:/ProjectScratch/398-173.07/PMRA_WESOke/Tracking/full_meta_MKVI_2021.csv",row.names = F)


## Make a file to process data in 
# Get basename
meta_2$base.name = basename(meta_2$file.name)
proc_file = meta_2[c("base.name","date","or.night","night.seq","prefix","time")]

dat_pics = data.frame(matrix(NA,nrow = 0,ncol = 1))
colnames(dat_pics) = "pic_name"

# the following can be set specifically in the loops if need be (see other write spectrograms scrpt)
Length=180 # total length of recording in seconds
Breaks=seq(0,Length,Interval) # sequence of break locations 




# real naming loop
# site = unique(meta_2$prefix)[1]
for (site in unique(meta_2$prefix)){
  
  
  # Keep only appropriate site data
  dat_in = meta_2[meta_2$prefix==site,]
  
  all_nights = unique(dat_in$or.night)
  
  # Loop through recording nights 
  # j = 1
  for (j in 1:length(all_nights)){
    
    grp_night = all_nights[j]
    
    
    dat_ret = dat_in[dat_in$or.night %in% grp_night,]
    
    # Create directory for every night spectrograms to be kept
    dir.out = paste0(out.root,site,"/",grp_night,"/")
    
    
    # Loop through sessions within each night 
    i=1
    for (i in 1:nrow(dat_ret)){
      
      dat_use = dat_ret[i,]
      
      
      
      
      # loop through window length periods
      # k=1
      for (k in 1:(length(Breaks)-1)){
        
        
        # set start and end of segment within recordings
        Start = Breaks[k]
        End = Breaks[k+1]
        
        # now we have times we can use to assign names and lables
        
        
        
        # create name for each time image
        
        name=paste0(gsub(pattern = "*.wav",replacement = "",x = dat_use$base.name),"_",formatC(Start, width = 3,flag = 0))
        
        name=paste(name,"jpg",sep = ".")
        
        
        
        # draw JPG Looping through 4 recordings 
        # L=1
        for(L in 1:ncells) {
          
          section = dat_use$file.name[L] # Identify file name required here
          
          
          
          
          if (L==1){
            
            subq=data.frame(section)
            
          } else (subq[1,L] = section)
          
          # calculate new time of image frame 
          # rec = substr(dat_use$base.name[L],18,32)
          # seconds = Start
          
          
          
        }
        
        subq[1,(ncol(subq)+1)]=name
        
        # back out of the loop again
        colnames(subq) <- c("rec_1","rec_2","rec_3","rec_4","img")
        
        
        
        if (k == 1){
          
          quantum = subq
          
        } else (quantum=rbind(quantum,subq))
        
        
        
        
      }
      
      if (i==1){supq = quantum} else (supq = rbind(supq,quantum))  
      
    }
    
    if (j==1){dat_out = supq}else(dat_out = rbind(dat_out,supq))
    
  }
  
  
  if (site == unique(meta_2$prefix)[1]){finally=dat_out}else(finally=rbind(finally,dat_out))
  
  print(site)
}




# save

# dir.create("C:/Users/jeremiah.kennedy/Documents/Working/SiteC_output/Spectrograms/",recursive = T)
#write.csv(finally,file = "D:/data/recs_imgs_MKVI_2021.csv",row.names = F)



# now we are ready for forming spectrograms
# meta_3 = meta_3[substr(meta_3$prefix,1,7)=="SUNBIRD",]

###### Part 2 ~ Spectrogram Formation ####### 
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
      dir.out = paste0(out.root,site,"/",grp_night,"/")
      if(!dir.exists(dir.out)){
        dir.create(dir.out,recursive = T)
      } 
      
      # through sessions within night
      for (i in 1:nrow(dat_ret)){
        
        dat_use = dat_ret[i,]
        
        
        
        # loop through 30 sec periods
        #k=1
        for (k in 1:(length(Breaks)-1)){
          
          ### processing time
          ptm = proc.time()
          ### 
          
          # set start and end of segment within recordings
          Start = Breaks[k]
          End = Breaks[k+1]
          
          
          # create name for each time image
          
          name=paste0(gsub(pattern = "*.wav",replacement = "",x = dat_use$base.name),"_",formatC(Start, width = 3,flag = 0))
          
          name=paste(name,"jpg",sep = ".")
          
          
          
          # create jpeg with "name" and specify size
          jpeg(paste0(dir.out,name), width=13, height=8, units='in', res=500)
          par(mar=rep(0,4))
          
          # 
          
          section = dat_use$file.name # Identify file name required here
          
          framename = substr(dat_use$base.name,14,28)
          
          framename = paste0(framename," + ",Start)
          
          
          try({
            
            WAV = readWave(section, from=Start, to=End, units='seconds')
            WAV@left = WAV@left-mean(WAV@left)
            sound1 = spectro(WAV, plot=F, ovlp=10, norm=F, wl=transf)
            
            
            imagep(x=sound1[[1]], y=sound1[[2]], z=t(sound1[[3]]), 
                   drawPalette=F, ylim=c(spec.min,spec.max), mar=rep(0,4), axes=F, col = magma(150, begin = 0,end = 1), decimate=F)
            text(x=5,y=1.9,framename)
            box()
            
            
            
            
          },silent = TRUE)
          
          
          dev.off()
          
          print(proc.time() - ptm)
          
        }
        
        
        
      }
      
      
      
      
      # Track sessions
      # 
      print(paste0("Session ",i," of ", max(dat_in$night.seq)," site ",site))    
    }
    
    
    
    
    
  }
  
  
  cat("\n")
  print(paste0(site,"-COMPLETE"))
  cat("\n")   
  
}   








