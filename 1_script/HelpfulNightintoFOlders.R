# Helpful collect nights into folders 



dev.off()
rm(list=ls())

# libraries
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)

##############################
#### Part 1 ~ Copy Files######
##############################



# Specify directory where recording files are kept:
dir = "S:/ProjectScratch/398-173.07/PMRA_WESOke/indices/MKCA/by_rec" # where files are kept

# list directories 
dat = data.frame(Full = list.dirs(dir,recursive = F))

dat$name = basename(dat$Full) # just the wav files name

meta = songmeter(dat$name)
meta$file.name = dat$name
meta$full.name = dat$Full

# now change dates

# let's do it the hard way !
file.grps = meta %>% group_by(prefix,year,month,day) %>% mutate(group_id = cur_group_id()) # group by date
# quick function for translating day number into night number 
# day = night ID, hr = hour in 24 hr clock (as integer), split = when to cut off the nights from one another (usually 12...noon)
d2n.func = function(day,hr,split){
  
  if (hr<split){night = day} else (night = day+1)
  
  return(night)
  
}




# apply function accross the dataframe 
file.grps$night.ID = mapply(d2n.func,file.grps$group_id,file.grps$hour,12) 

plot(file.grps$group_id,file.grps$night.ID) # visualize to make sure it makes sense

# ID the name change


for (i in 1:nrow(file.grps)){
  
  file.grps$new.name[i] = gsub("by_rec/",paste0("by_rec/",file.grps$night.ID[i],"/"),file.grps$full.name[i])
  
}

# now list all files
files = list.files(path = dir,recursive = T,full.names = T)


# now loop through files 
night = unique(file.grps$night.ID)[1]

for (night in unique(file.grps$night.ID)){
  
  night.dat = file.grps[file.grps$night.ID==night,]
  files.old = list.files(path = night.dat$full.name,recursive = T,full.names = T)

  # j=1
  for (j in 1:length(files.old)){
   
    new.name = gsub("by_rec/",paste0("by_rec/",night,"/"),files.old[j])
    
    if (!dir.exists(dirname(new.name))){dir.create(dirname(new.name),recursive = T)}
    
    file.rename(files.old[j],new.name)
    
    
  }


  
  
}


# Now put them in folders
(from = file.grps$full.name,to = file.grps$new.name)













