# Define the service name
$serviceName = "ArcGIS Server"

# Stop the service
try {
    Stop-Service -Name $serviceName -Force -ErrorAction Stop
    Write-Host "Attempting to stop the service: $serviceName"
} catch {
    Write-Host "Failed to stop the service: $_"
    exit
}

# Wait for a moment to allow the service to stop
Start-Sleep -Seconds 5

# Check the status of the service
$service = Get-Service -Name $serviceName

if ($service.Status -eq 'Stopped') {
    Write-Host "The service '$serviceName' has stopped successfully."
} else {
    Write-Host "The service '$serviceName' is still running. Current status: $($service.Status)"
}