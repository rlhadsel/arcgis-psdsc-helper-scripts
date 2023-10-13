# This script adds the exclusions for the windows defender AV
# Author: Robert Hadsell
# Date: 13-Oct-2023

Add-MpPreference -ExclusionPath "C:\Program Files\ArcGIS"
Add-MpPreference -ExclusionProcess "java.exe"
Add-MpPreference -ExclusionProcess "javaw.exe"
Add-MpPreference -ExclusionProcess "postgres.exe"
Add-MpPreference -ExclusionPath "C:\arcgisdatastore"
Add-MpPreference -ExclusionPath "C:\arcgisserver"
Add-MpPreference -ExclusionPath "C:\arcgisportal"