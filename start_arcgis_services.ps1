# Define the service name
$serviceName = "ArcGIS Server"

# Start the service
try {
    Start-Service -Name $serviceName -ErrorAction Stop
    Write-Host "Attempting to start the service: $serviceName"
} catch {
    Write-Host "Failed to start the service: $_"
    exit
}

# Wait for a moment to allow the service to start
Start-Sleep -Seconds 5

# Check the status of the service
$service = Get-Service -Name $serviceName

if ($service.Status -eq 'Started') {
    Write-Host "The service '$serviceName' has started successfully."
} else {
    Write-Host "The service '$serviceName' is still stopped. Current status: $($service.Status)"
}