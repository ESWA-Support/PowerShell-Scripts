Function Global:Clear-Winevent ( $Logname ) {
<#
.SYNOPSIS 
Given a specific Logname from the GET-WINEVENT Commandlet
it will clear the Contents of that log

.DESCRIPTION 
Cmdlet used to clear the Windows Event logs from Windows 7
Windows Vista, Server 2008 and Server 2008 R2

.EXAMPLE 
CLEAR-WINEVENT -Logname Setup

.EXAMPLE 
GET-WINEVENT -Listlog * | CLEAR-WINEVENT -Logname $_.Logname

Clear all Windows Event Logs

.NOTES 
This is a Cmdlet that is not presently in Powershell 2.0
although there IS a GET-WINEVENT Command to list the
Contents of the logs.  You can utilize this instead of
WEVTUTIL.EXE to clear out Logs.  Special thanks to Shay Levy
(@shaylevy on Twitter) for pointing out the needed code

#>

[System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog("$Logname")

}
<#
function clear-all-event-logs ($computerName="localhost")
{$logs = get-eventlog -computername $computername -list | foreach {$_.Log}
$logs | foreach {clear-eventlog -comp $computername -log $_ }
get-eventlog -computername $computername -list}
#>