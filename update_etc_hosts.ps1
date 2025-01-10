# Define the path to the template hosts file
$templatePath = "C:\path\to\template_hosts.txt"

# Define the path to the hosts file on the local machine
$hostsFilePath = "C:\Windows\System32\drivers\etc\hosts"

# Check if the template hosts file exists
if (Test-Path $templatePath) {
    try {
        # Backup the existing hosts file
        $backupPath = "C:\Windows\System32\drivers\etc\hosts.bak"
        Copy-Item -Path $hostsFilePath -Destination $backupPath -Force

        # Copy the template hosts file to the hosts file location
        Copy-Item -Path $templatePath -Destination $hostsFilePath -Force -ErrorAction Stop
        Write-Host "Updated hosts file successfully."
    } catch {
        Write-Host "Failed to update hosts file: $_"
    }
} else {
    Write-Host "Template hosts file not found at $templatePath."
}