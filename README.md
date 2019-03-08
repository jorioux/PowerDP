# PowerDP
> #### by Jonathan Rioux
> ***Note*** This module is NOT affiliated with, funded, or in any way associated with Micro Focus.

PowerShell for Micro Focus Data Protector (DP)
-
This PowerShell Module uses the `omnirpt` and `omnidb` and converts the output into native PowerShell arrays.

Installation
-
You can install this module on the Cell Manager if its running on Windows, or you can install the `User Interface` component on your workstation.
#### PowerShell v5 and later
You can install the `PowerDP` module directly from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerDP)
```PowerShell
Install-Module PowerDP
```

#### PowerShell v4 and earlier
Get [PowerShellGet Module](https://docs.microsoft.com/en-us/powershell/gallery/psget/get_psget_module) then do `Install-Module PowerDP`

Usage examples
-
```PowerShell
# The main functions are `Get-Omnidb` and `Get-Omnirpt`.
# The column names are kept the same, so you can easily filter with the columns names and display only the columns you want.
Get-Omnirpt -Report obj_copies -Days 7
Get-Omnirpt -Report obj_nobackup
Get-Omnirpt -Report session_objects -Session 2019/03/03-12

Get-Omnidb -Session 2019/03/07-7 -Listcopies
Get-Omnidb -Session 2019/03/03-2 -Media

#Converts the list_sessions report to a PowerShell array with additionnal filters
Get-ListSessions | Out-GridView
Get-ListSessions -Specification *full* -Days 7 -SessionType backup
Get-ListSessions -Specification *sql* -Hours 4 -Mode trans

#Fetches the session messages of each SQL restore sessions and returns a PowerShell array
Get-SQLRestoreSessions -Days 2
```

`Get-Omnirpt` usage
-
You must specify a report. You can omit `-Report` and only write `Get-Omnirpt <report_name>` if you want. Some reports requires additional parameters like `-Session` or `-Timeframe`. You can substitute `-Timeframe` by `-Days`.

A few examples:
```PowerShell
Get-Omnirpt obj_copies -Days 2
Get-Omnirpt obj_copies -Timeframe "48 48"
Get-Omnirpt session_media -Session 2019/03/03-6
```

Available reports for `-Report` parameter are:
* list_sessions
* used_media
* host_statistics
* obj_nobackup
* obj_copies
* obj_lastbackup
* obj_avesize
* media_list
* single_session
* session_objects
* session_hosts
* session_devices
* session_media
* session_objcopies

`Get-Omnidb` usage
-
You must specify a session with `-Session`. You can then specify one these parameters:

* `-Media`
* `-Listcopies`

A few examples:
```PowerShell
Get-Omnidb 2019/03/07-7 -Listcopies
Get-Omnidb 2019/03/03-2 -Media
```

Prerequisites
-
PowerDP requires `omniback` to be installed, and its `bin` directory must be in the PATH environment variable.
You can install the `User Interface` component on your workstation if you want to use PowerDP on your workstation. To do so, add your workstation as a Client in the CM and install only the `User Interface` component.

Compatibility
-
Confirmed working on DP versions 10.00 and up.

Contribution
-
Feel free to open issues and to contribute!