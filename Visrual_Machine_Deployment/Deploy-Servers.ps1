<#
    Author :- Jason Scanlon
    Version :- V1.0

.Synopsis
   Deploy and configure Servers from the host server using templates 
   You must set the host servers details in this script to ensure that host can deploy 
   the requested virtual machines. 

.DESCRIPTION
    

.NOTES
   The only section of this script that should be modified is the defaults secions of this script.
   
   Set this variable for the public facing Switch
   $VMSwitch

#>

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Set Script Defaults 
# Where are the main images Located on the server
$Base_Image = "C:\Base_Images\"
$AD_Server_GUI = "C:\Base_Image\Server_2022_DC_GUI.vhdx"
$AD_Server_Core = "C:\Base_Image\Server_2022_DC_Core.vhdx"
$FS_Server_GUI = "C:\Base_Image\Server_2022_FS_GUI.vhdx"
$FS_Server_Core = "C:\Base_Image\Server_2022_FS_Core.vhdx"
$APPS_Server_Core = "C:\Base_Image\Server_2022_apps_Core.vhdx"

# This is where the boot disk of the VMs will be stored 
#$OS_VHDX_Location = "D:\VD_Storage\"
#For testing Remove Before Deploying
$OS_VHDX_Location = "C:\Hyper-V"
$DATA_VHDX_Location = "C:\base_Path2"

# This is where the data disks of the VMs will be stored 
# $DATA_VHDX_Location = "E:\VD_Storage\"


# This is the main switch that will be used to connect the 
$VSwtich = "Public"
$SubMaskBit = "24"
# Functions Do not modify 
# Build the Menu for New Servers 
function Show-Menu
{
    param (
        [string]$Title = 'Select a Virtual Machine to Deploy'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Deploy New Domain Controler (GUI)."
    Write-Host "2: Deploy New Domain Controler (Core)."
    Write-Host "3: Deploy Additional Domain Controler (GUI)."
    Write-Host "4: Deploy Additional Domain Controler (Core)."
    Write-Host "5: Deploy New File Server (GUI)."
    Write-Host "6: Deploy New File Server (Core)."
    Write-Host "7: Deploy New Apps Server (GUI)."
    Write-Host "Q: To quit."
}

function Build-NewGUIDC
{
    param (
        [string]$Title = 'Deploying The First Domain Controller (GUI)'
    )
    Clear-Host
    #Deploy New AD Domain Controller (GUI)
$DCVMName = Read-Host -Prompt "Enter the Name of the New Domain Controller"
$DCIP = Read-Host -Prompt "Enter the static IP of this server"
$DFGW = Read-Host -Prompt "Enter the static Gateway IP of this server"
$DomainName = Read-Host -Prompt "Enter the fully quilified domain name(Example:TestDomain.local)"
$NETBIOName = Read-Host -Prompt "Enter the NETBIOS name(Example:TD)"
$DSRMPWD = Read-host -Prompt "Enter the DSRM Password"
$DSRMPWord = ConvertTo-SecureString $DSRMPWD -AsPlainText -Force
$DomainMode = "Default"
$ForestMode = "Default"

#VM Local Credentials
$DCLocalUser = "$DCVMName\Administrator"
$GETDCLocalPWord = Read-host -Prompt "Enter the Password for the local user account that you will use with this VM"
$DCLocalPWord = ConvertTo-SecureString -String $GETDCLocalPWord -AsPlainText -Force
$DCLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DCLocalUser, $DCLocalPWord

# New Domain Creds
$DomainUser = "$DomainName\administrator"
$GETDomainPWord = Read-host -Prompt "Enter the New Domain Admin Password"
$DomainPWord = ConvertTo-SecureString -String $GETDomainPWord -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

#Build The new virtual Machine
Write-Verbose "Copying Master VHDX and Deploying new VM with name [$DCVMName]" -Verbose 
New-Item -ItemType Directory -Path $OS_VHDX_Location\$DCVMNAME 
Copy-Item -Path $AD_Server_GUI -Destination $OS_VHDX_Location\$DCVMNAME\$DCVMNAME.vhdx
Write-Verbose "VHDX Copied, Building VM...." -Verbose
    New-VM -Name $DCVMName -MemoryStartupBytes 8GB -VHDPath "$OS_VHDX_Location\$DCVMName\$DCVMNAME.vhdx" -Generation 2 -SwitchName $VSwtich
    Set-VM -Name $DCVMName -ProcessorCount 4
    Set-VMMemory $DCVMName -DynamicMemoryEnabled $false
    Enable-VMIntegrationService -VMName $DCVMName -Name "Guest Service Interface"
    Set-VM -name $DCVMName -Notes "Primary Domain Controller `nIP Address: $DCIP"
Write-Verbose "VM Creation Completed. Starting VM [$DCVMName]" -Verbose
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential -ScriptBlock {
    param ($DCVMName, $DCIP, $SubMaskBit, $DFGW)
    New-NetIPAddress -IPAddress "$DCIP" -InterfaceAlias "Ethernet" -PrefixLength "$SubMaskBit" | Out-Null
    $DCEffectiveIP = Get-NetIPAddress -InterfaceAlias "Ethernet" | Select-Object IPAddress
    Write-Verbose "Assigned IPv4 and IPv6 IPs for VM [$DCVMName] are as follows" -Verbose 
    Write-Host $DCEffectiveIP | Format-List
    Write-Verbose "Updating Hostname for VM [$DCVMName]" -Verbose
    Rename-Computer -NewName "$DCVMName"
    } -ArgumentList $DCVMName, $DCIP, $SubMaskBit, $DFGW

Write-Verbose "Rebooting VM [$DCVMName] for hostname change to take effect" -Verbose
Stop-VM -Name $DCVMName
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

# Next we'll proceed by installing the Active Directory Role and then configuring the machine as a new DC in a new AD Forest
Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential -ScriptBlock {
    param ($DCVMName, $DomainMode, $ForestMode, $DomainName, $DSRMPWord) 
    Write-Verbose "Installing Active Directory Services on VM [$DCVMName]" -Verbose
    Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools 
    Write-Verbose "Configuring New Domain with Name [$DomainName] on VM [$DCVMName]" -Verbose
    Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -ForestMode $ForestMode -DomainMode $DomainMode -DomainName $DomainName -InstallDns:$true -LogPath “C:\Windows\NTDS” -SysvolPath “C:\Windows\SYSVOL” -SafeModeAdministratorPassword $DSRMPWord -DomainNetbiosName $NETBIOName -Force -NoRebootOnCompletion
    } -ArgumentList $DCVMName, $DomainMode, $ForestMode, $DomainName, $DSRMPWord

Write-Verbose "Rebooting VM [$DCVMName] to complete installation of new AD Forest" -Verbose
Stop-VM -Name $DCVMName
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 180}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

Write-Verbose "New Domain Provisioning Complete!!!!" -Verbose
}

