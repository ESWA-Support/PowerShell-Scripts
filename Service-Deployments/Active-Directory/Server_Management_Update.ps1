﻿<#
.SYNOPSIS
    This script is used to set a server or servers up to be managed from the local management machines.  
.DESCRIPTION
    This script is used to set a server or servers up to be managed from the local management machines.  If this script 
    is not run against the target servers it cannot be properly managed from the management machine
.EXAMPLE
    .\Server
.INPUTS
    
.OUTPUTS
    
.NOTES
    To specify a vaule for the parameter you will need to run the following command Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#>

$Domain_Name = ""

param($Target_Server)

If ($null -eq $Target_Server)
    {
        Write-host "This command will now run against all servers in the:" $env:USERDNSDOMAIN
        
        Invoke-Command -ComputerName (Get-ADComputer -Filter *).name -ScriptBlock{
    
        Write-host "Currently working on server:" $ENV:COMPUTERNAME
    
        #Disable IPV-6
        $NET_ADA = (Get-NetAdapterBinding).InterfaceAlias
        Foreach ($i in $NET_ADA){Disable-NetAdapterBinding –InterfaceAlias $i –ComponentID ms_tcpip6}
    
        #This insures that the server will register itself in DNS
        $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
        $networkConfig.SetDnsDomain("$Domain_Name")
        $networkConfig.SetDynamicDNSRegistration($true,$true)
        ipconfig /registerdns

        gpupdate /force
    
        #Clear all of the event logs, this does not back the logs up it only clears them
        wevtutil el | Foreach-Object {wevtutil cl "$_"}
        }
    }
    Else
    {
        Write-host "This command will now run against the server:" $Target_Server
        
        Invoke-Command -ComputerName $Target_Server -ScriptBlock{
    
        Write-host "Currently working on server:" $ENV:COMPUTERNAME
    
        #Disable IPV-6
        $NET_ADA = (Get-NetAdapterBinding).InterfaceAlias
        Foreach ($i in $NET_ADA){Disable-NetAdapterBinding –InterfaceAlias $i –ComponentID ms_tcpip6}
    
        #This insures that the server will register itself in DNS
        $networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
        $networkConfig.SetDnsDomain("$Domain_Name")
        $networkConfig.SetDynamicDNSRegistration($true,$true)
        ipconfig /registerdns

        gpupdate /force 
            
        #Clear all of the event logs, this does not back the logs up it only clears them
        wevtutil el | Foreach-Object {wevtutil cl "$_"}
        }
    }