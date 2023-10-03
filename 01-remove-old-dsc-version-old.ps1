# Remove PS DSC Module for ArcGIS
#Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS" -Recurses

# Invoke-Command -ScriptBlock {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS" -Recurse} -ComputerName -ComputerName machine1.esri.com,machine2.esri.com,machine3.esri.com
# Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName -ComputerName machine1.esri.com,machine2.esri.com,machine3.esri.com

# Get content from txt file
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"

foreach ($machine in $machinesArrayFromFile) {
    Write-Host "Checking for the existence of the PowerShell DSC Module on $machine"
    Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName $machine
    Invoke-Command -ScriptBlock {Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS" -Recurse} -ComputerName $machine
    Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName $machine
}