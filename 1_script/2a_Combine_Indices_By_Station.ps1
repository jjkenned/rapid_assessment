# Combine incides for LDFC processing
# This is useful if your script only calculates the LDFCs and doesnt combine them 


# Parameters 
# Directories and naming
# The character string used to define the directories may not get recognized as directories so I found a workaround

# Set-Location -Path "E:\processing\copied_recordings\BIRD\2022\MKVI"
$group = "REN-01" # station to station basis at this point

# set in and out directories 
$parent_input_dir = "F:\processing\copied_recordings\BIRD\2022\REN" 
$input_directories = Get-Childitem -Path "$parent_input_dir/$group"
$output_directory = "F:\processing\output.index.values\BIRD\2022\REN" # output directory 
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
        --input-data-directory "$output_directory/by_rec/$group/$current_group" `
        --output-directory "$output_directory/by_night/$group" `
        -z $time_zone_offset `
        --file-stem-name $current_group `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.yml" `
        --draw-images `
        --no-debug

}

Write-Output "Complete!"




