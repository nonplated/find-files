<#
    (Powershell)

    Function to find some files (pattern like *.*) in specified directories (with all subdirectories)

    See at bottom for examples

    Tested on Windows 10 
    
    Winter, 2020 (Not So Cold)
#>

function Find-Files {
    
    param (
        $SearchPattern,
        $Dirs="",
        [switch]$PrintFileNames=$false,
        [switch]$RemovableDrives=$false,
        [switch]$Summary=$true
    )

    if (!$Dirs) {
        # get all volumes letters (only volumes with letter and not removable)
        $Dirs = Get-Volume | 
            Where-Object { 
                $_.DriveLetter -and ($RemovableDrives -or ($_.DriveType -eq "fixed")) 
            } | 
            ForEach-Object { 
                $_.DriveLetter+":\" 
            }
    }

    Write-Host "Looking for files ($SearchPattern) in directories ($Dirs)..."

    #search every location
    ForEach ($Dir in $Dirs) {
        $TotalLength = 0 #file size [B]
        $TotalFiles = 0
        Get-Childitem $Dir -Include $SearchPattern -Recurse -ErrorAction SilentlyContinue | 
            ForEach-Object { 
                $TotalLength += $_.Length; 
                $TotalFiles += 1; 
                if ($PrintFileNames) { "$_" }; 
            }
        if ($Summary) {
            $TotalLength = ($TotalLength/(1024*1024)).ToString('0') #convert B to MB
            Write-Host ""
            Write-Host " # In directory: $Dir"
            Write-Host " # Total files: $TotalFiles"
            Write-Host " # Total size: $TotalLength MB"
        }
    }
}


########################
####    Examples    ####
########################

Find-Files *.pdf
#search all fixed drives (without removable drives)

Find-Files *.pdf -PrintFileNames
#search all fixed drives and plot file names (full path)

Find-Files *.pdf -Dirs @("C:\Windows","C:\Users") 
#search only selected directories (with all subdirs)
                                              
Find-Files *.pdf -RemovableDrives           
#search all drives included removable (like CD-ROM, USB-Flash)

Find-Files *.pdf -PrintFileNames | Out-File -FilePath "C:\output.txt" 
#if you want to save filenames output to file

Find-Files *.pdf -PrintFileNames -Summary:$false | Out-File -FilePath "C:\output_no_summary.txt"
#save filenames, but with no summary
