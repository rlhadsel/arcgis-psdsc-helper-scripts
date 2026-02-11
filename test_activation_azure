$vmNames = ""
$ErrorActionPreference = "Stop"
$datetime = Get-Date -Format yyyy_MM_dd_HHmm
$loggingDirectory = "C:\ArcGISActivation\Logs"
$utilitiesDirectory = "C:\ArcGISActivation\Utilities"
New-Item -ItemType Directory -Force -Path $loggingDirectory
New-Item -ItemType Directory -Force -Path $utilitiesDirectory
$logfile = "$($loggingDirectory)\$($datetime).log"
$vmArray = $vmNames -split ","
$webAdaptor = $vmArray | Where-Object {$_ -like "*web*vm"}
$configPath = "C:\ArcGISActivation\Utilities\GISServer_Foundational.json"

#Function to write to a log output file in for visibility as this will be run automatically
Function Write-Log
{
   Param ([string]$logstring)
    $logtime = Get-Date -Format yyyy_MM_dd_HHmmss
   Add-content $logfile -value ($logtime + " - " + $logstring)
}

Function Install-PSPackageProvider
{
    Param ([string]$providerName)

    try {
        Write-Log "Importing $($providerName) package provider..." 
        Import-PackageProvider -Name $providerName
    }
    catch {
        try {
            Write-Log "Unable to import $($providerName) package provider, attempting to install it instead..." 
            Install-PackageProvider -Name "Nuget" -Force -Scope "AllUsers"
        }
        catch {
            Write-Log "Error encountered while installing $($providerName) package provider. Error: $($_)" 
        }
    }
}

Function Install-PSModule 
{
    Param ([string]$moduleName, [string]$requiredVersion)

    try {
        Write-Log "Importing $($moduleName) Powershell module..." 
        Import-Module -Name $moduleName -RequiredVersion $requiredVersion
    }
    catch {
        try {
            Write-Log "Unable to import $($moduleName) Powershell module, attempting to install it instead..." 
            Install-Module -Name $moduleName -RequiredVersion $requiredVersion -Repository "PSGallery" -Force -AllowClobber
            Import-Module -Name $moduleName -RequiredVersion $requiredVersion
            Write-Log "Installed and imported $($moduleName) module successfully."
        }
        catch {
            Write-Log "Error encountered while installing $($moduleName) Powershell module. Error: $($_.Exception.Message)" 
        }
    }
}

#Setup WinRM trusted hosts for federation
Start-Service "WinRM"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmNames -Force

#Make sure that the Azure Powershell modules are imported
Install-PSPackageProvider -providerName "Nuget"
Install-PSModule -moduleName "Az" -requiredVersion "10.4.1"
Install-PSModule -moduleName "arcgis" -requiredVersion "4.3.0"
Write-Log "Importing WebAdministration module..."
Import-Module WebAdministration

#Set LCM to ApplyOnly
#Consult H&P on ActioAfterReboot conflicts
$script = @'
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            ConfigurationMode = "ApplyOnly"
            ActionAfterReboot = "StopConfiguration"
        }
    }
}
LCMConfig
'@
$script > $utilitiesDirectory\LCMConfig.ps1
Set-Location -Path $utilitiesDirectory
& "$($utilitiesDirectory)\LCMConfig.ps1"
Set-DscLocalConfigurationManager -Path "$($utilitiesDirectory)\LCMConfig"

#log into Azure with the VM's managed identity
Write-Log "Signing into Azure with managed identity..."
Connect-AzAccount -Identity -AccountId ""
Write-Log "Successfully signed into Azure..."

#Create storage context
Write-Log "Creating storage context..."
$ctx = New-AzStorageContext -StorageAccountName ""
Write-Log "Successfully created storage context..."

#Download SQL ODBC Drivers
Write-Log "Downloading SQL ODBC Driver..."
Get-AzStorageBlobContent -Container "" -Blob "" -Context $ctx -Destination $utilitiesDirectory -Force
Write-Log "Successfully downloaded configuration file..."

#Create encrypted password files from key vault
# NEED TO ADD LOGIC TO REMOVE THESE AT THE END
$keyVault = ""
$portalSecretName = "portal-signature" 
$sqlPWSecretName =  "sql-pw"
$localPWSecretName =  "vm-pw"
$sdePWSecretName = "sde-pw"
$sitePWSecretName = "site-pw"
$dbPWSecretName = "db-pw"
$agoPWSecretName = "ago-pw"
$portalPWSecretName = "portal-pw"

