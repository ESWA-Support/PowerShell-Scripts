#Build Orgs
New-ADOrganizationalUnit -Name "Main Organization" -Path "DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Groups" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Management Accounts" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Management Workstations" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "RDS Servers" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Resources" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Main Organization,DC=youlocal,DC-AD"
New-ADOrganizationalUnit -Name "Users" -Path "OU=Main Organization,DC=youlocal,DC-AD"

#Add Grousp

New-ADGroup -Name "SSL VPN Access" -SamAccountName SSL_VPN_Access -GroupCategory Security -GroupScope Global -DisplayName "SSL VPN Access" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 

New-ADGroup -Name "Accounting" -SamAccountName Accounting -GroupCategory Security -GroupScope Global -DisplayName "Accounting" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Accounts Payable" -SamAccountName Accounts_Payable -GroupCategory Security -GroupScope Global -DisplayName "Accounts Payable" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Accounts Receivable" -SamAccountName Accounts_Receivable -GroupCategory Security -GroupScope Global -DisplayName "Accounts Receivable" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "HR-Payroll" -SamAccountName HR-Payroll -GroupCategory Security -GroupScope Global -DisplayName "HR-Payroll" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Management" -SamAccountName Management -GroupCategory Security -GroupScope Global -DisplayName "Management" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Sales" -SamAccountName Sales -GroupCategory Security -GroupScope Global -DisplayName "Sales" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Sales Team" -SamAccountName Sales_Team -GroupCategory Security -GroupScope Global -DisplayName "Sales Team" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
New-ADGroup -Name "Sales Admin" -SamAccountName Sales_Admin -GroupCategory Security -GroupScope Global -DisplayName "Sales Admin" -Path "OU=Groups,OU=Main Organization,DC=youlocal,DC-AD" 
