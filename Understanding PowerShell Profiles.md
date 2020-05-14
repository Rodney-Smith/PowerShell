# Understanding the Profiles

You can have four different profiles in Windows PowerShell. The profiles are listed in load order. The most specific
profiles have precedence over less specific profiles where they apply.

**%windir%\system32\WindowsPowerShell\v1.0\profile.ps1**
This profile applies to all users and all shells.

**%windir%\system32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1**
This profile applies to all users, but only to the Microsoft.PowerShell shell.

**%UserProfile%\My Documents\WindowsPowerShell\profile.ps1**
This profile applies only to the current user, but affects all shells.

**%UserProfile%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1**
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
