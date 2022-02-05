<#
Add the users sam accounts to the groupsas listed below.
Each user name should be in ""
#>

$Accounts_Payable = ("")
$Accounts_Receivable = ("")
$HRPayroll = ("")
$Management = ("")
$Supervisors = ("")
$Purchasing = ("")
$Sales_Team = ("")
$Sales_Admin = ("")


<#
Make sure that there is one line for each of the above variables 
#>
Add-ADGroupMember -Identity Accounts_Payable -Members $Accounts_Payable
Add-ADGroupMember -Identity Accounts_Receivable -Members $Accounts_Receivable
Add-ADGroupMember -Identity HR-Payroll -Members $HRPayroll
Add-ADGroupMember -Identity Management -Members $Management
Add-ADGroupMember -Identity Supervisors -Members $Supervisors
Add-ADGroupMember -Identity Purchasing -Members $Purchasing
Add-ADGroupMember -Identity Sales_Team -Members $Sales_Team
Add-ADGroupMember -Identity Sales_Admin -Members $Sales_Admin