########################################################
########### Manipulate LDFCS database ##################
########################################################

## If you move your files or make manipulations, you may need to re-write file paths or something along those lines, in order to keep this database functioning
# THis script is for that

# Re-set  your script when needed
dev.off()
rm(list=ls())

# libraries
library(stringr)
library(tidyverse)
library(av)
library(chron)
library(seewave)
library(lubridate)
library(RSQLite)

## engage databse
LDFC.res <- DBI::dbConnect(RSQLite::SQLite(), "S:/ProjectScratch/398-173.07/PMRA_WESOke/PMRA_SAR/Processing/Timelapse_files/LDFCS/BIRD/2022/IndicesProcessing2.ddb")

# check db
dbListTables(LDFC.res)
dbListFields(LDFC.res,"DataTable")





# if you have a list of nights to process import here
night.use = tbl(LDFC.res,"DataTable") 
night.use = data.frame(night.use %>% select(File, Process))



# Extract metadata from file name (get from end so you don't need to deal with prefix length)
for (i in 1:nrow(night.use)){
  
  
  night.use$date[i] = substr(night.use$File[i], nchar(night.use$File[i]) - 12 + 1, nchar(night.use$File[i]) - 4)
  
}
night.use$date = substr(night.use$File, nchar(night.use$File))