function Build-NewCoreDC
{
    param (
        [string]$Title = 'Deploying The First Domain Controller (GUI)'
    )
    Clear-Host
    #Deploy New AD Domain Controller (GUI)
$DCVMName = Read-Host -Prompt "Enter the Name of the New Domain Controller"
$DCIP = Read-Host -Prompt "Enter the static IP of this server"
$DFGW = Read-Host -Prompt "Enter the static Gateway IP of this server"
$DomainName = Read-Host -Prompt "Enter the fully quilified domain name(Example:TestDomain.local)"
$NETBIOName = Read-Host -Prompt "Enter the NETBIOS name(Example:TD)"
$DSRMPWD = Read-host -Prompt "Enter the DSRM Password"
$DSRMPWord = ConvertTo-SecureString $DSRMPWD -AsPlainText -Force
$DomainMode = "Default"
$ForestMode = "Default"

#VM Local Credentials
$DCLocalUser = "$DCVMName\Administrator"
$GETDCLocalPWord = Read-host -Prompt "Enter the Password for the local user account that you will use with this VM"
$DCLocalPWord = ConvertTo-SecureString -String $GETDCLocalPWord -AsPlainText -Force
$DCLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DCLocalUser, $DCLocalPWord

# New Domain Creds
$DomainUser = "$DomainName\administrator"
$GETDomainPWord = Read-host -Prompt "Enter the New Domain Admin Password"
$DomainPWord = ConvertTo-SecureString -String $GETDomainPWord -AsPlainText -Force
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 

#Build The new virtual Machine
Write-Verbose "Copying Master VHDX and Deploying new VM with name [$DCVMName]" -Verbose 
New-Item -ItemType Directory -Path $OS_VHDX_Location\$DCVMNAME 
Copy-Item -Path $AD_Server_Core -Destination $OS_VHDX_Location\$DCVMNAME\$DCVMNAME.vhdx
Write-Verbose "VHDX Copied, Building VM...." -Verbose
    New-VM -Name $DCVMName -MemoryStartupBytes 8GB -VHDPath "$OS_VHDX_Location\$DCVMName\$DCVMNAME.vhdx" -Generation 2 -SwitchName $VSwtich
    Set-VM -Name $DCVMName -ProcessorCount 4
    Set-VMMemory $DCVMName -DynamicMemoryEnabled $false
    Enable-VMIntegrationService -VMName $DCVMName -Name "Guest Service Interface"
    Set-VM -name $DCVMName -Notes "Primary Domain Controller `nIP Address: $DCIP"
Write-Verbose "VM Creation Completed. Starting VM [$DCVMName]" -Verbose
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential -ScriptBlock {
    param ($DCVMName, $DCIP, $SubMaskBit, $DFGW)
    New-NetIPAddress -IPAddress "$DCIP" -InterfaceAlias "Ethernet" -PrefixLength "$SubMaskBit" | Out-Null
    $DCEffectiveIP = Get-NetIPAddress -InterfaceAlias "Ethernet" | Select-Object IPAddress
    Write-Verbose "Assigned IPv4 and IPv6 IPs for VM [$DCVMName] are as follows" -Verbose 
    Write-Host $DCEffectiveIP | Format-List
    Write-Verbose "Updating Hostname for VM [$DCVMName]" -Verbose
    Rename-Computer -NewName "$DCVMName"
    } -ArgumentList $DCVMName, $DCIP, $SubMaskBit, $DFGW

Write-Verbose "Rebooting VM [$DCVMName] for hostname change to take effect" -Verbose
Stop-VM -Name $DCVMName
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

# Next we'll proceed by installing the Active Directory Role and then configuring the machine as a new DC in a new AD Forest
Invoke-Command -VMName $DCVMName -Credential $DCLocalCredential -ScriptBlock {
    param ($DCVMName, $DomainMode, $ForestMode, $DomainName, $DSRMPWord) 
    Write-Verbose "Installing Active Directory Services on VM [$DCVMName]" -Verbose
    Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools 
    Write-Verbose "Configuring New Domain with Name [$DomainName] on VM [$DCVMName]" -Verbose
    Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -ForestMode $ForestMode -DomainMode $DomainMode -DomainName $DomainName -InstallDns:$true -LogPath “C:\Windows\NTDS” -SysvolPath “C:\Windows\SYSVOL” -SafeModeAdministratorPassword $DSRMPWord -DomainNetbiosName $NETBIOName -Force -NoRebootOnCompletion
    } -ArgumentList $DCVMName, $DomainMode, $ForestMode, $DomainName, $DSRMPWord

Write-Verbose "Rebooting VM [$DCVMName] to complete installation of new AD Forest" -Verbose
Stop-VM -Name $DCVMName
Start-VM -Name $DCVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$DCVMName]” -Verbose
    while ((Invoke-Command -VMName $DCVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 180}
Write-Verbose "PowerShell Direct responding on VM [$DCVMName]. Moving On...." -Verbose

Write-Verbose "New Domain Provisioning Complete!!!!" -Verbose
}

