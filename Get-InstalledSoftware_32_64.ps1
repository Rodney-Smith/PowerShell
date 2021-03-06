<#
.NAME
    Get-InstalledSoftware_32_64.ps1
.SYNOPSIS
    This script is written to collect the installed software on both
    32-bit and 64-bit Windows systems. It reads the registry and parses
    through each hive. There is an exclude array that can be added to
    over time.
.DESCRIPTION
    This uses a WMI wrapper function to get information from a target computer 
    system.  
    The PowerShell script reads the registry hives and determines the bitness
    of the OS. Based on the architecture os the system, reads the registry for 
    both 32-bit and 64-bit applicaitons. There is a list of excluded 
    applicaiton hives that can be added to over time.
.SYNTAX
    .\Get-InstalledSoftware_32_64.ps1
.PARAMETER Computername
    The name of the computer on the network that you would like to gather 
    information on.
.EXAMPLE
    \Get-InstalledSoftware_32_64.ps1 homecomputer1
.Notes 
  Author: Rodney Smith  
 Version: 1.1
 Updated: 6.September.2019
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

Function Get-SoftwareList {
    Param([
    Parameter(Mandatory=$true)]
    [string[]]$Computername)

#Registry Hives

$Object =@()

$excludeArray = ("Definition Update for Microsoft",
                 "Security Update for Microsoft",
                 "Security Update for Windows",
                 "Update for Windows",
                 "Update for Microsoft",
                 "Update for Skype",
                 "Hotfix")

[long]$HIVE_HKROOT = 2147483648
  [long]$HIVE_HKCU = 2147483649
  [long]$HIVE_HKLM = 2147483650
   [long]$HIVE_HKU = 2147483651
  [long]$HIVE_HKCC = 2147483653
  [long]$HIVE_HKDD = 2147483654

ForEach($EachServer in $Computername){
    $Query = Get-WmiObject -ComputerName $EachServer -query "Select AddressWidth, DataWidth,Architecture from Win32_Processor" 
    ForEach ($i in $Query){
        If($i.AddressWidth -eq 64){
            $OSArch='64-bit'
        } # EndIf          
        Else{            
            $OSArch='32-bit'            
        } # EndElse
    } # EndForEach$i

Switch ($OSArch){

"64-bit"{
$RegProv = GWMI -Namespace "root\Default" -list -computername $EachServer| where{$_.Name -eq "StdRegProv"}
$Hive = $HIVE_HKLM
$RegKey_64BitApps_64BitOS = "Software\Microsoft\Windows\CurrentVersion\Uninstall"
$RegKey_32BitApps_64BitOS = "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$RegKey_32BitApps_32BitOS = "Software\Microsoft\Windows\CurrentVersion\Uninstall"

#####################################################################################
# Get 64-bit application SubKey names from 64-bit OS

$SubKeys = $RegProv.EnumKey($HIVE, $RegKey_64BitApps_64BitOS)

# Make Sure No Error when Reading Registry

    if ($SubKeys.ReturnValue -eq 0){ # Loop Trhough All Returned SubKeys
        ForEach ($Name in $SubKeys.sNames){
            $SubKey = "$RegKey_64BitApps_64BitOS\$Name"
            $ValueName = "DisplayName"
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, "DisplayVersion")).sValue 
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, "Publisher")).sValue 
            $donotwrite = $false

            if($AppName.length -gt "0"){
                ForEach($exclude in $excludeArray){
                    if($AppName.StartsWith($exclude) -eq $TRUE){
                                $donotwrite = $true
                                break}
                } # EndForEach$exclude
                if ($donotwrite -eq $false){                        
                    $Object += New-Object PSObject -Property @{
                    Appication = $AppName;
                    Architecture  = "64-BIT";
                    ServerName = $EachServer;
                    Version = $Version;
                    Publisher= $Publisher;}
                } # EndIf
            } # EndIf
        } # EndForEach$Name
    } # EndIf


#####################################################################################
# Get 32-bit application SubKey names from 64-bit OS

$SubKeys = $RegProv.EnumKey($HIVE, $RegKey_32BitApps_64BitOS)

# Make Sure No Error when Reading Registry

    if ($SubKeys.ReturnValue -eq 0){ # Loop Through All Returned SubKeys
        ForEach ($Name in $SubKeys.sNames){
            $SubKey = "$RegKey_32BitApps_64BitOS\$Name"
            $ValueName = "DisplayName"
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, "DisplayVersion")).sValue 
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, "Publisher")).sValue 
            $donotwrite = $false

            if($AppName.length -gt "0"){
                ForEach($exclude in $excludeArray){
                    if($AppName.StartsWith($exclude) -eq $TRUE){
                        $donotwrite = $true
                        break}
                    } # EndForEach$exclude
                if ($donotwrite -eq $false){
                    $Object += New-Object PSObject -Property @{
                    Appication = $AppName;
                    Architecture  = "32-BIT";
                    ServerName = $EachServer;
                    Version = $Version;
                    Publisher= $Publisher;}
                } # EndIf
            } # EndIf
        } # EndForEach$Name
    } #EndIf
  } #End 64-bit OS

#####################################################################################

"32-bit"{
$RegProv = GWMI -Namespace "root\Default" -list -computername $EachServer| where{$_.Name -eq "StdRegProv"}
$Hive = $HIVE_HKLM
$RegKey_32BitApps_32BitOS = "Software\Microsoft\Windows\CurrentVersion\Uninstall"

#####################################################################################
# Get 32-bit application SubKey names from 32-bit OS

$SubKeys = $RegProv.EnumKey($HIVE, $RegKey_32BitApps_32BitOS)

# Make Sure No Error when Reading Registry

    if ($SubKeys.ReturnValue -eq 0){ # Loop Through All Returned SubKeys
        ForEach ($Name in $SubKeys.sNames){
            $SubKey = "$RegKey_32BitApps_32BitOS\$Name"
            $ValueName = "DisplayName"
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, "DisplayVersion")).sValue 
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, "Publisher")).sValue 

            if($AppName.length -gt "0"){
                $Object += New-Object PSObject -Property @{
                Appication = $AppName;
                Architecture  = "32-BIT";
                ServerName = $EachServer;
                Version = $Version;
                Publisher= $Publisher;}
            } # EndIf
        } # EndForEach$Name
    } # EndIf
  } # End 32-bit OS
} # End of Switch
} # EndForEach$EachServer

#$AppsReport

$column1 = @{expression="ServerName"; width=15; label="Name"; alignment="left"}
$column2 = @{expression="Architecture"; width=10; label="32/64 Bit"; alignment="left"}
$column3 = @{expression="Appication"; width=80; label="Appication"; alignment="left"}
$column4 = @{expression="Version"; width=15; label="Version"; alignment="left"}
$column5 = @{expression="Publisher"; width=30; label="Publisher"; alignment="left"}

"#"*80
"Installed Software Application Report"
"Numner of Installed Application count : $($object.count)"
"Generated $(get-date)"
"Generated from $(gc env:computername)"
"#"*80

$path=$env:TEMP+"\"+$Computername+"-Installed Software.csv"

$object | Format-Table $column1, $column2, $column3 ,$column4, $column5
$object | Export-Csv -Path $path -NoTypeInformation
$object | Out-GridView 
} # EndGet-SoftwareList
