<#
.SYNOPSIS
    Organizes files in your Downloads folder by type, date, or custom rules.

.DESCRIPTION
    This PowerShell script automatically organizes files in your Downloads folder
    into categorized subdirectories. Supports dry-run mode, duplicate detection,
    and customizable organization rules.

.PARAMETER DownloadsPath
    Path to the Downloads folder. Defaults to user's Downloads folder.

.PARAMETER OrganizeBy
    Organization method: 'Type', 'Date', or 'Custom'. Default is 'Type'.

.PARAMETER DryRun
    If specified, shows what would be done without actually moving files.

.PARAMETER LogPath
    Path to log file. Default: Downloads\organize-log.txt

.PARAMETER ConfigPath
    Path to custom configuration JSON file for organization rules.

.EXAMPLE
    .\Organize-Downloads.ps1 -DryRun
    Shows what would be organized without moving files.

.EXAMPLE
    .\Organize-Downloads.ps1 -OrganizeBy Type
    Organizes files by file type into categorized folders.

.EXAMPLE
    .\Organize-Downloads.ps1 -OrganizeBy Date
    Organizes files by date into year/month folders.

.NOTES
    Author: Claude Code
    Version: 1.0.0
    Created: 2025-11-16
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$DownloadsPath = "$env:USERPROFILE\Downloads",

    [Parameter(Mandatory=$false)]
    [ValidateSet('Type', 'Date', 'Custom')]
    [string]$OrganizeBy = 'Type',

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:USERPROFILE\Downloads\organize-log.txt",

    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "$PSScriptRoot\organize-config.json"
)

# File type categories
$FileCategories = @{
    'Documents' = @('.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.xls', '.xlsx', '.ppt', '.pptx', '.csv', '.md', '.json', '.xml')
    'Images' = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.ico', '.webp', '.tiff', '.raw', '.heic')
    'Videos' = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg')
    'Audio' = @('.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a', '.opus')
    'Archives' = @('.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz', '.iso')
    'Executables' = @('.exe', '.msi', '.dmg', '.app', '.deb', '.rpm', '.appx')
    'Code' = @('.py', '.js', '.java', '.cpp', '.c', '.h', '.cs', '.php', '.rb', '.go', '.rs', '.swift', '.kt', '.html', '.css', '.scss')
    'Ebooks' = @('.epub', '.mobi', '.azw', '.azw3')
    'Fonts' = @('.ttf', '.otf', '.woff', '.woff2')
    'CAD' = @('.dwg', '.dxf', '.stl', '.obj', '.fbx')
}

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

# Load custom configuration if exists
function Get-CustomConfig {
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            Write-Log "Loaded custom configuration from $ConfigPath"
            return $config
        }
        catch {
            Write-Log "Failed to load custom config: $_" -Level 'WARN'
            return $null
        }
    }
    return $null
}

# Get file category based on extension
function Get-FileCategory {
    param([string]$Extension)

    foreach ($category in $FileCategories.Keys) {
        if ($FileCategories[$category] -contains $Extension.ToLower()) {
            return $category
        }
    }
    return 'Other'
}

# Get destination folder based on organization method
function Get-DestinationFolder {
    param(
        [System.IO.FileInfo]$File,
        [string]$Method
    )

    switch ($Method) {
        'Type' {
            $category = Get-FileCategory -Extension $File.Extension
            return Join-Path $DownloadsPath $category
        }
        'Date' {
            $year = $File.LastWriteTime.Year
            $month = $File.LastWriteTime.ToString('MM-MMMM')
            return Join-Path $DownloadsPath "$year\$month"
        }
        'Custom' {
            # Implement custom logic here based on config
            $config = Get-CustomConfig
            if ($config -and $config.rules) {
                foreach ($rule in $config.rules) {
                    if ($File.Name -match $rule.pattern) {
                        return Join-Path $DownloadsPath $rule.destination
                    }
                }
            }
            # Fallback to type-based organization
            $category = Get-FileCategory -Extension $File.Extension
            return Join-Path $DownloadsPath $category
        }
    }
}

