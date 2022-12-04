﻿





# Set-Location -Path "D:\PMRA_SAR\Processing\Timelapse_files\LDFCS\BIRD\2022\MKDI\"

$group = "MKDI-01" # station to station basis at this point

# set in and out directories 
$parent_input_dir = "D:\PMRA_SAR\Processing\Timelapse_files\LDFCS\BIRD\2022\MKDI\new_name_indices_new" 
$input_directories = Get-Childitem -Path "$parent_input_dir\$group"
$output_directory = "D:\PMRA_SAR\Processing\Timelapse_files\LDFCS\BIRD\2022\MKDI\by_night" # output directory 
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

    
    $current_group = $input_directory.Name
  
    $counter = 0;


    Write-Output "Concatenating files for $current_group"

    # for more information on how this command works, please see:
    # https://ap.qut.ecoacoustics.info/technical/commands/concatenate_index_files.html
    C:\AP\AnalysisPrograms.exe ConcatenateIndexFiles `
        --input-data-directory "$parent_input_dir\$group\$current_group" `
        --output-directory "$output_directory\$group\$current_group" `
        -z $time_zone_offset `
        --file-stem-name $current_group `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.yml" `
        --draw-images `
        --no-debug

}

Write-Output "Complete!"







