<#

  Author :- jason Scanlon
  Version :- V1.0

.Synopsis
   Create Users in the Active Directory Domain

.DESCRIPTION
    This script will is used to create all of the users in the Active Directory Domain

.NOTES
   You need to edit the file "AD_User_Import.csv" to included all of the users that need to be added 
#>
$Import_users = Import-Csv -Path .\AD_User_Import.csv


$import_users | ForEach-Object {
    New-ADUser `
        -Name $($_.FirstName + " " + $_.LastName) `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
        -DisplayName $($_.FirstName + " " + $_.LastName) `
        -UserPrincipalName $_.UserPrincipalName `
        -SamAccountName $_.SamAccountName `
        -AccountPassword $(ConvertTo-SecureString $_.Password -AsPlainText -Force) `
        -EmailAddress $_.Email `
        -Path $_.Path `
        -HomeDrive $_.HomeDrive `
        -HomeDirectory $_.HomeDirectory `
        -Enabled $True
}