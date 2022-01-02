#######################################
#### Making Spectrograms with SoX ##### 
#######################################

# Re-set  your script when needed
dev.off()
rm(list=ls())


# Library required packages
library(seewave)
library(tuneR)


# set functions you will want to use 

# use function to convert day to night ID
d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}



# Set locations for source folder and destination folder 
# you may also want to have a temporary folder 


SourceFolder = "S:/ProjectScratch/398-173.07/PMRA_WESOke/process/MKVI/" #where your recording files are kept
OutputFolder = "C:/Users/jeremiah.kennedy/Documents/PMRA/trial/spectrograms" # where saving images


# list the files you want
full.file = list.files(SourceFolder,recursive = T,full.names = T,pattern = "*.wav") # full file names
file.name = basename(full.file)


# Get metadata for looping
meta = songmeter(file.name)
meta$file.name = full.file

#### Add selection list of files or nights #### 

# if you have a list of nights to process import here
night.use = read.csv(file = "C:/Users/jeremiah.kennedy/Documents/PMRA/trial/LDFC/processing_nights_updated.csv",stringsAsFactors = F)
night.use = night.use[c("station","night","Process")] # remove what isnt required 


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






# Basic Loop for making specs


# pre-loop, spectrogram settings/specifications
x <- 30 # x-axis length in seconds 


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
          
          # create sox command line
          command = paste(WAV, " -n trim ", (j-1)*x, " ", x, " rate 18k spectrogram -z 90 -o ", # -o always goes at the end
                OutputFolder,
                substr(filename, 1, nchar(filename)-4), "_", (j-1)*10, ".png", sep = "")
          
          
          sox (command, #naming png file names (removing the .wav)
               path2exe = "/Users/JillianCameronold/Documents/Grad School/Sox") #this is where sox program is saved
          
          
          
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




i=1


















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
    
    
    sox (paste(WavData, " -n trim ", (j-1)*x, " ", x, " rate 18k spectrogram -z 90 -o ", # -o always goes at the end
               OutputFolder,
               substr(filename, 1, nchar(filename)-4), "_", (j-1)*10, ".png", sep = ""), #naming png file names (removing the .wav)
         path2exe = "/Users/JillianCameronold/Documents/Grad School/Sox") #this is where sox program is saved
  }
  
  
  setTxtProgressBar(pb, i)
}

close(pb)

