<#
.SYNOPSIS
  This script created an HTML report of the system it is run on.  It can be used when system details are needed and you want 
  an eazy way to document the system 

.DESCRIPTION
  <Brief description of script>

  .PARAMETER <Parameter_Name>
    There are none at this time
.INPUTS
  There are none at this time
.OUTPUTS
  This will generate a report in the directory "C:\Temp\"  If you want the report to be created 
  in a different location update the variable $ReportSavePath
.NOTES
  Version:        1.0
  Author:         Jason Scanlon
  Creation Date:  03-01-2022
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\Get-System-Report.ps1
#>

[String]$ReportTitle = "System Report for: $env:COMPUTERNAME"
[String]$ReportSavePath = "C:\Temp\"
[String]$CompanyLogo = ""
[String]$RightLogo = "https://www.teamlogicit.com/TeamlogicIT/media/TLIT-Images/Global/c2c89e1.png"
[string]$Day = (Get-Date).Day
[string]$Month = (Get-Date).Month
[string]$Year = (Get-Date).Year

$ReportName = ("System-Report-for-$env:COMPUTERNAME - $Day - $Month - $Year")

# ____________________________________________________
# The script start to work here
# ____________________________________________________

Write-Host "Gathering Report Data..." -ForegroundColor White
Write-Host "__________________________________" -ForegroundColor White
(Write-Host -NoNewline "Report Save Path: " -ForegroundColor Yellow), (Write-Host  $ReportSavePath -ForegroundColor White)
(Write-Host -NoNewline "Working on system : " -ForegroundColor Yellow), (Write-Host $env:COMPUTERNAME -ForegroundColor White)

#Check for ReportHTML Module
$Mod = Get-Module -ListAvailable -Name "ReportHTML"
$Mod2 = Get-Module -ListAvailable -Name "PSWindowsUpdate"

#Check is the output direcotry exist 
If ($null -eq $Mod)
{
	
	Write-Host "ReportHTML Module is not present, attempting to install it"
	
	Install-Module -Name ReportHTML -Force -AllowClobber
	Import-Module ReportHTML -ErrorAction SilentlyContinue
	(Get-Content -Path "C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2\default.css") -replace '337e94', '17893b' |Set-Content -Path "C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2\default.css"
}

If ($null -eq $Mod2)
{
	Write-Host " PSWindowsUpdate Module is not present, attempting to install it"
	Install-Module PSWindowsUpdate -Force -AllowClobber
	Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
}

# Gets the Hardware Details
$HardwareTable1 = New-Object 'System.Collections.Generic.List[System.Object]'
$HW_MAN = (Get-ComputerInfo).CsManufacturer
$HW_FF = (Get-ComputerInfo).CsChassisSKUNumber
$HW_MOD = (Get-ComputerInfo).CsModel
$HW_REG_Org = (Get-ComputerInfo).WindowsRegisteredOrganization
$HW_Reg_Owner = (Get-ComputerInfo).WindowsRegisteredOwner

$objhw1 = [PSCustomObject]@{
	'Manufacturer'	    = $HW_MAN
	'Form Factor'	    = $HW_FF
	'Model'             = $HW_MOD
	'Registerd Org'	    = $HW_REG_Org
    'Registerd Owner'	= $HW_Reg_Owner
}

$HardwareTable1.Add($objhw1)

if (($HardwareTable1).Count -eq 0)
{
	$objhw1 = [PSCustomObject]@{
		
		Information = 'Information: Could not get items for table'
	}
	$HardwareTable1.Add($objhw1)
}

$HardwareTable2 = New-Object 'System.Collections.Generic.List[System.Object]'
$HW_CPU_Gen = (Get-WmiObject -Class Win32_Processor).Name
$HW_PCPU = (Get-ComputerInfo).CsNumberOfProcessors
$HW_LCPU = (Get-ComputerInfo).CsNumberOfLogicalProcessors
$HW_MEM = (Get-ComputerInfo).CsTotalPhysicalMemory
$HW_Vert = (Get-ComputerInfo).HyperVisorPresent

$objhw2 = [PSCustomObject]@{
	'CPU Generation'	= $HW_CPU_Gen
	'Physical CPUS'	    = $HW_PCPU
	'Local CPUS'        = $HW_LCPU
    'Physical Memory'   = $HW_MEM
	'Virtualization'	= $HW_Vert
}

$HardwareTable2.Add($objhw2)

if (($HardwareTable2).Count -eq 0)
{
	$objhw2 = [PSCustomObject]@{
		
		Information = 'Information: Could not get items for table'
	}
	$HardwareTable2.Add($objhw2)
}

# Gets the BIOS Data
$BIOTable = New-Object 'System.Collections.Generic.List[System.Object]'
$BIOS_Vendor = (Get-WmiObject -Class Win32_BIOS).Manufacturer
$BIOS_Version = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion
$BIOS_Serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber

