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


# Combination of:
# 1) append_dates&select....R
# 2) getdatefordays...R
# 3) Create_jpegs_owgr....R

## To convert ## 
# - Change reference of sites to process from long files to list created earlier on
# - Loop through full file names as apposed to doing site at a time
# - Convert to function Form


# Set directories 
in.root = "S:/ProjectScratch/398-173.07/ARUs - 2021/rw/" # recording files location
out.root="C:/Users/jeremiah.kennedy/Documents/Working/SiteC_output/Spectrograms/" # output directory where results are kept

## Additional input directory options
# multiple (but not all) sub-directories 
subs = c("210621_SE05","210716_2536_SE05","SM4") # list subdirectories
in.roots = paste0(in.root,subs) # paste to make full directories 

# set required numbger of grid cells for reference
ncells = 4
width<-2
height<-2

# Sound segment selection settings
Interval=60 # interval of frame segments in seconds
spec.max=10 # spectrogram max frequency in khz
spec.min=0 # spectrogram min frequency in khz
transf = 2048 # Forier transformation to use (wl in spectro function)


# Get files
full.file = list.files(in.roots,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)


# Metadata  and sorting
meta = songmeter(file.name) # get metadata

meta$file.name = full.file

meta$or.day = yday(meta$time) # get ordinal date
meta$Date = as.Date(meta$time,format = "%d%b%Y",tz = "MST") # get date for visually helpful processing
meta$station_date = paste0(meta$prefix,"-",meta$or.day)# make station date ID

# summarize recordings per day and days per station
unique(meta$prefix) # what stations are available?


meta$size = as.numeric(file.size(meta$file.name))


# check
meta[!yday(meta$Date)==meta$or.day,]


# Let's check what we know about these recordings (SKIP IF YOU ALREADY KNOW)
# How long are the recordings 

av_media_info(meta$file.name[1])

# the following can be set specifically in the loops if need be (see other write spectrograms scrpt)
Length=1800 # total length of recording in seconds
Breaks=seq(0,Length,Interval) # sequence of break locations 






# some QAQC
# missing.dat = meta[meta$size == 0,]
# write.table(missing.dat,"C:/Users/jeremiah.kennedy/Documents/Rayrock/Tracking/missing_any_data.txt",sep = " ")

# remove empty files from list
meta = meta[meta$size>0,]

# Dplyr for ordering recordings within day 
meta_2 = meta %>% group_by(station_date) %>% mutate(night.seq = order(time)) %>% arrange(station_date,night.seq) 

write.csv(meta_2,file = "S:/ProjectScratch/398-173.07/ARUs - 2021/rw/jck_processing/full_meta.csv",row.names = F)


## Make a file to process data in 
# Get basename
meta_2$base.name = basename(meta_2$file.name)
proc_file = meta_2[c("base.name","Date","or.day","night.seq","prefix","time")]

dat_pics = data.frame(matrix(NA,nrow = 0,ncol = 1))
colnames(dat_pics) = "pic_name"


# # naming loop
# for (site in unique(meta_2$prefix)){
#   dir.out = paste0(out.root,site,"/")
# 
#   # Keep only appropriate site data
#   dat_in = meta_2[meta_2$prefix==site,]
# 
#   for (i in 1:max(dat_in$night.seq)){
# 
#     dat_mid = dat_in[dat_in$night.seq==i,]
# 
#     dat_mid = dat_mid[order(dat_mid$or.day,decreasing = F),]
# 
# 
#     # loop through 60 sec periods
#     #k=2
#     for (k in 1:(length(Breaks)-1)){
# 
#       Start = Breaks[k]
#       End = Breaks[k+1]
# 
# 
#       # create name for each time image
# 
#       name=paste0(site,"_",formatC(dat_mid$night.seq[1],width = 2,flag = 0),"_",formatC(Start, width = 3,flag = 0))
#       name=paste(name,"jpeg",sep = ".")
# 
# 
#       if (site == unique(meta_2$prefix)[1] & i==1 & k==1){
# 
#         dat_pics <-c(name)
# 
#       } else (dat_pics <- c(dat_pics,name))
# 
# 
# 
# 
#     }
# 
#   }
# }


# save

# dir.create("C:/Users/jeremiah.kennedy/Documents/Working/SiteC_output/Spectrograms/",recursive = T)
# write.csv(dat_pics,file = "C:/Users/jeremiah.kennedy/Documents/Working/SiteC_output/Spectrograms/site_C_JPGs.csv")


# now we are ready for forming spectrograms
# meta_3 = meta_3[substr(meta_3$prefix,1,7)=="SUNBIRD",]

###### Part 2 ~ Spectrogram Formation ####### 
# site = unique(meta_2$prefix)[1]
for (site in unique(meta_2$prefix)){
  
  # What site we working with 
  print(paste0("started site ",site))
  
  # Create directory for site specs
  dir.out = paste0(out.root,site,"/")
  if(!dir.exists(dir.out)){
    dir.create(dir.out,recursive = T)
  } 
  
  
  # Keep only appropriate site data
  dat_in = meta_2[meta_2$prefix==site,]
  
  # Loop through sessions 
  #i=1
  for (i in 1:max(dat_in$night.seq)){
    
    print(paste0("recording sequence ID: ",i))
    
    dat_mid = dat_in[dat_in$night.seq==i,]
    
    dat_mid = dat_mid[order(dat_mid$or.day,decreasing = F),]
    
    all_nights = unique(dat_mid$or.day)
    
   # j = 2
    for (j in 1:floor((length(unique(dat_mid$or.day)))/ncells)){
      
      start_night = (j-1)*4+1
      end_night = start_night+3
      grp_night = all_nights[start_night:end_night]
      
      
      dat_ret = dat_mid[dat_mid$or.day %in% grp_night,]
      
      print("ordinal dates")
      print(grp_night)
      
      # loop through 60 sec periods
      #k=1
      for (k in 1:(length(Breaks)-1)){
        
        ### processing time
        ptm = proc.time()
        ### 
        
        # set start and end of segment within recordings
        Start = Breaks[k]
        End = Breaks[k+1]
        
        
        # create name for each time image
        
        name=paste0(site,"_","ses","_",formatC(dat_ret$night.seq[1],width = 2,flag = 0),"_nights_",j,"_",formatC(Start, width = 3,flag = 0))
        name=paste(name,"jpeg",sep = ".")
        
        
        
        # create jpeg with "name" and specify size
        jpeg(paste0(dir.out,name), width=13, height=8, units='in', res=800)
        par(mfrow=c(height,width)) 
        par(mar=rep(0,4))
        
        
        
        # draw JPG Looping through 4 dates
        # L=1
        for(L in 1:ncells) {
          
          section = dat_ret$file.name[L]
          WAV = readWave(section, from=Start, to=End, units='seconds')
          WAV@left = WAV@left-mean(WAV@left)
          sound1 = spectro(WAV, plot=F, ovlp=30, norm=F, wl=transf)
          
          BinRange=seq(0,70,1)
          
          imagep(x=sound1[[1]], y=sound1[[2]], z=t(sound1[[3]]), 
                 drawPalette=F, ylim=c(spec.min,spec.max), mar=rep(0,4), axes=F, col = rev(gray.colors(length(BinRange)-1, 0,0.9)), decimate=F)
          text(x=3,y=1,dat_mid$or.day[L])
          box()
          
        }
        dev.off()
        
        print(proc.time() - ptm)
        
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

  
  
  








