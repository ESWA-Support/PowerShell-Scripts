<#

  Author :- jason Scanlon
  Version :- V1.0

.Synopsis
   Deploy Active Direcoty

.DESCRIPTION
    This script check to see if the service for Active Directory and then deploys 
    the first domain controller.
    
    Once the initial domain controller has been deployed the system will reboot.

    This script will run on both server core and server with Desktop Experience 

.NOTES
   This script will Promopt you for all that it needs to setup the new domain.  
#>

#Variables Start Here

# Check to see if the installation media is installed and usable for installation
$Dr = Get-PSDrive | Where-Object {$_.Used  -gt "0"} |Select-Object -ExpandProperty Root

# This sets the fully quilifed name of the domain
$ADName = Read-host -Prompt "Enter the Fully Quilifided Domain Name:"

# This sets the NetBios Name of your domain
$NBName = Read-host -Prompt "Enter the NetBIOS Name:"

# This sets the forest mode level
$Fmode = "Default"

# This sets the domain mode level
$DMode = "Default"

# Enter the domain name and username here to use when created the domain
$Creds = (Get-Credential)

#Enter the Directory Service Recovery Password
$DSRMPWD = Read-host -Prompt "Enter the DSRM Password"

$DSRM = ConvertTo-SecureString $DSRMPWD -AsPlainText -Force

###################################################################################
#  You should not need to edit the command below to setup the new domain          #
###################################################################################

# Checks to see if the installatin files are instaled on the server before begining the install

$IFiles = Get-WindowsFeature -Name AD-Domain-Services | Select-Object -ExpandProperty InstallState


if ( $IFiles -eq "Available" ) 
    {
        Write-Output "Files Are there"
    }
    else 
    {
        Write-Output "Files are not there"
    }

# install the Windows Feature
install-windowsfeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

# Import the required powershell modules
Import-Module ADDSDeployment

# Configure the forest
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -DomainMode $DMode -DomainName $ADName -DomainNetbiosName $NBName -SafeModeAdministratorPassword $DSRM -ForestMode $Fmode -InstallDns:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -SysvolPath “C:\Windows\SYSVOL” -Force:$true