$obj1 = [PSCustomObject]@{
	'BIOS Vendor'		= $BIOS_Vendor
	'BIOS Version'	    = $BIOS_Version
	'Serial Number'		= $BIOS_Serial
}

$BIOTable.Add($obj1)

if (($BIOTable).Count -eq 0)
{
	$Obj1 = [PSCustomObject]@{
		
		Information = 'Information: Could not get items for table'
	}
	$BIOTable.Add($obj1)
}

# Gets the OS Details 
$OSTable = New-Object 'System.Collections.Generic.List[System.Object]'
$Operating_System = (Get-WMIObject Win32_OperatingSystem).Caption
$Operating_System_Build = (Get-WmiObject Win32_OperatingSystem).BuildNumber
$Operating_System_OSA = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$Operating_System_Serial = (Get-WmiObject Win32_OperatingSystem).SerialNumber
$Operating_System_Status = (Get-WmiObject Win32_OperatingSystem).Status

$obj = [PSCustomObject]@{
	'OS Name'		    = $Operating_System
	'Build Number'	    = $Operating_System_Build
	'OS Architecture'   = $Operating_System_OSA
	'Serial Number'		= $Operating_System_Serial
	'Status'		    = $Operating_System_Status
}

$OSTable.Add($obj)

if (($OSTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{Information = 'Information: Could not get items for table'}
	$OSTable.Add($obj)
}

# Get Missing Windows Update 
$WUTable = New-Object 'System.Collections.Generic.List[System.Object]'
$UPDates = (Get-WindowsUpdate)

foreach ($UPDate in $UPDates)
{
	$Status = $UPDate.Status
    $KB = $UPDate.KB
	$Size = $UPDate.Size
    $Title = $UPDate.Title
    	
	$obj = [PSCustomObject]@{
		
		'Status'    = $Status
		'KN Number'  = $KB
		'Download Size'   = $Size
        'Title'    = $Title
	}
	
	$WUTable.Add($obj)
}

if (($WUTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{Information = 'Information: There are no Windows Updates to install'}
	$WUTable.Add($obj)
}

# Gets Storage data of local and attached drives 
$StorageTable = New-Object 'System.Collections.Generic.List[System.Object]'
$Drives = (Get-Volume | Where-Object {$null -ne $_.DriveLetter})

foreach ($Drive in $Drives)
{
	
	$Name = $Drive.FriendlyName
    $Letter = $Drive.DriveLetter
	$SystemType = $Drive.FileSystemType
    $DriveType = $Drive.DriveType
    $Total = $Drive.size
	$Free = $Drive.SizeRemaining
    $Status = $Drive.HealthStatus
	
	$obj = [PSCustomObject]@{
		
		'Drive Name'    = $Name
		'Drive Letter'  = $Letter
		'System Type'   = $SystemType
        'Drive Type'    = $DriveType
		'Drive Size'    = $Total
		'Free Space'    = $Free
        'Drive Status'  = $Status
	}
	
	$StorageTable.Add($obj)
}

if (($StorageTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{Information = 'Information: Stroage devices'}
	$StorageTable.Add($obj)
}

# Pull Printer Data 
$PRTable = New-Object 'System.Collections.Generic.List[System.Object]'
$PRTS = (Get-Printer)

foreach ($PRT in $PRTS)
{
	$Name = $PRT.Name
	$PortName = $PRT.PortName
	$Location = $PRT.Location
	$Type = $PRT.Type
	$DeviceType = $PRT.DeviceType
	$PrinterStatus = $PRT.PrinterStatus
	$Status = $PRT.Status
	$StatusDescriptions = $PRT.StatusDescriptions
	$Comment = $PRT.Comment
	$Shared = $PRT.Shared
	$ShareName = $PRT.ShareName
	
	$obj = [PSCustomObject]@{
		
		'Name' = $Name
		'Port' = $PortName
		'Location' = $Location
		'Type' = $Type
		'Device Type' = $DeviceType
		'Printer Status' = $PrinterStatus
		'Status' = $Status
		'Status Descriptions' = $StatusDescriptions
		'Comment' = $Comment
		'Shared' = $Shared
		'Share Name' = $ShareName
	}
	$PRTable.Add($obj)
}

if (($PRTable).Count -eq 0){
	$Obj = [PSCustomObject]@{Information = 'Information: There are no printers installed'}
	$PRTable.Add($obj)
}

# Gets the Hardware that is installed in the systesm 
$DeviceTable = New-Object 'System.Collections.Generic.List[System.Object]'
$Device_List = (Get-WmiObject Win32_PnPSignedDriver)

foreach ($Device in $Device_List)
{
	
	$Name = $Device.Caption
    $Description = $Device.Description
	$Provider = $Device.DriverProviderName
    $DeviceType = $Device.DeviceType
    $DriverVersion = $Device.DriverVersion
    $FriendlyName = $Device.FriendlyName
    $IsSigned = $Device.IsSigned
    $Location = $Device.Location
    $Manufacturer = $Device.Manufacturer
    $Status = $Device.Status
	
	
	$obj = [PSCustomObject]@{
		
        'Manufacturer'    = $Manufacturer		
		'Friendly Name'   = $FriendlyName
        'Device Name'     = $Name
		'Description'     = $Description
		'Provider'        = $Provider
        'Device Type'     = $DeviceType
		'Driver Version'  = $DriverVersion
        'Is Signed'       = $IsSigned
        'Location'        = $Location
        'Status'          = $Status
		
        
	}
	
	$DeviceTable.Add($obj)
}

if (($DeviceTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		Information = 'Information: There is no information to be found'
	}
	$DeviceTable.Add($obj)
}

# AV Software 
$AVSoftwareTable = New-Object 'System.Collections.Generic.List[System.Object]'
$AVSoftware = (Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct)

foreach ($AV in $AVSoftware)
{
	$DisplayName = $AV.DisplayName
	$Product_State = $AV.productState
	
	$obj = [PSCustomObject]@{
		
		'Name'    = $DisplayName
		'Product State Code'  = $Product_State
	}
	
	$AVSoftwareTable.Add($obj)
}

if (($AVSoftwareTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{Information = 'Information: There is no EndPoint Protection'}
	$AVSoftwareTable.Add($obj)
}

#Pull Software Installed
$SoftwareTable = New-Object 'System.Collections.Generic.List[System.Object]'
#$InstalledSoftware = (Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall")
$InstalledSoftware = (Get-CimInstance -ClassName WIN32_product)

foreach ($IS in $InstalledSoftware)
{
	$DisplayName = $IS.Name
	$DisplayVersion = $IS.Version
    $Publisher = $IS.Vendor
	$obj = [PSCustomObject]@{
		
		'Name'    = $DisplayName
		'Version'  = $DisplayVersion
		'Publisher'   = $Publisher
	}
	
	$SoftwareTable.Add($obj)
}

if (($SoftwareTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{Information = 'Information: THere is no information to be found'}
	$SoftwareTable.Add($obj)
}

# Pulls the System Event Logs for the last 100 Errors and Warnings
$SystemEVTTable = New-Object 'System.Collections.Generic.List[System.Object]'
$SysEvents = (Get-EventLog -LogName System -EntryType Error,Warning -Newest 100)
foreach ($SysEvent in $SysEvents)
{
	
	$EventID = $SysEvent.EventID
    $Data = $SysEvent.Data
	$Index = $SysEvent.Index
    $Category = $SysEvent.Category
    $CategoryNumber = $SysEvent.CategoryNumber
    $EntryType = $SysEvent.EntryType
    $Message = $SysEvent.Message
    $Source = $SysEvent.Source
    $InstanceId = $SysEvent.InstanceId
    $TimeGenerated = $SysEvent.TimeGenerated
	$TimeWritten = $SysEvent.TimeWritten
	$UserName = $SysEvent.UserName
	$Site = $SysEvent.Site
	$Container = $SysEvent.Container

	$obj = [PSCustomObject]@{

        'Event ID'    		= $EventID		
		'Data'  			= $Data
        'Index'     		= $Index
		'Category'     		= $Category
		'Category Number'   = $CategoryNumber
        'Entry Type'     	= $EntryType
		'Message'  			= $Message
        'Source'       		= $Source
        'Instance ID'       = $InstanceId
        'Generated On'      = $TimeGenerated
		'Written On'        = $TimeWritten
		'User Name'         = $UserName
		'Site'          	= $Site
		'Container'         = $Container
	}
	
	$SystemEVTTable.Add($obj)
}

if (($SystemEVTTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: There are no Errors or Warnings in this event log'
	}
	$SystemEVTTable.Add($obj)
}

# Pulls the Application Event Logs for the last 100 Errors and Warnings
$AppEVTTable = New-Object 'System.Collections.Generic.List[System.Object]'
$AppEvents = (Get-EventLog -LogName Application -EntryType Error,Warning -Newest 100)
foreach ($AppEvent in $AppEvents)
{
	$EventID = $AppEvent.EventID
    $Data = $AppEvent.Data
	$Index = $AppEvent.Index
    $Category = $AppEvent.Category
    $CategoryNumber = $AppEvent.CategoryNumber
    $EntryType = $AppEvent.EntryType
    $Message = $AppEvent.Message
    $Source = $AppEvent.Source
    $InstanceId = $AppEvent.InstanceId
    $TimeGenerated = $AppEvent.TimeGenerated
	$TimeWritten = $AppEvent.TimeWritten
	$UserName = $AppEvent.UserName
	$Site = $AppEvent.Site
	$Container = $AppEvent.Container
	
	
	$obj = [PSCustomObject]@{
		
        'Event ID'			= $EventID
		'Data'   			= $Data
        'Index'     		= $Index
		'Category'  		= $Category
		'Category Number'   = $CategoryNumber
        'Entry Type'     	= $EntryType
		'Message'  			= $Message
        'Source'       		= $Source
        'Instance ID'       = $InstanceId
        'Generated On'      = $TimeGenerated
		'Written On'        = $TimeWritten
		'User Name'         = $UserName
		'Site'          	= $Site
		'Container'         = $Container
	}
	
	$AppEVTTable.Add($obj)
}

if (($AppEVTTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: There are no Errors or Warnings in this event log'
	}
	$AppEVTTable.Add($obj)
}

# Pulls the Security Event Logs for the last 100 Errors and Warnings
$SecEVTTable = New-Object 'System.Collections.Generic.List[System.Object]'
$SecEvents = (Get-EventLog -LogName Security -EntryType FailureAudit -Newest 100)
foreach ($SecEvent in $SecEvents)
{
	$EventID = $SecEvent.EventID
    $Data = $SecEvent.Data
	$Index = $SecEvent.Index
    $Category = $SecEvent.Category
    $CategoryNumber = $SecEvent.CategoryNumber
    $EntryType = $SecEvent.EntryType
    $Message = $SecEvent.Message
    $Source = $SecEvent.Source
    $InstanceId = $SecEvent.InstanceId
    $TimeGenerated = $SecEvent.TimeGenerated
	$TimeWritten = $SecEvent.TimeWritten
	$UserName = $SecEvent.UserName
	$Site = $SecEvent.Site
	$Container = $SecEvent.Container
	
	$obj = [PSCustomObject]@{
		
        'Event ID'    = $EventID
		'Data'   = $Data
        'Index'     = $Index
		'Category'     = $Category
		'Category Number'        = $CategoryNumber
        'Entry Type'     = $EntryType
		'Message'  = $Message
        'Source'       = $Source
        'Instance ID'        = $InstanceId
        'Generated On'          = $TimeGenerated
		'Written On'          = $TimeWritten
		'User Name'          = $UserName
		'Site'          = $Site
		'Container'          = $Container
    
	}
	
	$SecEVTTable.Add($obj)
}

if (($SecEVTTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: There are no Errors or Warnings in this event log'
	}
	$SecEVTTable.Add($obj)
}

$tabarray = @('Dashboard', 'Device List', 'Missing Windows Updates', 'Installed Software', 'System Event Logs', 'Application Event Logs', 'Security Event Logs')

#Dashboard Report
$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'
$FinalReport.Add($(Get-HTMLOpenPage -TitleText $ReportTitle -LeftLogoString $CompanyLogo -RightLogoString $RightLogo))
$FinalReport.Add($(Get-HTMLTabHeader -TabNames $tabarray))
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[0] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Vendor Information"))
$FinalReport.Add($(Get-HTMLContentTable $HardwareTable1))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "CPU Information"))
$FinalReport.Add($(Get-HTMLContentTable $HardwareTable2))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Bios Information"))
$FinalReport.Add($(Get-HTMLContentTable $BIOTable))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Operating System Information"))
$FinalReport.Add($(Get-HTMLContentTable $OSTable))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Endpoint Protection"))
$FinalReport.Add($(Get-HTMLContentTable $AVSoftwareTable))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Storage"))
$FinalReport.Add($(Get-HTMLContentDataTable $StorageTable ))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Printers"))
$FinalReport.Add($(Get-HTMLContentDataTable $PRTable))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[1] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Device List"))
$FinalReport.Add($(Get-HTMLContentDataTable $DeviceTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

# Windows Update Status Tab
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[2] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Missing Windows Updates"))
$FinalReport.Add($(Get-HTMLContentDataTable $WUTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

#Software Tab
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[3] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Installed Software"))
$FinalReport.Add($(Get-HTMLContentDataTable $SoftwareTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

#System Event Log Tab
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[4] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "System Event Logs"))
$FinalReport.Add($(Get-HTMLContentDataTable $SystemEVTTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

#Application Event Log Tab
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[5] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Application Event Logs"))
$FinalReport.Add($(Get-HTMLContentDataTable $AppEVTTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

#Security Event Log Tab
$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[6] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Security Event Logs"))
$FinalReport.Add($(Get-HTMLContentDataTable $SecEVTTable ))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLColumnClose))

$FinalReport.Add($(Get-HTMLTabContentClose))
$FinalReport.Add($(Get-HTMLClosePage))

Write-Host "Compiling Report..." -ForegroundColor Green

Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName $ReportName -ReportPath $ReportSavePath