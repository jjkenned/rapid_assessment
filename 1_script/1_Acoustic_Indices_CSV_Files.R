###################################################
#### Get Acoustic Indices for all Recordings  ##### 
###################################################

# Re-set  your script when needed
dev.off()
rm(list=ls())

# Set the directory containing the files
directory <- "C:/Users/jeremiah.kennedy/Documents/PMRA/Code/rapid_assessment/0_data/Data/"
# The directory to store the results
base_output_directory <- "C:\\Temp\\Workshop\\BatchIndicesOutput"

# Get a list of audio files inside the directory
# (Get-ChildItem is just like ls, or dir)
files <- list.files(directory, pattern = "*.wav", full.names = TRUE)

# iterate through each file
for(file in files) {
  message("Processing ", file) 
  
  # get just the name of the file
  file_name <- basename(file)
  
  # make a folder for results
  output_directory <- normalizePath(file.path(base_output_directory, file_name))
  dir.create(output_directory, recursive = TRUE)
  
  # prepare command
  command <- sprintf('audio2csv "%s" "Towsey.Acoustic.yml" "%s" ', file, output_directory)
  
  # finally, execute the command
  system2('C:\\AP\\AnalysisPrograms.exe', command)
}
