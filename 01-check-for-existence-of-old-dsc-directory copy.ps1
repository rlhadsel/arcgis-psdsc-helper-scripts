# This script checks for the existance of the ArcGIS PowerShell DSC Module on all machines participating in the deployment
# Author: Robert Hadsell
# Date: 18-Nov-2022
#
# Future enhancements:

# Example: Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName machine1.esri.com,machine2.esri.com,machine3.esri.com
# Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName list,of,machine,names,no,quotes

# Get content from txt file
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"

foreach ($machine in $machinesArrayFromFile) {
    Write-Host "Checking for the existence of the PowerShell DSC Module on $machine"
    Invoke-Command -ScriptBlock {Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"} -ComputerName $machine
}