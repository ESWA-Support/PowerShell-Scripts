<#
.SYNOPSIS
    This script is used to set a server or servers up to be managed from the local management machines.  
.DESCRIPTION
    This script is used to set a server or servers up to be managed from the local management machines.  If this script 
    is not run against the target servers it cannot be properly managed from the management machine

.EXAMPLE
    This will run the script against all of the servers that are in the active directory domain
    .\Server 

    This will run this script against a specific server 
    .\Server -Target_Server "server name"

.NOTES
    To specify a vaule for the parameter you will need to run the following command Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#>

#This comm
param($Target_Server)

If ($Target_Server -eq $null)
    {
        Write-host "This command will now run against all servers in the:" $env:USERDNSDOMAIN
        
        Invoke-Command -ComputerName (Get-ADComputer -Filter {OperatingSystem -like "*windows*server*"}).name -ScriptBlock{
    
        Write-host "Currently working on server:" $ENV:COMPUTERNAME
    
        # Disable IPV-6
        $NET_ADA = (Get-NetAdapterBinding).InterfaceAlias
        Foreach ($i in $NET_ADA){Disable-NetAdapterBinding –InterfaceAlias $i –ComponentID ms_tcpip6}
    
        # This insures that the server will register itself in DNS
        $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
        $networkConfig.SetDnsDomain("adamspools.local")
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
        Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
        Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTPS Listener (TCP-In)'

        Set-NetFirewallRule -Profile Domain -DisplayGroup 'Remote File Server Resource Manager Management'
        Enable-NetFirewallRule -DisplayGroup 'Remote File Server Resource Manager Management'
    
        # Clear all of the event logs, this does not back the logs up it only clears them
        wevtutil el | Foreach-Object {wevtutil cl "$_"}
        }
    }
    Else
    {
        Write-host "This command will now run against the server:" $Target_Server
        
        Invoke-Command -ComputerName $Target_Server -ScriptBlock{
    
        Write-host "Currently working on server:" $ENV:COMPUTERNAME
    
        # Disable IPV-6
        $NET_ADA = (Get-NetAdapterBinding).InterfaceAlias
        Foreach ($i in $NET_ADA){Disable-NetAdapterBinding –InterfaceAlias $i –ComponentID ms_tcpip6}
    
        # This insures that the server will register itself in DNS
        $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
        $networkConfig.SetDnsDomain("adamspools.local")
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
        Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
        Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTPS Listener (TCP-In)'

        Set-NetFirewallRule -Profile Domain -DisplayGroup 'Remote File Server Resource Manager Management'
        Enable-NetFirewallRule -DisplayGroup 'Remote File Server Resource Manager Management'
    
        # Clear all of the event logs, this does not back the logs up it only clears them
        wevtutil el | Foreach-Object {wevtutil cl "$_"}
        }
    }