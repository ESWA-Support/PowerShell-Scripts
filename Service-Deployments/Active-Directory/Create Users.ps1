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