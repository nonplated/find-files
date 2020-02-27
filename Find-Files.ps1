

function Find-Files {

<#
.SYNOPSIS
Function to find some files (pattern like *.*) in specified directories (with all subdirectories)

.DESCRIPTION
Tested on Windows 10
Winter, 2020 (Not So Cold)

.PARAMETER SearchPattern
Pattern of files to find: *.*, *.bmp

.PARAMETER Dirs
The directories where look.

.PARAMETER PrintFileNames
Set if filenames should be outputed.

.PARAMETER RemovableDrives
Set to search files on USB,CD,DVD drives too.

.PARAMETER NoSummary
Dont show calculating about found files.

.EXAMPLE
PS > Find-Files -PrintFileNames *.mp4

.EXAMPLE
PS > Find-Files -?

.EXAMPLE
PS > Find-Files *.pdf

Search all fixed drives (without removable drives)

.EXAMPLE
PS > Find-Files @("*.txt","*.log")

Search txt and log files

.EXAMPLE
PS > Find-Files *.pdf -PrintFileNames

Search all fixed drives and plot file names (full path)

.EXAMPLE
PS > Find-Files *.pdf -Dirs @("C:\Windows","C:\Users")

Search only selected directories (with all subdirs)

.EXAMPLE
PS > Find-Files *.pdf -RemovableDrives

Search all drives included removable (like CD-ROM, USB-Flash)

.EXAMPLE
PS > Find-Files *.pdf -PrintFileNames | Out-File -FilePath "C:\output.txt"

if you want to save filenames output to file

.EXAMPLE
PS > Find-Files *.pdf -PrintFileNames -NoSummary | Out-File -FilePath "C:\output_no_summary.txt"

Save filenames, but with no summary

.LINK
https://github.com/nonplated/powershell
#>

    param (
        [Parameter(Mandatory=$true)][string]$SearchPattern,
        [string[]]$Dirs="",
        [switch]$PrintFileNames=$false,
        [switch]$RemovableDrives=$false,
        [switch]$NoSummary=$false
    )

    if (!$Dirs) {
        # get all volumes letters (only volumes with letter and not removable)
        $Dirs = Get-Volume `
            | Where-Object {
                $_.DriveLetter -and ($RemovableDrives -or ($_.DriveType -eq "fixed"))
            } `
            | Sort-Object -unique DriveLetter `
            | ForEach-Object {
                $_.DriveLetter+":\"
            }
        Write-Host "Found drives: $Dirs"
    }

    Write-Host "Looking for files ($SearchPattern) in directories ($Dirs)..."

    #search every location
    ForEach ($Dir in $Dirs) {
        $TotalLength = 0 #file size [B]
        $TotalFiles = 0
        Get-Childitem $Dir -Include $SearchPattern -Recurse -ErrorAction SilentlyContinue `
            | ForEach-Object {
                $TotalLength += $_.Length;
                $TotalFiles += 1;
                if ($PrintFileNames) { "$_" };
            }
        if (!$NoSummary) {
            $TotalLength = ($TotalLength/(1024*1024)).ToString('0') #convert B to MB
            Write-Host ""
            Write-Host " # In directory: $Dir"
            Write-Host " # Total files: $TotalFiles"
            Write-Host " # Total size: $TotalLength MB"
        }
    }
}
