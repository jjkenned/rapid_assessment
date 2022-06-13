# sox script for all specs, based on the following specs

# set directories
$input_directories = Get-Childitem -Path "C:\Users\jeremiah.kennedy\Documents\PMRA\trial\recs" 
$output_directory = "C:\Users\jeremiah.kennedy\Documents\PMRA\trial\spectrograms"# output directory
$ErrorActionPreference = "Stop"

# Window settings
$max_freq = 2500 # maximum frequency (hz)
$min_freq = 0 # minimum frequency (hz)
$window_length = '0:30' # window length (m:ss)

$input_file = Resolve-Path "C:\Users\jeremiah.kennedy\Documents\PMRA\trial\recs\MKVI-U01-002_20210405_093300-0700.wav"
$output_file = "C:\Users\jeremiah.kennedy\Documents\PMRA\trial\spectrograms\image.png"


# trial recs
$input_directory = $input_directories[1]





# run loop
foreach ($input_directory in $input_directories) {

# Split the recording into sections 
 sox  $input_file -n stat
 

foreach ($start in ) {


# testing code
sox $input_directory -n spectrogram -s $start -d $window_length 

}







}

$env:Path

set PATH=%PATH%;'C:\Program Files (x86)\sox-14-4-2'

sox -help

Set-Location -Path "C:\"

sox $input_file -n spectrogram -o $output_file

soxi

sox $input_file $output_file --norm




   sox input.aiff output.wav spectrogram −S 1:00




    sox (paste(WavData, " -n trim ", (j-1)*x, " ", x, " rate 18k spectrogram -z 90 -o ", # -o always goes at the end
               OutputFolder,
               substr(filename, 1, nchar(filename)-4), "_", (j-1)*10, ".png", sep = ""), #naming png file names (removing the .wav)
         path2exe = "/Users/JillianCameronold/Documents/Grad School/Sox") #this is where sox program is saved
  }



  