Write-Log "Retrieving passwords from key vault and storing in encrypted files..."
$sql_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $sqlPWSecretName -AsPlainText
$sql_password = $sql_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$sql_password > $utilitiesDirectory\sql_password.txt
$siteAdmin_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $sitePWSecretName -AsPlaintext
$siteAdmin_password = $siteAdmin_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$siteAdmin_password > $utilitiesDirectory\siteAdmin_password.txt
$local_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $localPWSecretName -AsPlainText
$local_password = $local_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$local_password > $utilitiesDirectory\local_password.txt
$sde_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $sdePWSecretName -AsPlainText
$sde_password = $sde_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$sde_password > $utilitiesDirectory\sde_password.txt
$db_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $dbPWSecretName -AsPlainText
$db_password = $db_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$db_password > $utilitiesDirectory\db_password.txt
$ago_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $agoPWSecretName -AsPlainText
$ago_password = $ago_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$ago_password > $utilitiesDirectory\ago_password.txt
$portal_password = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $portalPWSecretName -AsPlainText
$portal_password = $portal_password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
$portal_password > $utilitiesDirectory\portal_password.txt

Write-Log "Successfully retrieved and encrypted all passwords..."

#Determine machine role and local admin user
$vmMetadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri http://169.254.169.254/metadata/instance?api-version=2020-09-01
$roleTag = $vmMetadata.compute.tags.Split(";") | Select-String -Pattern "role:"
$roleTag = Out-String -InputObject $roleTag
$role = $roleTag.Substring($roleTag.IndexOf(":")+1)
$role = $role.Trim().ToLower()
$username = $vmMetadata.compute.osProfile.adminUsername
$domain = "."
$fulluser = "${domain}\${username}"
$securePassword = Get-Content "${utilitiesDirectory}\local_password.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $fulluser, $securePassword

#conditional web adaptor logic
if($role -eq "web adaptor") {
    #Bind the certificate from the key vault extension to 443 for the web adaptor
    $webBinding = Get-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
    if(!$webBinding){
        New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
    }
    Get-Item -Path IIS:\SslBindings\*!443 | Remove-Item
    Get-ChildItem cert:\localmachine\My | Where-Object {$_.DnsNameList -match $hostName} | New-Item -Path IIS:\SslBindings\*!443 -Force
    Set-WebConfigurationProperty -Filter 'system.webServer/security/requestFiltering/requestLimits' -PSPath "IIS:\sites\Default Web Site" -Name "maxQueryString" -Value 4096
}

#Execute ESRI modules if one of the orchestrator roles
$orchestratorRoles = @("portal", "mapping", "image", "geoprocessing", "mapping02", "mapping03","mapping04","mapping05","mapping06")
if($orchestratorRoles -contains $role){
    $maxRetries = 30
    $currentRetries = 0
    $newcimsession = New-CimSession -ComputerName $webAdaptor -Credential $credential
    while($currentRetries -ne $maxRetries){
        try{
            Write-Log "Checking if DSC is already running against the web adaptor..."
            Get-DscConfigurationStatus -CimSession $newcimsession -All
            Write-Log "Web adaptor is available for configuration..."
            Write-Log "Starting ArcGIS configuration..."
            Invoke-ArcGISConfiguration -ConfigurationParametersFile $configPath -Mode "InstallLicenseConfigure" -Credential $credential
            Write-Log "ArcGIS configuration complete..."
            break
        } catch {
            Write-Log "Web adaptor already has a configuration running against it. Retrying in 2 minutes..."
            Write-Log $_.Exception
            $currentRetries += 1
            Start-Sleep -Seconds 120
        }
    }
}else{
    Write-Log "Machine is not an orchestrator, skipping to the end..."
}

#Install the OpenSSH Server so we can bastion in via SSH and Terraform remote-exec
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
#Start the sshd service and ensure it is automatically started on reboot
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

#Set the Python path for Azure Automation
[System.Environment]::SetEnvironmentVariable("PYTHON_3_PATH", $pythonPath, "Machine")

#Download the Python post configuration script only if this is the portal machine
if($role -eq "portal") {
    Write-Log "Downloading Python post configuration script..."
    Get-AzStorageBlobContent -Container $storageContainer -Blob $postconfigBlob -Context $ctx -Destination $utilitiesDirectory -Force
    Write-Log "Successfully downloaded Python post configuration script..."

    #Execute Python post configuration script
    Write-Log "Executing portal post configuration..."
    &$pythonPath"\python.exe" $utilitiesDirectory"\"$postconfigBlob
    Write-Log "Portal post configuration complete..."
}

#NOTE: we'd like to clean up the license files, but they need to be present on the nodes when the portal machine orchestrates
#Write-Log "Cleaning up license files..."
#Remove-Item -Path "$($prvcPath).prvc"
#Remove-Item -Path "$($utilitiesDirectory)\portal.json" 
Write-Log "Installation and configuration is complete. Exiting..."
Exit
Exit
