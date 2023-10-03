#Brendan Bladdick
#
#Switch LCM from ApplyAndMonitor to ApplyOnly

# Get content from txt file
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"

$parameters = @{
    ComputerName = $machinesArrayFromFile
    ScriptBlock = 
        {
            Write-Host "Starting LCM modification - Switching 'ApplyandMonitor' to 'ApplyOnly' for $(hostname)" -ForegroundColor Magenta

            Set-Location "C:\Windows\System32"
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

