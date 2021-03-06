<#
.NAME
    Get-SystemInfo.ps1
.SYNOPSIS
    Gather information about target computer.  (Including Current Date/Time, BIOS, 
    SystemInfo, Environment Variables, IP Address, ARP Table, Network Shares, 
    Running Processes, Scheduled Tasks.
.DESCRIPTION
    This uses a WMI wrapper function to get information from a target computer system.  
    The PowerShell script requires two directories be created on the target drive 
    (Case_Data and Tools).  This script and FDPro.exe should be placed in the Tools 
    directory along with any other command line tools you would like to execute.
.SYNTAX
    .\Get-SystemInfo.ps1 (drive letter:)
.PARAMETER TargetDrive
    The drive letter where you want the report to be stored.
.EXAMPLE
    \Get-SystemInfo.ps1 E:
.Notes 
  Author: Rodney Smith  
 Version: 1.1
 Updated: 13.May.2020
   LEGAL: This is free and unencumbered software released into the public domain.
          Anyone is free to copy, modify, publish, use, compile, sell, or
          distribute this software, either in source code form or as a compiled
          binary, for any purpose, commercial or non-commercial, and by any
          means.
          In jurisdictions that recognize copyright laws, the author or authors
          of this software dedicate any and all copyright interest in the
          software to the public domain. We make this dedication for the benefit
          of the public at large and to the detriment of our heirs and
          successors. We intend this dedication to be an overt act of
          relinquishment in perpetuity of all present and future rights to this
          software under copyright law.
          THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
          EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
          MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
          IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
          OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
          ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
          OTHER DEALINGS IN THE SOFTWARE.
          For more information, please refer to <http://unlicense.org>

Requires -Version 3.0 
#>

param(
    [Parameter(Mandatory=$true)][string]$TargetDrive
)

      $key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $value = "InstallationType"
 $InstType = (Get-ItemProperty -Path $key -Name $value).$value
$TargetDir = "$TargetDrive\util"
  $Logfile = $TargetDir+"\"+$env:COMPUTERNAME+"_SystemInfo.log"

#this logs all commands and output to a file
Write-Host "Starting Transcript"
Start-Transcript -path "$TargetDir\$PCName.txt"

# Log Local System Environment Information
Write-Host  "Current Date: " $(get-date) `r`n
Write-Host  "Logged On User: " $env:USERNAME `r`n
Write-Host  "Computer Name: " $env:COMPUTERNAME `r`n
Write-Host  "Operating System Version: " $((Get-WmiObject Win32_OperatingSystem).version) `r`n

#Connect to Target System
#Enter-PSSession $PCName
#get-date

Write-Host "WmiOject BIOS Call" `r`n
$(Get-WmiObject win32_BIOS)
Write-Host "WmiOject CompterSystem Call" `r`n
$(Get-WmiObject win32_ComputerSystem) 
Write-Host "WmiOject OperatingSystem Call" `r`n
$(Get-WmiObject win32_OperatingSystem) 
Write-Host "Name: " $((Get-WmiObject Win32_OperatingSystem).Name) `r`n
Write-Host "Description: " $((Get-WmiObject Win32_OperatingSystem).Description) `r`n
Write-Host "Architecture: " $((Get-WmiObject Win32_OperatingSystem).OSArchitecture) `r`n
Write-Host "Caption: " $((Get-WmiObject Win32_OperatingSystem).Caption) `r`n
# $((Get-WmiObject Win32_OperatingSystem).BuildNumber)
Write-Host "Install Date: " $((Get-WmiObject Win32_OperatingSystem).InstallDate) `r`n
Write-Host "Last Boot Up Time: " $((Get-WmiObject Win32_OperatingSystem).LastBootUpTime) `r`n

# Collect System Information
Write-Host "Execute systeminfo" `r`n
CMD /C "systeminfo >$LogFile"
Write-Host "Execute set" `r`n
CMD /C "set >>$LogFile"

If($InstType -eq "Server"){
    Write-Host "Execute net statistics server" `r`n
    CMD /C "net statistics server >>$LogFile"
} # EndIf
Else{
    Write-Host "Execute net statistics workstation" `r`n
    CMD /C "net statistics workstation >>$LogFile"
} # EndElse

# Collect Network Information
Write-Host  "Execute ipconfig /all" `r`n
CMD /C "ipconfig /all >>$LogFile"
Write-Host "Execute nslookup" `r`n
CMD /C "nslookup $PCName >>$LogFile"
Write-Host "Execute ping" `r`n
CMD /C "ping -4 $PCName >>$LogFile"
Write-Host "Execute tracert" `r`n
CMD /C "tracert -d -4 $PCName >>$LogFile"
Write-Host "Execute arp -a" `r`n
CMD /C "arp -a >>$LogFile"
Write-Host "Execute nbtstat -S" `r`n
CMD /C "nbtstat -S >>$LogFile"
Write-Host "Execute net share" `r`n
CMD /C "net share >>$LogFile"

# Service Information
$(Get-Service | Group-Object status)
$(Get-Service | Where-Object {$_.status -eq "stopped"})
$(Get-Service | Where-Object {$_.status -eq "running"})

# Collect Running Processes
Write-Host "Execute netstat -anobv" `r`n
CMD /C "netstat -anobv >>$LogFile"
#Get-WmiObject win32_process | ft name, path -auto
Write-Host "Execute net start" `r`n
CMD /C "net start >>$LogFile"

# Collect Task Information
Write-Host "Execute schtasks /query" `r`n
CMD /C "schtasks /query >>$LogFile"
Write-Host "Execute tasklist /svc" `r`n
CMD /C "TaskList /svc >>$LogFile"

# Check applocker log (in audit mode)
#$(Get-WinEvent -logname "Microsoft-Windows-AppLocker/EXE and DLL" | ft time*, message -auto)

#$(Get-WmiObject win32_Service | ft name, pathname -auto)
#$(Get-ItemProperty hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run)

#end PowerShellSession
#Exit
Stop-Transcript
Exit

# A few key things I want to point out. With the run start-transcript at the start, your whole 
# console session is logged to a file. Because the script is logging the session, it does run 
# some extra commands to record the general environment. It uses Get-WMIObject to get processes
# and services that started the process.
