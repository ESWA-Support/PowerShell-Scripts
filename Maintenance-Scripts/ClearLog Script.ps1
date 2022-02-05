<#
This script will make a copy of the event logs and then clear them.  
If must be run from an elevated powershell windows 
#>

# Get the path where you want to store the backup files


$Log_Backup_Path = Read-Host "Please enter the full path of where you want to store the log files before cleareing them" 

Test-Path -Path $Log_Backup_Path 

If ((Test-Path -Path $Log_Backup_Path) -eq $True){
    Write-host "The file path exists and will not be created"
}else{
    New-Item -Path $Log_Backup_Path -ItemType Directory 
}

Copy-Item -Path C:\Windows\System32\winevt\Logs\*.* -Destination $Log_Backup_Path

wevtutil el | ForEach-Object {wevtutil cl "$_"}