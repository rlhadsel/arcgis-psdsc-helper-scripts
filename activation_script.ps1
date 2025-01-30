#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility
<#
.SYNOPSIS
usfs-arcgis-activation.ps1

.DESCRIPTION
Downloads and installs the ESRI PowerShell DSC [https://github.com/Esri/arcgis-powershell-dsc] Modules to the default powershell path.
Also runs setup commands for DSC and WinRM that ESRI recommends before running their DSC module, see # https://github.com/Esri/arcgis-powershell-dsc/wiki/V4.-Getting-Started#supported-operating-system-os-platforms
for more info. 
This script must be run on all target nodes before the Invoke-ArcGISConfiguration DSC function is executed on the orchestrating node.

.PARAMETERS
None

.INPUTS
None

.OUTPUTS
None.

.NOTES
Version:        1.0
Authors:        Robert Hadsell
Creation Date:  12-Aug-2024
Purpose/Change: Initial script development

#>

########################### Define log file ###########################
$Logfile = "C:\deploy\$(gc env:computername).log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

########################### Set working Directory ###########################
$working_directory = "C:\deploy"
if (-not (Test-Path -Path $working_directory -PathType Container)) { 
    New-Item -ItemType Directory -Path $working_directory -Force
    Set-Location $working_directory
    LogWrite "Created working directory: $working_directory"
    } 
else { 
    LogWrite "'$working_directory' already exists."
    Set-Location $working_directory
}

####################################################################################
########################### Create Administrator Account ###########################
####################################################################################

########### Create Admin Account ###########
$NewLocalAdmin = "" # update this to a name you would like to use, if deploying with a local admin account
$Password = "" # this could be a value pulled from keyvault or passed in by terraform during the deployment
$securedPassword = ConvertTo-SecureString $Password -AsPlainText -Force
# this helped with the securedPassword arguments: https://ichappas.wordpress.com/2019/10/08/windows-local-user-from-aws-ssm-manager/
New-LocalUser "$NewLocalAdmin" -Password $securedPassword -FullName "$NewLocalAdmin" -Description "Local Esri Admin" -AccountNeverExpires -PasswordNeverExpires > $working_directory\create_admin_acct.txt
LogWrite "Created $NewLocalAdmin account."
Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdmin" > $working_directory\admin_group.txt
LogWrite "Added $NewLocalAdmin account to Administrators group on machine."
Add-LocalGroupMember -Group "Remote Management Users" -Member "$NewLocalAdmin" > $working_directory\remote_mgmnt_group.txt
LogWrite "Created $NewLocalAdmin account to Remote Management Users group on machine."

########### Allow Port 445 for File Share ###########
New-NetFirewallRule -DisplayName "Allow 445 Outbound" -Direction Outbound -LocalPort 445 -Protocol TCP -Action Allow > $working_directory\outbound_firewall_rules.txt
LogWrite "Added firewall rule to allow traffic on port 445 outbound."
New-NetFirewallRule -DisplayName "Allow 445 Inbound" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow > $working_directory\inbound_firewall_rules.txt
LogWrite "Added firewall rule to allow traffic on port 445 inbound."

#############################################################################################
########################### Install PowerShell DSC Pre-requisties ###########################
#############################################################################################

########### Set Execution Policy ###########
if ( ( (Get-ExecutionPolicy) -ne "RemoteSigned" ) -and ( (Get-ExecutionPolicy) -ne "Unrestricted" ) ) { 
    LogWrite "Setting ExecutionPolicy to RemoteSigned..."
    Set-ExecutionPolicy RemoteSigned -Force > $working_directory\set_execution_policy.txt
    LogWrite "Successfully Set ExecutionPolicy to RemoteSigned."

} 
else { 
    Write-Host "ExecutionPolicy set to RemoteSigned or Unrestricted." 
    $execution_policy = Get-ExecutionPolicy
    LogWrite "ExecutionPolicy set to $execution_policy."
}

########### Download the PowerShell DSC Module from PowerShell Gallery ###########
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force > $working_directory\install_nuget.log
LogWrite "Installed NuGet."
Install-Module ArcGIS -Force > $working_directory\install_arcgis_module.log
LogWrite "Installed ArcGIS Module."



########### configure winrm ###########
winrm quickconfig -Force > $working_directory\config_winrm.log
LogWrite "Enabled winrm."

########### Configure LCM ###########
Set-Location C:\Windows\System32

[DSCLocalConfigurationManager()]

configuration LCMConfig {
    Node localhost {
        Settings {
            ConfigurationMode = 'ApplyOnly'
            ActionAfterReboot = 'StopConfiguration'
        }
    }
}
LCMConfig

Set-DscLocalConfigurationManager -Path "C:\Windows\System32\LCMConfig" -Force > $working_directory\set_lcm.txt
LogWrite "Set LCM Settings to ConfigurationMode = ApplyOnly and ActionAfterReboot = StopConfiguration."
Get-DscLocalConfigurationManager -CimSession localhost > $working_directory\get_lcm.txt

########### Set Trusted Hosts ###########
winrm s winrm/config/client '@{TrustedHosts="*"}' > $working_directory\trusted_hosts.txt # this can also be a list of IPs/FQDNS instead of the wildcard (*) value
LogWrite "Set trusted hosts."

## sleep 5 minutes to allow other nodes to finish spinning up: https://www.sharepointdiary.com/2020/09/powershell-sleep-command.html
$total = 360
$count = $total
 
while ($count -gt 0) {

 "$count seconds remaining..." >> $working_directory\timer.txt
 Start-Sleep -Seconds 1
 $count--

}

#################################################################################################
########################### Run the Invoke-ArcGISConfiguration cmdlet ###########################
#################################################################################################
# The code below should only be ran from the orchestration machine
# This code SHOULD NOT be ran on all of the VMs in the deployment, only the machine denoted as the orchestration VM

# Run powershell as adminitrator
Set-Location $working_directory

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $NewLocalAdmin, $securedPassword

Invoke-ArcGISConfiguration -ConfigurationParametersFile "C:\path\to\json\config.json" -Mode InstallLicenseConfigure -DebugSwitch -EnableMSILogging -Credential $credential

# additional Invoke-ArcGISConfiguration statements could be defined below


