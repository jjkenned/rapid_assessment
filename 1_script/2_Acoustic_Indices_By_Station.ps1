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

#requires -version 6


<#
Paramaterization for application of script. 
Get someone who knows about this to interprate why this is problematic for running generally. Should work by substituting the values below


param(
    [Parameter(
        Position = 0,
        Mandatory = $true,
        ValueFromRemainingArguments = $true,
        ValueFromPipeline = $true)]
    [System.IO.DirectoryInfo[]]$input_directories,

    [Parameter(
        Mandatory = $true)]
    [System.IO.DirectoryInfo]$output_directory,

    [Parameter(
        Mandatory = $true)]
    [string]$time_zone_offset,

    $name_filter = "*"

)


#> 








# Parameters 
# Directories and naming
# The character string used to define the directories may not get recognized as directories so I found a workaround

Set-Location -Path "S:\ProjectScratch\398-173.07\PMRA_WESOke\"
$input_directories = Get-Childitem -Path "S:\ProjectScratch\398-173.07\PMRA_WESOke\process\MKSC\MKSC-U01" 
$output_directory = "S:\ProjectScratch\398-173.07\PMRA_WESOke\indices\MKSC\MKSC-U01" # output directory 
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
        C:\AP\AnalysisPrograms.exe audio2csv $file "$default_configs/Towsey.Acoustic.yml" "$output_directory/by_rec/$current_group/$name" --no-debug --parallel 

    
    
    }

    Write-Output "Now concatenating files for $current_group"

    # for more information on how this command works, please see:
    # https://ap.qut.ecoacoustics.info/technical/commands/concatenate_index_files.html
    C:\AP\AnalysisPrograms.exe ConcatenateIndexFiles `
        --input-data-directory "$output_directory/by_rec/$current_group" `
        --output-directory "$output_directory/by_night" `
        -z $time_zone_offset `
        --file-stem-name $current_group `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.yml" `
        --draw-images `
        --no-debug

}

Write-Output "Complete!"




