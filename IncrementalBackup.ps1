# Define source folders and destination path
# Replace the following line with the actual source folders (e.g., @("C:\Path1", "D:\Path2"))
$sourceFolders = @("<!-- Insert source folders here -->")
# Replace the following line with the actual destination base path (e.g., "Z:\BackupFolder")
$destinationBase = "<!-- Insert destination path here -->"

# Get current date for folder naming
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupFolder = "$destinationBase\IncrementalBackup_$date"

# Manifest file path (to track backed-up files)
$manifestFile = "$destinationBase\BackupManifest.txt"

# Log file path
$logFile = "$backupFolder\IncrementalBackupLog_$date.txt"

try {
    # Create a new backup folder with the current date
    New-Item -ItemType Directory -Path $backupFolder | Out-Null

    # Load the manifest file if it exists
    if (Test-Path $manifestFile) {
        $manifest = Get-Content $manifestFile | ConvertFrom-Csv
    } else {
        $manifest = @()
    }

    # Loop through each source folder
    foreach ($source in $sourceFolders) {
        if (-Not (Test-Path $source)) {
            Add-Content -Path $logFile -Value "Source folder does not exist: $source"
            continue
        }

        # Get all files in the source directory
        $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            # Log the file being processed
            Add-Content -Path $logFile -Value "Processing file: $($file.FullName)"

            # Skip files with invalid characters in their names
            if ($file.Name -match '[<>:"/\\|?*]') {
                Add-Content -Path $logFile -Value "Skipping file with invalid characters: $($file.FullName)"
                continue
            }

            # Check if the file exists in the manifest
            $manifestEntry = $manifest | Where-Object { $_.FilePath -eq $file.FullName }
            if (-Not $manifestEntry -or $file.LastWriteTime -gt [datetime]$manifestEntry.LastWriteTime) {
                # If the file doesn't exist in the manifest or has been modified, copy it
                $relativePath = $file.FullName.Substring($source.Length + 1)

                # Extract only the drive letter or root folder name from $source
                $sourceName = (Split-Path -Qualifier $source).TrimEnd(':')
                $destinationFile = Join-Path -Path $backupFolder -ChildPath "$sourceName\$relativePath"

                # Handle long file paths by using the \\?\ prefix
                $destinationFile = "\\?\" + $destinationFile

                # Ensure the destination directory exists
                $destinationDir = Split-Path -Path $destinationFile -Parent
                if (-Not (Test-Path $destinationDir)) {
                    New-Item -ItemType Directory -Path $destinationDir | Out-Null
                }

                # Copy the file
                Copy-Item -Path $file.FullName -Destination $destinationFile -Force
                Add-Content -Path $logFile -Value "Copied file from ${source}: $($file.FullName)"

                # Update the manifest
                if ($manifestEntry) {
                    $manifestEntry.LastWriteTime = $file.LastWriteTime.ToString("o")
                } else {
                    $manifest += [PSCustomObject]@{
                        FilePath       = $file.FullName
                        LastWriteTime  = $file.LastWriteTime.ToString("o")
                    }
                }
            }
        }
    }

    # Save the updated manifest
    $manifest | ConvertTo-Csv -NoTypeInformation | Set-Content $manifestFile

    # Log success
    Add-Content -Path $logFile -Value "Incremental backup completed successfully at $date."

    # Delete backups older than 7 days
    $cutoffDate = (Get-Date).AddDays(-7)
    Get-ChildItem -Path $destinationBase -Directory | Where-Object {
        $_.Name -like "IncrementalBackup_*" -and $_.LastWriteTime -lt $cutoffDate
    } | Remove-Item -Recurse -Force

    Add-Content -Path $logFile -Value "Old backups deleted successfully."
} catch {
    # Log error
    Add-Content -Path $logFile -Value "Incremental backup failed at $date. Error: $_"
}
