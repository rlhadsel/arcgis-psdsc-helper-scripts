# Define the paths to exclude
$ags_install_dir = "C:\ArcGIS"
$ags_content_dir = "C:\arcgisserver"
$ags_exe = "ArcGISServer.exe"
$javaw_process = "javaw.exe"
$arcsoc_processes = "ArcSOC.exe"

# Add exclusion for the ArcGIS directories
Add-MpPreference -ExclusionPath $ags_install_dir
Add-MpPreference -ExclusionPath $ags_content_dir

# Add exclusion for javaw.exe
Add-MpPreference -ExclusionProcess $javaw_process
Add-MpPreference -ExclusionProcess $ags_exe
Add-MpPreference -ExclusionProcess $arcsoc_processes

# Output the current exclusions for verification
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess