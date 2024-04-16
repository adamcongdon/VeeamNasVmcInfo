 # VMC log path is hardcoded for now. If logs are sent elsewhere, please adjust accordingly.
 $logsPath = "C:\ProgramData\Veeam\Backup\Utils\VMC.log"

 # section identifiers
 $sectionStart = "=====UNSTRUCTURED DATA===="
 $sectionEnd = "========"
 
 #output files, feel free to rename and relocate
 $csvFilePath = 'Share Breakdown.csv'
 $csv2FilePath = 'output2.csv'
 
 #get file info and set empty containers.
 $content = Get-Content $logsPath
 $sections = @()
 $currentSection = @()
 $capturing = $false
 
 foreach($line in $content){
     if(-not $capturing -and $line -match $sectionStart){
         $capturing = $true
         $currentSection = @()
         #$currentSection += $line.Remove(0,50)
     }
     elseif($capturing){
         if($line -match $sectionEnd){
             $capturing = $false
             $sections += ,($currentSection)
             $currentSection = @()
         }
         else{
             if( -not $line -match "[VmcStats]"){
                 $currentSection += $line.Remove(0,49)
             }
         }
     }
 }
 
 # Here we set a new list to only contain the final data section from the log:
 $dataLines = $sections[$sections.Count-1]
 $data = @()
 
 # Removing last 3 lines to capture only the data lines
 for($i=1;$i -ne $dataLines.Count-3;$i++){
     $data += $dataLines[$i]
 }
 
 # converting to CSV data based on property for readability
 $csvData = $data | ForEach-Object {
     $properties = @{}
     # Split using comma and create key-value pairs
     $_.Trim() -split ', ' | ForEach-Object {
         $key, $value = $_.Split(':', 2).Trim()
         $properties[$key] = $value
     }
     # Output as a PSCustomObject
     [PSCustomObject]$properties
 }
 
 #exporting data to CSV
 $csvData | Export-Csv -Path $csvFilePath -NoTypeInformation
 
 # exporting summary line to text file. May work on this more later..
 $dataLines[$dataLines.Count -2] | Out-File "FileAndFolderSizeCounts.txt" 
 