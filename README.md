# PowerDP
PowerShell for HPE Data Protector (DP)
-
This PowerShell Module converts the `omnirpt <...> -tab` output into a PowerShell array for easy filtering and manipulation. I intent to develop other functions in the future that builds on top of that.

***Note*** This module is NOT affiliated with, funded, or in any way associated with HPE.

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

Usage
-
The main function is `ConvertTo-Array`. You can pipline the output from the `omnirpt` command or pass it as a parameter.
```PowerShell
omnirpt -report list_sessions -timeframe 24 24 -tab | ConvertTo-Array

omnirpt -report used_media -timeframe 48 48 -tab | ConvertTo-Array | Where-Object {$_.Location -like "*HP:MSL6480*"}
```

There is also ready-to-use functions to generate reports in PowerShell array format.
```PowerShell
Get-ListSessions | Out-GridView

Get-ListSessions -Specification *full* -Days 7 -SessionType backup

Get-ListSessions -Specification *sql* -Hours 4 -Mode trans
```

The column names are kept the same, so you can easily filter with the columns names and display only the columns you want. It's important to include the `-tab` parameter because the function needs the input to be tab separated.

Prerequisites
-
PowerDP requires `omniback` to be installed, and its `bin` directory must be in the PATH environment variable.
You can install the `User Interface` component on your workstation if you want to use PowerDP on your workstation. To do so, add your workstation as a Client in the CM and install only the `User Interface` component.

Release notes
-
#### 1.0.4
* Added new function : Get-SessionObjects
* Enhanced function ConvertTo-Array
    - Removed "[" and "]" in column names so they are displayed correctly in Out-GridView
    - "Duration" column now displays with seconds
    - Converts the "Size [kB]" column to "Size (GB)" for better readability of the size
#### 1.0.3
* Added new function : Get-ListSessions
* Removed "\_t" (timestamp) column and keep only the non-"\_t" column since its already converted to DateTime format
* Some code optimization

#### 1.0.2
* Initial stable release