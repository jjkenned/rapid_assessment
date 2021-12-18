
site = unique(meta_2$prefix)[1]
for (site in unique(meta_2$prefix)){
  
  # Create directory for site specs
  dir.out = paste0(out.root,site,"/")
  
  # Keep only appropriate site dataa
  dat_in = meta_2[meta_2$prefix==site,]
  
  all_nights = unique(dat_in$or.night)
  
  # Loop through recording nights 
  # j = 1
  for (j in 1:length(all_nights)){
    
    grp_night = all_nights[j]
    
    
    dat_ret = dat_in[dat_in$or.night %in% grp_night,]
    
  
    # through sessions within night in groups of 4
    # i= seq(1,nrow(dat_ret),4)[1]
    for (i in seq(1,nrow(dat_ret)),4)){
      
      dat_use = dat_ret[i:(i+3),]
      
      
      
      # loop through 30 sec periods
      # k=1
      for (k in 1:(length(Breaks)-1)){
        
        ### processing time
        ptm = proc.time()
        ### 
        
        # set start and end of segment within recordings
        Start = Breaks[k]
        End = Breaks[k+1]
        
        
        # create name for each time image
        
        name=paste0(site,"_","ses","_",formatC(dat_use$night.seq[1],width = 2,flag = 0),"_night_",all_nights[j],"_",formatC(Start, width = 3,flag = 0))
        
        name=paste(name,"jpeg",sep = ".")
        
        
        
        # draw JPG Looping through 4 recordings 
        # L=1
        for(L in 1:ncells) {
          
          
          
          section = dat_use$full[L] # Identify file name required here
          
          # deal with missing components 
          
          try({
            
            WAV = readWave(section, from=Start, to=End, units='seconds')
            WAV@left = WAV@left-mean(WAV@left)
            sound1 = spectro(WAV, plot=F, ovlp=30, norm=F, wl=transf)
            
            BinRange=seq(0,70,1)
            
            imagep(x=sound1[[1]], y=sound1[[2]], z=t(sound1[[3]]), 
                   drawPalette=F, ylim=c(spec.min,spec.max), mar=rep(0,4), axes=F, col = rev(gray.colors(length(BinRange)-1, 0,0.9)), decimate=F)
            text(x=3.1,y=2.4,dat_ret$time[L])
            box()
            
            
            
            
          },silent = TRUE)
          
          
          
          
          
        }
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

