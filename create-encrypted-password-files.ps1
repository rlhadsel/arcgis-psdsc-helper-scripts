# This script creates encrypted password files on the orchestration machine used for PS DSC deployments.
# Author: Robert Hadsell
# Date: 01-Sept-2022
#
# Future Enhancements:
# 1. Make this loopable so that you generate the password files for x number of passwords needed

Write-Host "password generation starting" -ForegroundColor Magenta

$targetdir = "C:\temp\passwordFiles" # Modify this variable depending on where the txt files should be written to
mkdir $targetdir


Write-Host "Enter the the password for the web server ______________.pfx certificate"


Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$targetdir\arcgispsdscauth0.txt"



Write-Host "Enter in the password for the 'DOMAIN\\SVC_ACCOUNT' account"

Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$targetdir\arcgispsdscauth1.txt"



Write-Host "Enter the the password for the server 'siteadmin' account"

Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$targetdir\arcgispsdscauth2.txt"



Write-Host "Enter the the password for the portal 'portaladmin' account"

Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "$targetdir\arcgispsdscauth3.txt"



Write-Host "password generation complete" -ForegroundColor Green