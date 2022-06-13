
# site = unique(meta_2$prefix)[1]
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
    # i = seq(1,nrow(dat_ret),4)[1]
    for (i in seq(1,nrow(dat_ret),4)){
      
      dat_use = dat_ret[i:(i+3),]
      
    

      
      # loop through 30 sec periods
      # k=1
      for (k in 1:(length(Breaks)-1)){
        
       
        # set start and end of segment within recordings
        Start = Breaks[k]
        End = Breaks[k+1]
        
        # now we have times we can use to assign names and lables
        
        
        
        # create name for each time image
        
        name=paste0(site,"_","ses","_",formatC(dat_use$night.seq[1],width = 2,flag = 0),"_night_",all_nights[j],"_",formatC(Start, width = 3,flag = 0))
        
        name=paste(name,"jpeg",sep = ".")
        
        
          
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




