<#
.SYNOPSIS
    This script is used to creat the base enviroment for any virtual servers that you will deploy
.DESCRIPTION
    This script is setup so taht 
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

# Get the Hypervisors details 
$LocalHostname = Get-Computerinfo
<#
WindowsEditionId, WindowsProductName, WindowsRegisteredOrganization, WindowsSystemRoot, WindowsVersion, CsDomain, CsDomainRole,
CsEnableDaylightSavingsTime, CsName, CsPCSystemType, CsPCSystemTypeEx, CsWorkgroup, OsName, OsOperatingSystemSKU, OsSystemDrive,
OsWindowsDirectory, HyperVisorPresent,
#>

#This is for getting the network adapter details 
<# MacAddress, Status, LinkSpeed, AdminStatus, MediaConnectionState, ifAlias, InterfaceAlias, ifIndex, Name, Virtual, VlanID #>
$NetAdapters = Get-NetAdapter -Physical
$TotalNetworkAdapters = (Get-NetAdapter -Physical | Group-Object -Property Name).Count


<# Ask the user if they need a Net Team #>
If ($TotalNetworkAdapters -gt 1) {
    Write-host  "You have"$TotalNetworkAdapters "would you like to create a network team"
    $NetTeam = Read-Host -Prompt "Would you like to create a network team"
}
else {
    Write-host  "You only have "$TotalNetworkAdapters "you cannot create a network team"
}

$VLANID_Net = Read-host "What do you want to call your team"


# Get the Prefix of the servers to ad
$Prefix = Read-Host -Prompt "what prefix for the servesrs do you wish to use?"

$VirtualDCTotal = Read-Host -Prompt "How many Domain controlers do you need?"
$VirtualFSTotal = Read-Host -Prompt "How many File Servers do you need?"
$VirtualGenTotal = Read-Host -Prompt "How many General use servers do you need?"
$VirtualAPPSTotal = Read-Host -Prompt "How many Application Servrs do you need?"

$DCSuffix = "-DC-"
$FSSuffix = "-FS-"
$GenSuffix = "-Gen-"
$APPSuffix = "-Apps-"

function VlanSetup {
    param ($VLANCount)
    $VLANID = @("99")
    $VLANName = @("Management")
    # Naming for the Adapters 

    for ($VNET = 1; $VNET -ile $VLanCount; $VNET++) {
        $VLANID += Read-Host -Prompt "Please enter the VLAN ID"
        $VLANName += Read-Host -Prompt "Please enter the VLAN Name"
    }
}


Foreach ( $VMGUI in $Core) {
    New-VM -Name $VMGUI -MemoryStartupBytes 16GB -BootDevice VHD -VHDPath D:\VD_Storage\$VMGUI.vhdx -Path $MM_Store'\Virtual Machines' -Generation 2 -SwitchName Hyper-V1
    Set-VM - Name $VMGUI -ProcessorCount 12
    Rename-VMNetworkAdapter -VMName $VMGUI -Name "Network Adapter" -New "Corp_Net"
    Enable-VMIntegrationService -VMName $VMGUI -Name "Guest Service Interface"    
}

Foreach ( $VMCore in $Core) {
    New-VM -Name $VMCore -MemoryStartupBytes 8GB -BootDevice VHD -VHDPath D:\VD_Storage\$VMCore.vhdx -Path $MM_Store'\Virtual Machines' -Generation 2 -SwitchName Hyper-V1
    Set-VM - Name $VMCore -ProcessorCount 4
    Rename-VMNetworkAdapter -VMName $VMCore -Name "Network Adapter" -New "Corp_Net"
    Enable-VMIntegrationService -VMName $VMCore -Name "Guest Service Interface"    
}