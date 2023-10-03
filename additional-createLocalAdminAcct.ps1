# This script creates a local account that can be used with the DSC
# Author: Robert Hadsell
# Date: 18-Nov-2022
#
# Future enhancements:

# Get content from txt file
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"

foreach ($machine in $machinesArrayFromFile) {
    # Create local account
    Invoke-Command -ScriptBlock {
        $username = "arcgis_ps"
        $groups = @("Administrators", "Remote Management Users")
        $Password = Read-Host -AsSecureString
        New-LocalUser $username -Password $password -FullName $username -Description "ArcGIS Service Account" -PasswordNeverExpires
        foreach ($group in $groups) {
            # Add new local user to group(s)
            Add-LocalGroupMember -Group $group -Member $username
        }
    } -ComputerName $machine
}