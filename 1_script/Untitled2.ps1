 
 
 
 
 C:\AP\AnalysisPrograms.exe ConcatenateIndexFiles `
        --input-data-directory "D:\TEMP\MUCH\LDFS\by night\by_rec\MUCH-001" `
        --output-directory "D:\TEMP\MUCH\LDFS\by_day" `
        -z $time_zone_offset `
        --file-stem-name "MUCH-001" `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.basic.yml" `
        --draw-images `
        --no-debug