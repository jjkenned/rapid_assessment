# Re-set  your script when needed
dev.off()
rm(list=ls())


# fromdir = c("F:/PMRA_SAR/Recordings/BIRD/2021/MKVI")

from = list.files("E:/PMRA_SAR/Recordings/BIRD/2016",full.names = T,recursive = T,pattern = ".wav")
to = list.files("F:/PMRA_SAR/Recordings/BIRD/2016",full.names = T,recursive = T,pattern = ".wav")




from[!basename(from) %in% basename(to)]

to[!basename(to) %in% basename(from)]

matches = data.frame(name = basename(from[basename(from) %in% basename(to)]))


dest = data.frame(Full = to)
dest$size = file.size(dest$Full)

source = data.frame(Full = from)
source$size = file.size(source$Full)

dest$name = basename(dest$Full)
source$name = basename(source$Full)


for (i in 1:nrow(source)){
  
  if (source$name[i] %in% dest$name){
    
    file = source$name[i]
    comp_in = data.frame(name = file,size_to = source$size[i],size_from = dest$size[dest$name == file]) 
    comp_in$dif = comp_in$size_to - comp_in$size_from
    
  }
  if (i==1){comp_out = comp_in} else (comp_out = rbind(comp_out,comp_in))
  
  if(i%%1000==0){print(i)}
  
}


