


   
    C:\AP\AnalysisPrograms.exe ConcatenateIndexFiles `
        --input-data-directory "D:\TEMP\LDFS\MKVI-U03-010" `
        --output-directory "D:\TEMP\LDFS\by night\MKVI-U03-010" `
        -z $time_zone_offset `
        --file-stem-name "MKVI-U03-010" `
        --directory-filter "*.*" `
        --index-properties-config "$default_configs/IndexPropertiesConfig.yml" `
        --false-colour-spectrogram-config "$default_configs/SpectrogramFalseColourConfig.yml" `
        --draw-images `
        --no-debug
       