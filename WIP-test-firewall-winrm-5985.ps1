# Parse the dsc.json file to get the Nodes
$machinesArrayFromFile = Get-Content -Path "C:\deploy\psscripts\machines.txt"

@($machinesArrayFromFile).ForEach({
Write-Verbose -Verbose "Node name $_"
Invoke-Command -ComputerName $_ -ScriptBlock {PowerShell.exe -Command "Test-NetConnection -ComputerName $_ -Port 5985"}
})