Function Get-SQLRestoreSessions {
	<#
        .SYNOPSIS
            Returns a table with latest SQL restore sessions
        .DESCRIPTION
            Fetches the session messages of each SQL restore sessions and creates a PowerShell table
        .EXAMPLE
            Get-SQLRestoreSessions -Days 2
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    Param(
        [int]$Days = 1
    )

    $Cmd = "omnidb -session -type restore"
    $Cmd += " -last $Days"

	$Sessions = Invoke-Expression -Command $Cmd

	#remove the first 2 lines
	$Sessions = $Sessions[2..($Sessions.Count-1)]

	$Array = @()
	$i = 0
	$Sessions | %{
		$i++
		$Item = New-Object PSObject
		$StartTime, $EndTime, $Duration, $Database, $Target, $Source = ""
		
		#If the line matches a Session ID
		if($_ -match '^(\d{4}\/\d{2}\/\d{2}\-\d+)\s+Restore\s+(In Progress|\w+)\s+.*$'){
			$SessionID = $Matches[1]

			Write-Progress -Activity "Fetching SQL restore sessions" -status "$SessionID" -percentComplete ($i / $Sessions.Count*100)

			$Status = $Matches[2]
			$Messages = $(omnidb -session $SessionID -report)
			$Messages | %{
				if($_ -match '^.*Time:\s(.*)$'){
					if($StartTime -eq ""){
						$StartTime = [datetime]$Matches[1]
					}
					$EndTime = [datetime]$Matches[1]
					return
				}
				if($_ -match "^\s+Database name\s+:\s+'(.*)'.*$"){
					$Database = $Matches[1]
					return
				}
				if($_ -match "^\s+Target SQL Server\s+:\s+'(.*)'.*$"){
					$Target = $Matches[1]
					return
				}
				if($_ -match "^\s+Source SQL Server\s+:\s+'(.*)'.*$"){
					$Source = $Matches[1]
					return
				}
			}
			if([string]::IsNullOrEmpty($Database)){
				return
			}
			$Duration = [string]($EndTime - $StartTime)
			$Item | Add-Member -type NoteProperty -Name Database -Value $Database
			$Item | Add-Member -type NoteProperty -Name Source -Value $Source
			$Item | Add-Member -type NoteProperty -Name Target -Value $Target
			$Item | Add-Member -type NoteProperty -Name StartTime -Value $StartTime
			$Item | Add-Member -type NoteProperty -Name Duration -Value $Duration
			$Item | Add-Member -type NoteProperty -Name Status -Value $Status
			$Item | Add-Member -type NoteProperty -Name SessionID -Value $SessionID
			$Array += $Item
		} else {
			write-host "Erreur"
			return
		}
	}

	return $Array | Select-Object * | Sort-Object -Property "StartTime"
}