function Build-NewGUIFS
{
    param (
        [string]$Title = 'Deploying A File Server with GUI'
    )
    Clear-Host

#Deploy New File Server (GUI)
$FSVMName = Read-Host -Prompt "Enter the name of the new server"
$FSIP = Read-Host -Prompt "Enter the static IP of this server"
$DFGW = Read-Host -Prompt "Enter the static Gateway IP of this server"

#VM Local Credentials
$FSLocalUser = "$FSVMName\Administrator"
$GETFSLocalPWord = Read-host -Prompt "Enter the Password for the local Admin for the file server"
$FSLocalPWord = ConvertTo-SecureString -String $GETFSLocalPWord -AsPlainText -Force
$FSLocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $FSLocalUser, $FSLocalPWord

#Build The new virtual Machine
Write-Verbose "Copying Master File Server VHDX and Deploying new File Server with name [$FSVMName]" -Verbose 
New-Item -ItemType Directory -Path $OS_VHDX_Location\$FSVMNAME 
New-Item -ItemType Directory -Path $DATA_VHDX_Location\$FSVMNAME 
New-VHD -Path  $DATA_VHDX_Location\$FSVMNAME\$FSVMNAME"_Data".vhdx -Dynamic -SizeBytes 500GB 

Copy-Item -Path $FS_Server_GUI -Destination $OS_VHDX_Location\$FSVMNAME\$FSVMNAME.vhdx
Write-Verbose "VHDX Copied, Building VM...." -Verbose
    New-VM -Name $FSVMName -MemoryStartupBytes 16GB -VHDPath "$OS_VHDX_Location\$FSVMName\$FSVMNAME.vhdx" -Generation 2 -SwitchName $VSwtich
    Add-VMHardDiskDrive -VMName $FSVMName -Path $DATA_VHDX_Location\$FSVMNAME\$FSVMNAME"_Data".vhdx
    Set-VM -Name $FSVMName -ProcessorCount 4
    Set-VMMemory $FSVMName -DynamicMemoryEnabled $false
    Enable-VMIntegrationService -VMName $FSVMName -Name "Guest Service Interface"
    Set-VM -name $FSVMName -Notes "Files Server: $FSVMName `nIP Address: $FSIP"
Write-Verbose "VM Creation Completed. Starting VM [$FSVMName]" -Verbose
Start-VM -Name $FSVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$FSVMName]” -Verbose
    while ((Invoke-Command -VMName $FSVMName -Credential $FSLocalCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$FSVMName]. Moving On...." -Verbose

Invoke-Command -VMName $FSVMName -Credential $FSLocalCredential -ScriptBlock {
    param ($FSVMName, $FSIP, $SubMaskBit, $DFGW)
    New-NetIPAddress -IPAddress "$FSIP" -DefaultGateway "$DFGW" -InterfaceAlias "Ethernet" -PrefixLength "$SubMaskBit" | Out-Null
    $FSEffectiveIP = Get-NetIPAddress -InterfaceAlias "Ethernet" | Select-Object IPAddress
    Write-Verbose "Assigned IPv4 and IPv6 IPs for VM [$FSVMName] are as follows" -Verbose 
    Write-Host $FSEffectiveIP | Format-List
    Write-Verbose "Updating Hostname for VM [$FSVMName]" -Verbose
    Rename-Computer -NewName "$FSVMName"
    } -ArgumentList $FSVMName, $FSIP, $SubMaskBit, $DFGW

Write-Verbose "Rebooting VM [$FSVMName] for hostname change to take effect" -Verbose
Stop-VM -Name $FSVMName
Start-VM -Name $FSVMName

Write-Verbose “Waiting for PowerShell Direct to start on VM [$FSVMName]” -Verbose
    while ((Invoke-Command -VMName $FSVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 1}
Write-Verbose "PowerShell Direct responding on VM [$FSVMName]. Moving On...." -Verbose

$FDDJ = Read-Host -Prompt "Do you want to Join this server to a Domain (Y/N) (Only Use Y or N)"

If ($FDDJ -eq "Y"){
    $DomainName = Read-Host -Prompt "Enter the fully quilified domain name(Example:TestDomain.local)"
    $DomainUser = "$DomainName\administrator"
    $GETDomainPWord = Read-host -Prompt "Enter the New Domain Admin Password"
    $DomainPWord = ConvertTo-SecureString -String $GETDomainPWord -AsPlainText -Force
    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord 
    Invoke-Command -VMName $FSVMName -Credential $FSLocalCredential -ScriptBlock {
        param ($DomainName, $DomainUser, $DomainCredential)
        Add-Copmuter -DomainName $DomainName -DomainCredential $DomainCredential -Restart
    }
    }Else{}
Write-Verbose “Waiting for PowerShell Direct to start on VM [$FSVMName]” -Verbose
while ((Invoke-Command -VMName $FSVMName -Credential $DomainCredential {“Test”} -ea SilentlyContinue) -ne “Test”) {start-Sleep -Seconds 180}
Write-Verbose "PowerShell Direct responding on VM [$FSVMName]. Moving On...." -Verbose

Write-Verbose "New File Server Provisioning Complete!!!!" -Verbose
}

function Build-NewCoreFS
{

}

function Build-NewAPPSSrv
{

}

# ----------------------------------------------------
# The script start to work here
# ----------------------------------------------------

Show-Menu –Title $Title
$selection = Read-Host "Please make a selection" -ForegroundColor Green
    switch ($selection)
    {
        '1' {'Deploying New Domain Controller (GUI).'
            Build-NewGUIDC
            }
        '2' {'Deploying New Domain Controller (Core).'
            Build-NewCoreDC}
        '3' {'Deploying Additional Domain Controller (GUI).(Coming Soon)'}
        '4' {'Deploying Additional Domain Controller (Core).(Coming Soon)'}
        '5' {'Deploying New File Server (GUI).'
            Build-NewGUIFS}
        '6' {'Deploying New File Server (Core).'
            Build-NewCoreFS}
        '7' {'Deploying New Apps Server (GUI)'
            Build-NewAPPSSrv}
        'q' {return}
    }
