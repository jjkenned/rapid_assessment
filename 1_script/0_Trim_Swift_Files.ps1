# set directories
$input_directories = Get-Childitem -Path "F:\recordings\BIRD\2022\REN"
$output_directory = "F:\processing\trimmed_recordings\BIRD\2022\REN"# output directory
$ErrorActionPreference = "Stop"


# trial recs
$input_directory = $input_directories[1]

# set working directory 
Set-Location -Path "C:\"



# run loop
foreach ($input_directory in $input_directories) {

#Station_Name
$name = $input_directory.Name

# now get full path ID
$path = $input_directory | %{$_.FullName}
$files = Get-ChildItem -Path "$path"
$out_subdir = "$output_directory/$name"



# make folder
if (Test-Path $out_subdir) {
   
} else
{
  
    #PowerShell Create directory if not exists
    New-Item "$out_subdir" -ItemType Directory
    
}

$file = $files[1]
foreach($file in $files){

# get file name

$file_name = $file.Basename
$infile = $file | %{$_.FullName}
# get output file name 
$out_file = -join("$out_subdir/$file_name",".wav")

# Split the recording into sections 

if (Test-Path $out_file){Write-Output "done this one"}else{ 


sox $infile $out_file trim 5

Write-Output "new one"

}


}


 



}
