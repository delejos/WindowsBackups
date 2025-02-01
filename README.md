Disclaimer: This was created as part of a learning exercise, as a source to use PowerShell. Yes, Robocopy exist and can do a much better job than this alternative. Again, it's just an exercise. 
# Incremental Backup Script

This PowerShell script performs incremental backups of specified source folders to a destination path. It tracks changes using a manifest file and logs all operations for debugging and auditing purposes.

## Features
- Incremental backup: Only copies files that are new or modified.
- Handles long file paths by using the `\\?\` prefix.
- Deletes old backups older than 7 days to save space.
- Logs all actions to a log file for traceability.

## Prerequisites
- PowerShell 5.1 or later.
- Administrative privileges (if accessing certain directories).

## Usage
1. Replace the placeholders in the script:
   ```powershell
   $sourceFolders = @("<!-- Insert source folders here -->")
   $destinationBase = "<!-- Insert destination path here -->"

$sourceFolders = @("C:\Users\USER1\Desktop", "D:\", "F:\")
$destinationBase = "Z:\Backups"

## Save the file and run the script in PowerShell:
- .\IncrementalBackup.ps1

## Customization
- Modify the $cutoffDate variable to change the retention period for old backups.
- Adjust logging behavior by editing the $logFile section.
