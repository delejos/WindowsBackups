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
