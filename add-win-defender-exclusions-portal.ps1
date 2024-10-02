# Define the paths to exclude
$portal_install_dir = "C:\ArcGIS"
$portal_content_dir = "C:\arcgisportal"
$portal_exe = "ArcGISPortal.exe"
$javaw_process = "javaw.exe"
$java_process = "java.exe"
$postgres_processes = "postgres.exe"

# Add exclusion for the ArcGIS directories
Add-MpPreference -ExclusionPath $portal_install_dir
Add-MpPreference -ExclusionPath $portal_content_dir

# Add exclusion for javaw.exe
Add-MpPreference -ExclusionProcess $java_process
Add-MpPreference -ExclusionProcess $javaw_process
Add-MpPreference -ExclusionProcess $portal_exe
Add-MpPreference -ExclusionProcess $postgres_processes

# Output the current exclusions for verification
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess