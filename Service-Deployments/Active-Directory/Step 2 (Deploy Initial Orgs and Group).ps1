<#
Prepare this sever to be remotely managed 
#>
# Get all the needed Values


$DNSName = (Get-ADDomain).Forest

Write-host "Currently working on server:" $ENV:COMPUTERNAME

$DSName = (Get-ADDomain).DistinguishedName
    
# Disable IPV-6
$NET_ADA = (Get-NetAdapterBinding).InterfaceAlias

Foreach ($i in $NET_ADA){Disable-NetAdapterBinding –InterfaceAlias $i –ComponentID ms_tcpip6}
    
# This insures that the server will register itself in DNS
    $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
    $networkConfig.SetDnsDomain("$DNSName")
    $networkConfig.SetDynamicDNSRegistration($true,$true)
    ipconfig /registerdns

    # Update firewall to allow for remote control 
    Enable-NetFirewallRule -DisplayName 'COM+ Network Access (DCOM-In)'
    Enable-NetFirewallRule -DisplayName 'Remote Event Log Management (RPC)'      
    Enable-NetFirewallRule -DisplayName 'Remote Event Log Management (NP-In)'    
    Enable-NetFirewallRule -DisplayName 'Remote Event Log Management (RPC-EPMAP)'
    Enable-NetFirewallRule -DisplayName 'Remote Volume Management - Virtual Disk Service (RPC)'      
    Enable-NetFirewallRule -DisplayName 'Remote Volume Management - Virtual Disk Service Loader (RPC)'
    Enable-NetFirewallRule -DisplayName 'Remote Volume Management (RPC-EPMAP)'
    Enable-NetFirewallRule -DisplayName 'Performance Logs and Alerts (DCOM-in)'
    Enable-NetFirewallRule -DisplayName 'Performance Logs and Alerts (TCP-in)'
    

    Set-NetFirewallRule -Profile Domain -DisplayGroup 'Remote File Server Resource Manager Management'
    Enable-NetFirewallRule -DisplayGroup 'Remote File Server Resource Manager Management'

#Lets build the OU's
$DSName = (Get-ADDomain).DistinguishedName
$MainOU = Read-Host -Prompt "Enther The Name of The Main Organizational Unit"
Write-host "We are builing this $MainOU and $DSName"
# Create Root Organizational Unit 
New-ADOrganizationalUnit -Name $MainOU -Path $DSName 

$OUPath =  "OU=" + $MainOU + "," + $DSName

# Create Sub Organizational Units under the Root Organizational Unit
New-ADOrganizationalUnit -Name "Groups" -Path $OUPath
New-ADOrganizationalUnit -Name "Management Accounts" -Path $OUPath
New-ADOrganizationalUnit -Name "Management Workstations" -Path $OUPath
New-ADOrganizationalUnit -Name "RDS Servers" -Path $OUPath
New-ADOrganizationalUnit -Name "Resources" -Path $OUPath
New-ADOrganizationalUnit -Name "Servers" -Path $OUPath
New-ADOrganizationalUnit -Name "Workstations" -Path $OUPath
New-ADOrganizationalUnit -Name "Users" -Path $OUPath

# Default group used for VPN access
$Group_Path = "OU=Groups" + "," + $OUPath
New-ADGroup -Name "SSL VPN Access" -SamAccountName SSL_VPN_Access -GroupCategory Security -GroupScope Global -DisplayName "SSL VPN Access" -Path $Group_Path

$MGMT_Path = "OU=Management Accounts" + "," + $OUPath
Get-ADUser -Identity tlit | Move-ADObject -TargetPath $MGMT_Path
Get-ADUser -Identity Administrator | Move-ADObject -TargetPath $MGMT_Path

# Clear all of the event logs, this does not back the logs up it only clears them
wevtutil el | Foreach-Object {wevtutil cl "$_"}