# Find and report duplicate files
function Find-Duplicates {
    param([array]$Files)

    Write-Log "Checking for duplicate files..."
    $fileHashes = @{}
    $duplicates = @()

    foreach ($file in $Files) {
        try {
            $hash = Get-FileHash -Path $file.FullName -Algorithm MD5
            if ($fileHashes.ContainsKey($hash.Hash)) {
                $duplicates += [PSCustomObject]@{
                    Original = $fileHashes[$hash.Hash]
                    Duplicate = $file.FullName
                    Size = $file.Length
                }
            }
            else {
                $fileHashes[$hash.Hash] = $file.FullName
            }
        }
        catch {
            Write-Log "Error hashing file $($file.FullName): $_" -Level 'ERROR'
        }
    }

    if ($duplicates.Count -gt 0) {
        Write-Log "Found $($duplicates.Count) duplicate files:"
        foreach ($dup in $duplicates) {
            $sizeKB = [math]::Round($dup.Size / 1KB, 2)
            Write-Log "  - $($dup.Duplicate) (duplicate of $($dup.Original), ${sizeKB}KB)"
        }
    }
    else {
        Write-Log "No duplicates found."
    }

    return $duplicates
}

# Main execution
function Start-Organization {
    Write-Log "====== Downloads Organization Started ======"
    Write-Log "Downloads Path: $DownloadsPath"
    Write-Log "Organization Method: $OrganizeBy"
    Write-Log "Dry Run: $DryRun"

    # Validate downloads path
    if (-not (Test-Path $DownloadsPath)) {
        Write-Log "Downloads path does not exist: $DownloadsPath" -Level 'ERROR'
        return
    }

    # Get all files in Downloads (exclude directories and already organized files)
    $files = Get-ChildItem -Path $DownloadsPath -File | Where-Object {
        $_.DirectoryName -eq $DownloadsPath
    }

    if ($files.Count -eq 0) {
        Write-Log "No files to organize in Downloads folder." -Level 'INFO'
        return
    }

    Write-Log "Found $($files.Count) files to organize"

    # Find duplicates
    $duplicates = Find-Duplicates -Files $files

    # Statistics
    $stats = @{
        TotalFiles = $files.Count
        Moved = 0
        Skipped = 0
        Errors = 0
        CategoriesCreated = @()
    }

    # Organize files
    foreach ($file in $files) {
        try {
            $destination = Get-DestinationFolder -File $file -Method $OrganizeBy
            $destinationPath = Join-Path $destination $file.Name

            # Skip if file is already in correct location
            if ($file.FullName -eq $destinationPath) {
                Write-Log "Skipping (already organized): $($file.Name)" -Level 'DEBUG'
                $stats.Skipped++
                continue
            }

            # Create destination directory if needed
            if (-not (Test-Path $destination)) {
                if (-not $DryRun) {
                    New-Item -Path $destination -ItemType Directory -Force | Out-Null
                }
                if ($stats.CategoriesCreated -notcontains $destination) {
                    $stats.CategoriesCreated += $destination
                }
                Write-Log "Created directory: $destination"
            }

            # Handle file name conflicts
            $counter = 1
            $originalName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $extension = $file.Extension

            while (Test-Path $destinationPath) {
                $newName = "${originalName}_${counter}${extension}"
                $destinationPath = Join-Path $destination $newName
                $counter++
            }

            # Move file
            if ($DryRun) {
                Write-Log "[DRY RUN] Would move: $($file.Name) -> $destination"
            }
            else {
                Move-Item -Path $file.FullName -Destination $destinationPath -Force
                Write-Log "Moved: $($file.Name) -> $destination"
            }

            $stats.Moved++
        }
        catch {
            Write-Log "Error organizing $($file.Name): $_" -Level 'ERROR'
            $stats.Errors++
        }
    }

    # Summary
    Write-Log "====== Organization Complete ======"
    Write-Log "Total files: $($stats.TotalFiles)"
    Write-Log "Moved: $($stats.Moved)"
    Write-Log "Skipped: $($stats.Skipped)"
    Write-Log "Errors: $($stats.Errors)"
    Write-Log "Categories created: $($stats.CategoriesCreated.Count)"

    if ($DryRun) {
        Write-Log "DRY RUN MODE - No files were actually moved."
        Write-Log "Run without -DryRun to perform actual organization."
    }
}

# Run the script
Start-Organization
