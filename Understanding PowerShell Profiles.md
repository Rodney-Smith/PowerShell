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
