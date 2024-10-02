# Define the paths to exclude
$ds_install_dir = "C:\ArcGIS"
$ds_content_dir = "C:\arcgisdatastore"
$ds_exe = "ArcGISDataStore.exe"
$javaw_process = "javaw.exe"
$postgres_processes = "postgres.exe"

# Add exclusion for the ArcGIS directories
Add-MpPreference -ExclusionPath $ds_install_dir
Add-MpPreference -ExclusionPath $ds_content_dir

# Add exclusion for javaw.exe
Add-MpPreference -ExclusionProcess $javaw_process
Add-MpPreference -ExclusionProcess $ds_exe
Add-MpPreference -ExclusionProcess $postgres_processes

# Output the current exclusions for verification
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess