#########################################
##### Select nights for database ########
#########################################

#### prep ####
# clear work space
rm(list=ls())
dev.off()


# library required packages
library(stringr)
library(seewave)
library(suncalc)
library(tidyr)
library(lubridate)
library(sound)
library(tuneR)
library(oce)

# Combination of:
# 1) append_dates&select....R
# 2) getdatefordays...R
# 3) Create_jpegs_owgr....R

## To convert ## 
# - Change reference of sites to process from long files to list created earlier on
# - Loop through full file names as apposed to doing site at a time
# - Convert to function Form


# Set output directory 
out.root="C:/Users/jeremiah.kennedy/Documents/Working/Rayrock Output/Spectrograms" # output directory where results are kept

##### Step 1: Prep and Read in Data ##### 

# Prep-prep, project-specific stuff (similar to begining of function in script 1)
# Required decisions and pre-sets for project
# form<-"PPPP-CC-SSS-NN" # this is the format for the site and station ID (P<-project, C<-cluster, S<-site, N<-station)
form<-"NNNNNNN"

# proj.id="NWTI" # this is important for assigning sites etc. Project ID should match first section of name

# grid specifications important to setup for list referencing
grid_ref<-c("NW","NE","SW","SE")
width<-2
height<-2
Interval=20 # interval of frame segments in seconds
spec.max=1.3 # spectrogram max frequency in khz
spec.min=0 # spectrogram min frequency in khz
transf = 2048 # Forier transformation to use (wl in spectro function)




## Read in Data
# List of recordings from script 2, because it is called nwti.use we will assign that name there
load(file = "0_data/processed/NWTI_list_4_Indices.Rdata") # all recordings in selected time and date period
night.ref<-read.csv("0_data/processed/NWTI_Night_ref.csv") # grading for each night

# Add site values in so that you can combine the3 reference sheet and the site
# Station and site ID fields
nwti.use$site<-substr(nwti.use$prefix,1,max(str_locate_all(pattern = "S",form)[[1]]))
nwti.use$station<-substr(nwti.use$prefix,min(str_locate_all(pattern = "N",form)[[1]]),max(str_locate_all(pattern = "N",form)[[1]]))


# Add rating and chosen recording status to DF by merging and keeping all nwtiuse
night.use<-merge(nwti.use,night.ref,by = c("site","ynight"),all.x = T)

# now choose by rating 
chosen<-night.use[night.use$choose==1,]






###### Step 2: Functions ###### 
# Function for creating spectrograms

get.specs<-function(chosen,form,grid_ref,Interval,out.root,height,width,spec.min,spec.max,transf){
  
  
  ##### Start creating sessions and printing #####
  
  print("PreLoop Setup")
  cat("\n")
  # Preloop setup
  Cols=c('month', 'day', 'hour', 'min', 'sec', 'time') #Get month, day, hour, min, sec columns, so that we know how many unique 
  
  print("Starting Loop")
  cat("\n")
  
  #for loop for each site
  site<-"NWTI-01-002"
  for (site in unique(chosen$site)){
    
    
    # Make directory for it to be kept
    dir.out<-paste0(out.root,site,"/")
    if(!dir.exists(dir.out)){
      dir.create(dir.out,recursive = T)
    }
    
    
    # set chosen for site
    Meta<-chosen[chosen$site==site,]
    # set sessions
    Sessions=unique(Meta[,Cols])
    # i=1
    for(i in 1:nrow(Sessions)) { # go through all the sessions recorded
      
      S=Sessions[i,] # ID the active row of the sessions df
      
      #Get the associated metadate for recordings for session in question (either 4 or 16 usually) 
      Recs=Meta[Meta$month==S$month & Meta$day==S$day & Meta$hour==S$hour & 
                  Meta$min==S$min,]
      Recs1=Meta[Meta$month==S$month & Meta$day==S$day & Meta$hour==S$hour & 
                   Meta$min==S$min,]
      
      
      for (k in 1:length(grid_ref)){
        
        Recs[k,] = Recs1[Recs1$station==grid_ref[k],]
        
      }
      
      # If you need to do that manually then its here
      # Recs[1,]=Recs1[Recs1$station=="001",]
      # Recs[2,]=Recs1[Recs1$station=="002",]
      # Recs[3,]=Recs1[Recs1$station=="003",]
      # Recs[4,]=Recs1[Recs1$station=="004",]
      # Recs[5,]=Recs1[Recs1$station=="005",]
      # Recs[6,]=Recs1[Recs1$station=="006",]
      # Recs[7,]=Recs1[Recs1$station=="007",]
      # Recs[8,]=Recs1[Recs1$station=="008",]
      # Recs[9,]=Recs1[Recs1$station=="009",]
      # Recs[10,]=Recs1[Recs1$station=="010",]
      # Recs[11,]=Recs1[Recs1$station=="010",]
      # Recs[12,]=Recs1[Recs1$station=="012",]
      # Recs[13,]=Recs1[Recs1$station=="013",]
      # Recs[14,]=Recs1[Recs1$station=="014",]
      # Recs[15,]=Recs1[Recs1$station=="014",]
      # Recs[16,]=Recs1[Recs1$station=="016",]
      
      
      
      
      #### Construct another loop to generate the spectrograms. ####
      # start by getting length of recordings and designating sequence of intervals
      Length=readWave(Recs$Full[1], header=T)$samples/readWave(Recs$Full[1], header=T)$sample.rate 
      
      Breaks=seq(0,Length,Interval) # segments to clip 
      
      
      # delineate compenent of recording to clips 
      
      for(j in 1:(length(Breaks)-1)) {
        Start=Breaks[j] # start and end of recording clips 
        End=Breaks[j+1]
        
        # start jpeg creation 
        
        # create name for each time immage
        
        name=paste(site, S$time, sep = " ")
        name=paste(name,"jpeg",sep = ".")
        name=gsub(" ","_",name)
        name=gsub(":","",name)
        
        Sec=(j*Interval)-Interval
        Secpeg=paste(Sec,"jpeg",sep = ".")
        Secpeg=paste0("_",Secpeg)
        name=gsub(".jpeg",Secpeg,name)
        
        # create jpeg with "name" and specify size
        jpeg(paste0(dir.out,name), width=13, height=8, units='in', res=500)
        par(mfrow=c(height,width)) 
        par(mar=c(0,0,0,0))
        
        
        for(L in 1:nrow(Recs)) {
          section = Recs$Full[L]
          WAV = readWave(section, from=Start, to=End, units='seconds')
          WAV@left = WAV@left-mean(WAV@left)
          sound1 = spectro(WAV@, plot=F, ovlp=30, norm=F, wl=transf)
          
          
          
          # Problem: by default spectro does left channel only. Would be more 
          # computationally expensive to do two channels.
          BinRange=seq(0,70,1)
          
          imagep(sound1[[1]], sound1[[2]], t(sound1[[3]]), 
                 drawPalette=F, ylim=c(spec.min,spec.max), mar=rep(0,4), axes=F,
                 breaks=BinRange, col=rev(gray.colors(length(BinRange)-1, 0,0.9)), decimate=F)
          text(x=1,y=1.2,Recs$station[L])
          box()
          
        }
        dev.off()
      }
      print(paste0("Session ",i," of ", nrow(Sessions)," site ",site))
    }
    cat("\n")
    print(paste0(site,"-COMPLETE"))
    cat("\n")
    
  }
  
  
  
  
  
  
}


get.specs(chosen,form,grid_ref,Interval,out.root,height,width,spec.min,spec.max,transf)
