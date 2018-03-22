# PowerDP
PowerShell for HPE Data Protector (DP)
-

This PowerShell Module converts the `omnirpt <...> -tab` output into a PowerShell array for easy filtering and manipulation. I intent to develop other functions in the future that builds on top of that.

Installation
-
#### PowerShell v5 and Later
You can install the `PowerDP` module directly from the PowerShell Gallery
```PowerShell
Install-Module PowerDP
```

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

Release notes
-
#### 1.0.3
* Added new function : Get-ListSessions
* Removed "\_t" (timestamp) column and keep only the non-"\_t" column since its already converted to DateTime format
* Some code optimization

#### 1.0.2
* Initial stable release