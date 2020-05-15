<#####################################################################################
This is free and unencumbered software released into the public domain.

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

For more information, please refer to <http://unlicense.org>                                                                     #
#####################################################################################>
<#
.NAME
    Get-ActiveHosts.ps1
.SYNOPSIS
    This is a script to loop through a .csv of hosts and IP addresses to find all 
    active hosts.
.DESCRIPTION
    This uses a WMI wrapper function to get information from a target computer system.  
    The PowerShell script requires two directories be created on the target drive 
    (Case_Data and Tools).  This script and FDPro.exe should be placed in the Tools 
    directory along with any other command line tools you would like to execute.
.SYNTAX
    .\Get-ActiveHosts.ps1
.PARAMETER 
    Non at this time.
.EXAMPLE
    \Get-ActiveHosts.ps1
.Notes 
  Author: Rodney Smith  
 Version: 1.1
 Updated: 13.May.2020

Requires -Version 3.0 
#>

# Get Shell Folder value for Downloads of the Current User
  $key = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
$value = "{374DE290-123F-4565-9164-39C4925E467B}"
 $path = (Get-ItemProperty -Path $key -Name $value).$value

#Read the hosts information from the .csv file
$_env = Import-Csv $path\ResourceRecords.csv

#Setup veriables
 $outputCSV = @()
$Confluence = @()
   $siteURL = @()
#       $env = $_env | Where-Object {$_.Name -ne $env:COMPUTERNAME}
      $name = $_env.Name
      $type = $_env.Type
      $data = $_env.Data
   $comment = $_env.Comment
      $site = $_env.Site
$outputFile = $path + "\ActiveHosts.csv"


ForEach ($n in $name){
  If ([string]::IsNullOrEmpty($n)){
    Write-Host "Value is NULL or EMPTY." -ForegroundColor Yellow
  } # EndIf
  Else{
    If (Test-Connection -ComputerName $n -Count 1 -ErrorAction SilentlyContinue){
      $outputCSV += "$n,up"
      $url = "https://confluence/rest/api/search?cql=siteSearch~'" + $d + "'"
      $Confluence += Invoke-RestMethod -Method Get -Uri $url
      $siteURL += $Confluence.results.url
      Write-Host "$n is up" -ForegroundColor Green
    } # EndIf
    Else{
      Write-Host "$n is down" -ForegroundColor Red
    } # EndElse
  } # EndElse
} # EndForEach

ForEach ($d in $data){
  If ([string]::IsNullOrEmpty($d)){
    Write-Host "Value is NULL or EMPTY." -ForegroundColor Yellow
  }
  Else{
    If (Test-Connection -ComputerName $d -Count 1 -ErrorAction SilentlyContinue){
      $outputCSV += "$d,up"
      $url = "https://confluence/rest/api/search?cql=siteSearch~'" + $d + "'"
      $Confluence += Invoke-RestMethod -Method Get -Uri $url
      $siteURL += $Confluence.results.url
      Write-Host "$d is up" -ForegroundColor Green
    } # EndIf
    Else{
      Write-Host "$d is down" -ForegroundColor Red
    } # EndElse
  } # EndElse
} # EndForEach

$siteURL
$outputCSV | Out-File -Append $outputFile -Encoding UTF8

<# Testing Code
$d = "167.10.5.15" # Sample IP Address
url = "https://confluence/rest/api/search?cql=siteSearch~'" + $d + "'"
# Invoke-WebRequest
$ConfluenceWR = Invoke-WebRequest -Method Get -Uri $url
# Invoke-RestMethod
$ConfluenceRM = Invoke-RestMethod -Method Get -Uri $url
#>

<# Generate email with attachment on Mondays
[array]$TO = "group_mailbox@email.com"
#Modify the IF statement variable with the correct location variable.
if(((Get-Date).DayOfWeek) -eq "Monday")
{
    $TO += "person1@email.com","person2@email.com","person3@email.com"
}
#email some people
Send-MailMessage -To         $TO `
                 -Subject    "Active Hosts$ecc" `
                 -From       "no-reply@email.com" `
                 -smtpServer "smtp.servername.net" `
                 -Body       $text `
                 -Attachments $outputFile
#>

