﻿<#
.SYNOPSIS
  Generates acoustic indices for multiple audio files and concatenates the output.
.DESCRIPTION
  Generates acoustic indices for multiple audio files and concatenates the output.
  Expects each directory to contain audio files for one location.
.PARAMETER $input_directories
    A directory of audio files to process.
.PARAMETER $output_directory
    A directory where the indices should be exported to
.INPUTS
  Optionally: input directories
.OUTPUTS
  Files stored in $output_directory
.NOTES
  Version:        2.0
  Author:         Anthony Truskinger
  Creation Date:  2020-01-30
  Modification Date: 2021-11-18
  Purpose/Change: Updated docs links, add ap finder script
.EXAMPLE
  ./indices_and_concat.ps1 D:/Stud D://Thompson -time_zone_offset "10:00" -output_directory ./output
#>


# Parameters 
# Directories and naming
# The character string used to define the directories may not get recognized as directories so I found a workaround

# Set-Location -Path "E:\processing\copied_recordings\BIRD\2022\MKVI"
<<<<<<< HEAD
$group = "MKDI-01" # station to station basis at this point
=======
<<<<<<< HEAD

$group = "recordings" # station to station basis at this point

# set in and out directories 
$parent_input_dir = "//hemmera.com/Shared/ProjectScratch/106242-01 Bird and Bat Data/2022/Bird_Data_Processing" 
$input_directories = Get-Childitem -Path "$parent_input_dir/$group"
$output_directory = "//hemmera.com/Shared/ProjectScratch/106242-01 Bird and Bat Data/2022/Bird_Data_Processing/indices" # output directory 
=======
$group = "MKVI-U24" # station to station basis at this point
>>>>>>> e793c5404dfc2e4a0fde1d2a90589f179f1c21f4

# set in and out directories 
$parent_input_dir = "D:\PMRA_SAR\Recordings\BIRD\2022\MKDI" 
$input_directories = Get-Childitem -Path "$parent_input_dir\$group"
<<<<<<< HEAD
$output_directory = "D:\PMRA_SAR\Processing\Timelapse_files\LDFCS\BIRD\2022\MKDI" # output directory 
=======
$output_directory = "E:\processing\output.index.values\BIRD\2022\MKVI" # output directory 
>>>>>>> 6e0c180ce761e2045b350b3e4e70c13710566746
>>>>>>> e793c5404dfc2e4a0fde1d2a90589f179f1c21f4
$name_filter = "*" # name filter(kinda unsure what it means)
$time_zone_offset = -0700



# Do not continue running the script if a problem is encountered
$ErrorActionPreference = "Stop"


# get the path for AP.exe. When do this to resolve some nice default config files.
# TODO: remove this when the default config file feature is implemented in AP.exe
$ap_path = "C:\AP"
$default_configs = Resolve-Path "$ap_path\ConfigFiles"

# check how it works
# $input_directory = $input_directories[1]

foreach ($input_directory in $input_directories) {
    Write-Output "Processing $input_directory"


    $dir_in = $input_directory.FullName
    $current_group = $input_directory.Name
    

    $audio_files = Get-ChildItem -Recurse -File $dir_in -Include "*.wav"
    $filtered_files = $audio_files | Where-Object { $_.Name -ilike $name_filter }

    $counter = 0;
    # bring out of this loop as well to deal with error
    # $file = $filtered_files[1]

    foreach ($file in $filtered_files) {
        $counter++
        Write-Output "Generating indices for $file, file $counter of $($filtered_files.Count)"
        $name = $file.Name

        # make folder to keep output

        
        # for more information on how this command works, please see:
        # https://ap.qut.ecoacoustics.info/technical/commands/analyze_long_recording.html
        C:\AP\AnalysisPrograms.exe audio2csv $file "$default_configs/Towsey.Acoustic.Short.Low.yml" "$output_directory/by_rec/$group/$current_group/$name" --no-debug --parallel 

    
    
    }

    Write-Output "Now concatenating files for $current_group"

    # for more information on how this command works, please see:
    # https://ap.qut.ecoacoustics.info/technical/commands/concatenate_index_files.html
    C:\AP\AnalysisPrograms.exe ConcatenateIndexFiles `
        --input-data-directory "$output_directory/by_rec/$group/$current_group" `
        --output-directory "$output_directory/by_night/$group/$current_group" `
        -z $time_zone_offset `
        --file-stem-name $current_group `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.yml" `
        --draw-images `
        --no-debug

}

Write-Output "Complete!"

sox



