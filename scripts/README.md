# Downloads Organizer - PowerShell Script

Automatically organize your Windows Downloads folder into categorized subdirectories.

## Features

- **Multiple Organization Methods**: By file type, date, or custom rules
- **Dry Run Mode**: Preview changes before executing
- **Duplicate Detection**: Find and report duplicate files
- **Customizable**: JSON-based configuration for custom rules
- **Detailed Logging**: Track all operations with timestamps
- **Safe**: Handles file name conflicts automatically

## Quick Start

### 1. Basic Usage (Organize by File Type)

```powershell
# Preview what will be organized (dry run)
.\Organize-Downloads.ps1 -DryRun

# Actually organize files
.\Organize-Downloads.ps1
```

### 2. Organize by Date

```powershell
# Organizes into Year\Month folders
.\Organize-Downloads.ps1 -OrganizeBy Date
```

### 3. Custom Organization Rules

```powershell
# Uses rules from organize-config.json
.\Organize-Downloads.ps1 -OrganizeBy Custom -ConfigPath .\organize-config.json
```

## Installation

### Option 1: Run from VS Code

1. Open VS Code
2. Open the terminal (`` Ctrl+` `` or `View > Terminal`)
3. Navigate to the scripts folder:
   ```powershell
   cd path\to\-homelab.automation\scripts
   ```
4. Run the script:
   ```powershell
   .\Organize-Downloads.ps1 -DryRun
   ```

### Option 2: Run from Warp Terminal

1. Open Warp
2. Navigate to scripts folder
3. Execute the script

### Option 3: Run from PowerShell

1. Press `Win + X`, select "Windows PowerShell" or "Terminal"
2. Navigate to scripts folder
3. You may need to adjust execution policy:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. Run the script

## File Categories

The script organizes files into these categories by default:

| Category | File Types |
|----------|------------|
| **Documents** | .pdf, .doc, .docx, .txt, .rtf, .odt, .xls, .xlsx, .ppt, .pptx, .csv, .md, .json, .xml |
| **Images** | .jpg, .jpeg, .png, .gif, .bmp, .svg, .ico, .webp, .tiff, .raw, .heic |
| **Videos** | .mp4, .avi, .mkv, .mov, .wmv, .flv, .webm, .m4v, .mpg, .mpeg |
| **Audio** | .mp3, .wav, .flac, .aac, .ogg, .wma, .m4a, .opus |
| **Archives** | .zip, .rar, .7z, .tar, .gz, .bz2, .xz, .iso |
| **Executables** | .exe, .msi, .dmg, .app, .deb, .rpm, .appx |
| **Code** | .py, .js, .java, .cpp, .c, .h, .cs, .php, .rb, .go, .rs, .swift, .kt, .html, .css, .scss |
| **Ebooks** | .epub, .mobi, .azw, .azw3 |
| **Fonts** | .ttf, .otf, .woff, .woff2 |
| **CAD** | .dwg, .dxf, .stl, .obj, .fbx |
| **Other** | Everything else |

## Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `-DownloadsPath` | Path to Downloads folder | `$env:USERPROFILE\Downloads` | `-DownloadsPath "C:\Users\YourName\Downloads"` |
| `-OrganizeBy` | Method: Type, Date, or Custom | `Type` | `-OrganizeBy Date` |
| `-DryRun` | Preview without moving files | `$false` | `-DryRun` |
| `-LogPath` | Path to log file | `Downloads\organize-log.txt` | `-LogPath "C:\Logs\organize.log"` |
| `-ConfigPath` | Path to config JSON | `.\organize-config.json` | `-ConfigPath ".\my-rules.json"` |

## Custom Configuration

Edit `organize-config.json` to create custom organization rules:

```json
{
  "description": "Custom organization rules",
  "rules": [
    {
      "name": "Work Documents",
      "pattern": "(?i)(work|meeting|invoice).*\\.(pdf|docx?)",
      "destination": "Work"
    },
    {
      "name": "Screenshots",
      "pattern": "(?i)screenshot.*",
      "destination": "Screenshots"
    }
  ]
}
```

### Rule Format

- **name**: Descriptive name for the rule
- **pattern**: Regular expression to match file names
- **destination**: Subfolder name in Downloads

### Regex Examples

- `(?i)work.*` - Files starting with "work" (case-insensitive)
- `.*\\.pdf$` - All PDF files
- `^screenshot.*` - Files starting with "screenshot"
- `(invoice|receipt).*` - Files containing "invoice" or "receipt"

## Examples

### Example 1: First-Time Organization

```powershell
# See what will happen
PS> .\Organize-Downloads.ps1 -DryRun

[2025-11-16 14:30:00] [INFO] ====== Downloads Organization Started ======
[2025-11-16 14:30:00] [INFO] Found 147 files to organize
[2025-11-16 14:30:00] [INFO] Checking for duplicate files...
[2025-11-16 14:30:01] [INFO] Found 3 duplicate files
[2025-11-16 14:30:01] [INFO] [DRY RUN] Would move: report.pdf -> Documents
[2025-11-16 14:30:01] [INFO] [DRY RUN] Would move: vacation.jpg -> Images
...

# Looks good? Run for real
PS> .\Organize-Downloads.ps1

[2025-11-16 14:35:00] [INFO] Moved 147 files successfully
```

### Example 2: Organize by Date (Archive Old Downloads)

```powershell
PS> .\Organize-Downloads.ps1 -OrganizeBy Date

# Creates structure like:
# Downloads/
#   2024/
#     01-January/
#     02-February/
#   2025/
#     11-November/
```

### Example 3: Custom Rules for Obsidian Files

```powershell
# Edit organize-config.json to add:
{
  "rules": [
    {
      "name": "Obsidian Exports",
      "pattern": ".*obsidian.*",
      "destination": "Obsidian-Sync"
    }
  ]
}

# Run with custom rules
PS> .\Organize-Downloads.ps1 -OrganizeBy Custom
```

## Logging

All operations are logged to `Downloads\organize-log.txt` by default:

```
[2025-11-16 14:30:00] [INFO] ====== Downloads Organization Started ======
[2025-11-16 14:30:00] [INFO] Downloads Path: C:\Users\YourName\Downloads
[2025-11-16 14:30:00] [INFO] Found 147 files to organize
[2025-11-16 14:30:01] [INFO] Created directory: C:\Users\YourName\Downloads\Documents
[2025-11-16 14:30:01] [INFO] Moved: report.pdf -> Documents
[2025-11-16 14:30:01] [ERROR] Error organizing locked-file.exe: File is in use
[2025-11-16 14:30:15] [INFO] ====== Organization Complete ======
```

## Safety Features

1. **Dry Run Mode**: Always test with `-DryRun` first
2. **File Conflict Handling**: Automatically renames duplicates (e.g., `file_1.pdf`, `file_2.pdf`)
3. **Only Top-Level Files**: Doesn't touch files already in subdirectories
4. **Detailed Logging**: Track every operation
5. **Error Handling**: Continues processing even if individual files fail

## Troubleshooting

### "Cannot run scripts" Error

```powershell
# Allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Access Denied" Errors

- Close programs that might have files open (browsers, PDF readers, etc.)
- Run PowerShell as Administrator
- Check file permissions

### Files Not Being Organized

- Use `-DryRun` to see what would happen
- Check the log file for errors
- Ensure files are in the top level of Downloads (not in subdirectories)

### Custom Rules Not Working

- Validate JSON syntax: https://jsonlint.com/
- Test regex patterns: https://regex101.com/
- Check `-ConfigPath` points to correct file

## Integration with Obsidian/SyncThing

This script is designed to organize your Downloads folder **before** syncing Obsidian vaults with SyncThing:

1. **First**: Run this script to organize downloads
2. **Then**: Set up SyncThing to sync organized folders
3. **Finally**: Configure Obsidian to use synced vault locations

### Recommended Workflow

```powershell
# 1. Organize downloads with custom Obsidian rules
.\Organize-Downloads.ps1 -OrganizeBy Custom

# 2. Now your Downloads/Obsidian-Sync folder is organized
# 3. Point SyncThing to Downloads/Obsidian-Sync
# 4. Configure Obsidian vaults after sync completes
```

## Scheduling (Optional)

### Run automatically on login:

1. Open Task Scheduler (`taskschd.msc`)
2. Create Basic Task
3. Trigger: "When I log on"
4. Action: "Start a program"
5. Program: `powershell.exe`
6. Arguments: `-File "C:\path\to\Organize-Downloads.ps1"`

### Run weekly:

Use Windows Task Scheduler with a weekly trigger.

## Contributing

This script is part of the Homelab Automation project. Feel free to:
- Add new file categories
- Improve duplicate detection
- Add custom organization methods
- Enhance logging

## Version History

- **1.0.0** (2025-11-16): Initial release
  - Type, Date, and Custom organization methods
  - Duplicate detection
  - Dry run mode
  - JSON configuration

## License

MIT License - Part of the Homelab Automation project

## Support

For issues or questions:
1. Check the log file at `Downloads\organize-log.txt`
2. Run with `-DryRun` to preview
3. Review this README
4. Check the homelab automation repository

---

**Happy Organizing!** 🗂️
