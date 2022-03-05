<#
    This script will get the build version of Windows installed 
#>
Switch ($PSVersionTable.PSVersion.ToString())
{
  "7.1.0" {Import-Module -Name Appx -UseWindowsPowerShell; Break}
  "7.1.1" {Import-Module -Name Appx -UseWindowsPowerShell; Break}
}
 
$buildInfo = [PSCustomObject]@{
  Version     = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion
  InstalledOn = [DateTime]::FromFileTime((Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallTime))
  OSBuild     = "{0}.{1}" -f (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild), (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name UBR)
  Edition     = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName
  ReleaseId   = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId
  Experience  = (Get-AppxPackage 'MicrosoftWindows.Client.CBS').Version
}
Write-Host $buildInfo