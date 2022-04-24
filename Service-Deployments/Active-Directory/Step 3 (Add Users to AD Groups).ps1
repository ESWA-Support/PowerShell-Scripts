<#

  Author :- jason Scanlon
  Version :- V1.0

.Synopsis
   This script adds the new users to the needed groups in the domain 

.DESCRIPTION
   Edit the variables to include the users in the proper groups.  Refer to the script used to create the organizations and groups to added the users to the proper groups 

.NOTES

#>

# Add users and groups here copy as needed 
$Accounts_Payable = ("Benita","Haley")
$Accounts_Receivable = ("Lorene","Loryn")
$HRPayroll = ("Amanda")
$Management = ("Debbie","Kris","Robin")
$Supervisors = ("Arturo","Gary","Jeromy","Josem","Jose.m","Manny","Markm","Peter","Robert","Stan ")
$Purchasing = ("Alfredo","Jose")
$Permits = ("Bradley","Ike","Luis","Nancy","Shannon","Vickie")
$Coordinators = ("Glenn","Kyle","Martha","Noemi","Noreen","Rosi")
$Golden_State = ("John")
$VegasAccounting = ("Brenda")
$Sales_Team = ("Amandah","Chris","Corby","Craig","Garyg","Jim","Johnr","Kim","Mark","Michael","Mike","Nick","Porfi","Ray","Steve","Todd")
$Sales_Admin = ("Rebecca")

# Copy and paste as needed to add the users to the requested groups 
Add-ADGroupMember -Identity Accounts_Payable -Members $Accounts_Payable
Add-ADGroupMember -Identity Accounts_Receivable -Members $Accounts_Receivable
Add-ADGroupMember -Identity HR-Payroll -Members $HRPayroll
Add-ADGroupMember -Identity Management -Members $Management
Add-ADGroupMember -Identity Supervisors -Members $Supervisors
Add-ADGroupMember -Identity Purchasing -Members $Purchasing
Add-ADGroupMember -Identity Permits -Members $Permits
Add-ADGroupMember -Identity Coordinators -Members $Coordinators
Add-ADGroupMember -Identity Golden_State -Members $Golden_State
Add-ADGroupMember -Identity VegasAccounting -Members $VegasAccounting
Add-ADGroupMember -Identity Sales_Team -Members $Sales_Team
Add-ADGroupMember -Identity Sales_Admin -Members $Sales_Admin