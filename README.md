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
```
```PowerShell
omnirpt -report used_media -timeframe 48 48 -tab | ConvertTo-Array | Where-Object {$_.Location -like "*HP:MSL6480*"}
```

The column names are kept the same, so you can easily filter with the columns names and display only the columns you want. It's important to include the `-tab` parameter because the function needs the input to be tab separated.