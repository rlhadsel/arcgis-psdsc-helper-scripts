#Brendan Bladdick
#
#Switch LCM from ApplyAndMonitor to ApplyOnly

# This script checks for the existance of the ArcGIS PowerShell DSC Module on all machines participating in the deployment
# Author: Robert Hadsell
# Date: 01-Sept-2022
#
# Future enhancements:
# 1. Make this loopable so that you pass it a list of machine names via csv or txt file


#$arcgisservers=@('ps0016608.esri.com','ps0016607.esri.com','ps0016609.esri.com')
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"
$parameters = @{
    ComputerName = $machinesArrayFromFile
    ScriptBlock = 
        {
            Write-Host "Starting LCM modification - Switching 'ApplyandMonitor' to 'ApplyOnly' for $(hostname)" -ForegroundColor Magenta
            C:
            cd C:\Windows\System32
            Write-Host " "
            # create the LCM file within the System32 directory
            Write-Host "    Creating LCM File in C:\Windows\System32 for $(hostname)" -ForegroundColor Yellow

            [DSCLocalConfigurationManager()]
            configuration LCMConfig
            {
            Node localhost
            {
            Settings
            {
            ConfigurationMode = 'ApplyOnly'
            ActionAfterReboot = 'StopConfiguration'
            }
            }
            }
            LCMConfig

            Write-Host " "
            Write-Host " "
            Write-Host "    Finished creating the LCM File for $(hostname)" -ForegroundColor Yellow
            Write-Host " "
            Write-Host "    Setting the LCM to ApplyOnly for $(hostname)" -ForegroundColor Yellow
            Write-Host " "
            # set the local configuration manager 
            Set-DscLocalConfigurationManager -Path "C:\Windows\System32\LCMConfig"
            Write-Host "    Getting the LCM to confirm it changed to 'ApplyOnly', please check for $(hostname)" -ForegroundColor Yellow
            # get the local configuration manager 
            Get-DscLocalConfigurationManager -CimSession localhost
            Write-Host "    Finished LCM modification - Switched 'ApplyandMonitor' to 'ApplyOnly' for $(hostname)" -ForegroundColor Green
        }
    }
Invoke-Command @parameters

