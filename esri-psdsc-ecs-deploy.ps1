# Define the directory path
$directoryPath = "C:\deploy"
$certsPath = "$directoryPath\certs"

# Check if the directory exists
if (-Not (Test-Path -Path $directoryPath)) {
    # Create the directory
    New-Item -Path $directoryPath -ItemType Directory -ErrorAction Stop
    Write-Host "Directory created successfully: $directoryPath"
} else {
    Write-Host "Directory already exists: $directoryPath"
}

# Check if the directory exists
if (-Not (Test-Path -Path $certsPath)) {
    # Create the directory
    New-Item -Path $certsPath -ItemType Directory -ErrorAction Stop
    Write-Host "Directory created successfully: $certsPath"
} else {
    Write-Host "Directory already exists: $certsPath"
}

Write-Host "Enter the the password for the ArcGIS Online Account account"

Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$directoryPath\rhadsell_esrijj.txt"

winrm quickconfig

Set-ExecutionPolicy RemoteSigned -Force

Set-Location C:\Windows\System32

Write-Host " "

# create the LCM file within the System32 directory

Write-Host "    Creating LCM File in C:\Windows\System32" -ForegroundColor Yellow



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

Write-Host "    Finished creating the LCM File" -ForegroundColor Yellow

Write-Host " "

Write-Host "    Setting the LCM to ApplyOnly" -ForegroundColor Yellow

Write-Host " "

# set the local configuration manager

Set-DscLocalConfigurationManager -Path "C:\Windows\System32\LCMConfig"

Write-Host "    Getting the LCM to confirm it changed to 'ApplyOnly', please check" -ForegroundColor Yellow

# get the local configuration manager

Get-DscLocalConfigurationManager -CimSession localhost

Write-Host "    Finished LCM modification - Switched 'ApplyandMonitor' to 'ApplyOnly'" -ForegroundColor Green

Install-Module arcgis -Force

# copy certs
Copy-Item -Path "\\archive\crdata\serverdata\Misc\certs\esri_issuing_ca.cer" -Destination C:\deploy\certs\esri_issuing_ca.cer
Copy-Item -Path "\\archive\crdata\serverdata\Misc\certs\esri_root.cer" -Destination C:\deploy\certs\esri_root.cer
Copy-Item -Path "\\archive\crdata\serverdata\Misc\certs\wildcard_esri.pfx" -Destination C:\deploy\certs\wildcard_esri.pfx

Set-Location $directoryPath

Invoke-ArcGISConfiguration -ConfigurationParametersFile .\1091-BED-minHA-v440json.json -Mode InstallLicenseConfigure -DebugSwitch -EnableMSILogging

