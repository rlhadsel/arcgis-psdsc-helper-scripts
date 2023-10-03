$sb = {
    $m = "$env:COMPUTERNAME`n"
    $GEP = Get-ExecutionPolicy
    $m += "----" + $GEP + "`n"
    $a = Get-Module -ListAvailable -FullyQualifiedName "ArcGIS" | Select-Object Name, Version
    $m +="----" + $a.Name + " Version " + $a.Version +"`n"
    $GLCM = Get-DscLocalConfigurationManager | Select-Object -ExpandProperty ConfigurationMode
    $m += "----" + $GLCM + "`n"
    Write-Host $m
}

Invoke-Command -ComputerName c0jsmv2.esri.com -ScriptBlock $sb