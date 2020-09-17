# Understanding the Profiles

You can have four different profiles in Windows PowerShell. The profiles are listed in load order. The most specific
profiles have precedence over less specific profiles where they apply.

**%windir%\system32\WindowsPowerShell\v1.0\profile.ps1**
This profile applies to all users and all shells.

**%windir%\system32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1**
This profile applies to all users, but only to the Microsoft.PowerShell shell.

**%UserProfile%\Documents\WindowsPowerShell\profile.ps1**
This profile applies only to the current user, but affects all shells.

**%UserProfile%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1**
This profile applies only to the current user and the Microsoft.PowerShell shell.


## Creating a Profile

When you create or import variables, aliases, or functions, or add a Windows PowerShell snap-in, these elements are added
only to the current session. If you exit the session or close the window, they are gone.

To save the variables, aliases, functions, and commands that you use routinely, and make them available in every Windows
PowerShell session, add them to your Windows PowerShell profile.

You can also create, share, and distribute profiles to enforce a consistent view of Windows PowerShell in a larger enterprise.

Windows PowerShell profiles are not created automatically. To create a profile, create a text file with the specified name
in the specified location. Typically, you will use the user-specific, shell-specific profile, known as the Windows PowerShell
user profile. The location of this profile is stored in the $profile variable.

To display the path to the Windows PowerShell profile, type:
`$profile`

or

`$profile | Select-Object -Property AllUsersAllHosts,AllUsersCurrentHost,CurrentUserAllHosts,CurrentUserCurrentHost | Format-List`

To determine whether a Windows PowerShell profile has been created on the system, type:
`test-path $profile`
If the profile exists, the response is True; otherwise, it is False.


# Profiles in Windows PowerShell ISE

https://docs.microsoft.com/en-us/powershell/scripting/components/ise/how-to-use-profiles-in-windows-powershell-ise?view=powershell-7

The profile that you use is determined by how you use Windows PowerShell and Windows PowerShell ISE.

* If you use only Windows PowerShell ISE to run Windows PowerShell, then save all your items in one of the ISE-specific profiles, such as the CurrentUserCurrentHost profile for Windows PowerShell ISE or the AllUsersCurrentHost profile for Windows PowerShell ISE.

* If you use multiple host programs to run Windows PowerShell, save your functions, aliases, variables, and commands in a profile that affects all host programs, such as the CurrentUserAllHosts or the AllUsersAllHosts profile, and save ISE-specific features, like color and font customization in the CurrentUserCurrentHost profile for Windows PowerShell ISE profile or the AllUsersCurrentHost profile for Windows PowerShell ISE.

The following are profiles that can be created and used in Windows PowerShell ISE. Each profile is saved to its own specific path.

Profile Type | Profile Path
--- | ---
Current user, PowerShell ISE | `$PROFILE.CurrentUserCurrentHost`, or `$PROFILE`
All users, PowerShell ISE | `$PROFILE.AllUsersCurrentHost`
Current user, All hosts | `$PROFILE.CurrentUserAllHosts`
All users, All hosts | `$PROFILE.AllUsersAllHosts`

## To create a new profile

To create a new “Current user, Windows PowerShell ISE” profile, run this command:
```PowerShell
if (!(Test-Path -Path $PROFILE ))
{ New-Item -Type File -Path $PROFILE -Force }
```

To create a new “All users, Windows PowerShell ISE” profile, run this command:
```PowerShell
if (!(Test-Path -Path $PROFILE.AllUsersCurrentHost))
{ New-Item -Type File -Path $PROFILE.AllUsersCurrentHost -Force }
```

To create a new “Current user, All Hosts” profile, run this command:
```PowerShell
if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts))
{ New-Item -Type File -Path $PROFILE.CurrentUserAllHosts -Force }
```

To create a new “All users, All Hosts” profile, type:
```PowerShell
if (!(Test-Path -Path $PROFILE.AllUsersAllHosts))
{ New-Item -Type File -Path $PROFILE.AllUsersAllHosts -Force }
```

## To edit a profile

1. To open the profile, run the command psEdit with the variable that specifies the profile you want to edit. For example, to open the “Current user, Windows PowerShell ISE” profile, type: psEdit $PROFILE

2. Add some items to your profile. The following are a few examples to get you started:

     * To change the default background color of the Console Pane to blue, in the profile file type: `$psISE.Options.OutputPaneBackground = 'blue'` . For more information about the `$psISE` variable, see Windows PowerShell ISE Object Model Reference.

     * To change font size to 20, in the profile file type: `$psISE.Options.FontSize =20`

3. To save your profile file, on the File menu, click Save. Next time you open the Windows PowerShell ISE, your customizations are applied.

## How to start a profile

When you open the profile file, it is blank. However, you can fill it with the variables, aliases, and commands that you use frequently.

Here are a few suggestions to get you started.

### Add commands that make it easy to open your profile

This is especially useful if you use a profile other than the "Current User, Current Host" profile. For example, add the following command:
```PowerShell
function Pro {notepad $PROFILE.CurrentUserAllHosts}
```

### Add a function that lists the aliases for any cmdlet
```PowerShell
function Get-CmdletAlias ($cmdletname) {
  Get-Alias |
    Where-Object -FilterScript {$_.Definition -like "$cmdletname"} |
      Format-Table -Property Definition, Name -AutoSize
}
```

### Customize your console
```PowerShell
function Color-Console {
  $Host.ui.rawui.backgroundcolor = "white"
  $Host.ui.rawui.foregroundcolor = "black"
  $hosttime = (Get-ChildItem -Path $PSHOME\PowerShell.exe).CreationTime
  $hostversion="$($Host.Version.Major) `.$($Host.Version.Minor)"
  $Host.UI.RawUI.WindowTitle = "PowerShell $hostversion ($hosttime)"
  Clear-Host
}
Color-Console
```

### Add a customized PowerShell prompt
```PowerShell
function Prompt
{
$env:COMPUTERNAME + "\" + (Get-Location) + "> "
}
```

For more information about the PowerShell prompt, see about_Prompts.


# PowerShell remoting over SSH
##Set up on a macOS computer

  Install the latest version of PowerShell, 'brew cask install PowerShell'.

  Make sure SSH Remoting is enabled by following these steps:
      Open System Preferences.
      Click on Sharing.
      Check Remote Login to set Remote Login: On.
      Allow access to the appropriate users.

  Edit the sshd_config file at location /private/etc/ssh/sshd_config.

  Use a text editor such as nano:
    sudo nano /private/etc/ssh/sshd_config

  Make sure password authentication is enabled:
    PasswordAuthentication yes
  Optionally, enable key authentication:
    PubkeyAuthentication yes

  Add a PowerShell subsystem entry:
    Subsystem powershell /usr/local/bin/pwsh -sshs -NoLogo

  Restart the sshd service.
    sudo launchctl stop com.openssh.sshd
    sudo launchctl start com.openssh.sshd
