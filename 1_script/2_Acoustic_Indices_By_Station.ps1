
# Set-Location -Path "E:\processing\copied_recordings\BIRD\2022\MKVI"
$group = "MKVI-U-14" # station to station basis at this point

# set in and out directories 
$parent_input_dir = "P:/PMRA_processing/copied_recordings/BIRD/2022/MKVI" 
$input_directories = Get-Childitem -Path "$parent_input_dir/$group"
$output_directory = "P:/PMRA_processing/output.index.values/BIRD/2022/MKVI" # output directory 
$name_filter = "*" # name filter(kinda unsure what it means)
$time_zone_offset = -0700



# Do not continue running the script if a problem is encountered
$ErrorActionPreference = "Stop"


# get the path for AP.exe. When do this to resolve some nice default config files.

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





