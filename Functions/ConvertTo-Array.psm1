Function ConvertTo-Array {
	<#
		.SYNOPSIS
			Creates an array out of the omnirpt output
		.DESCRIPTION
			Converts the "omnirpt <...> -tab" output into a native PowerShell array for easy filtering and manipulation.
		.EXAMPLE
			omnirpt -report list_sessions -timeframe 24 24 -tab | ConvertTo-Array
		.EXAMPLE
			omnirpt -report used_media -timeframe 24 24 -tab | ConvertTo-Array | Where-Object {$_.Location -like "*HP:MSL6480*"}
		.LINK
			https://github.com/jorioux/PowerDP
	#>

	[OutputType([System.Object[]])]
	[CmdletBinding()]
	Param(
		[Parameter(ValueFromPipeline = $true)]
        [string[]]$Lines
	)
	BEGIN {
		$ConvertFrom = ""
		$Headers = $False
		$ArrayOutput = @()
		$i = 0
	}
	PROCESS {
		$Lines | ForEach-Object {
			#Detect type of input
			if($ConvertFrom -eq ""){
				if($_.Startswith("#")){
					$ConvertFrom = "tab"
				} else {
					$ConvertFrom = "notab"
				}
			}


			$StartTime, $EndTime, $Time = $null

			#skip line if null or empty
			if([string]::IsNullOrEmpty($_)){return}

			$ArrLine = @()
			$Item = New-Object PSObject
			$i++


			if($ConvertFrom -eq "tab"){
				
				#skips lines until at the headers line
				if($_.StartsWith("#")){
					#if current line contains the headers
					if($Headers -eq $True){
						$Headers = $_.replace("# ","")
						$Headers = $Headers.split("`t")
						return
					}
					#if the next line contains the headers
					if($_.StartsWith("# Headers")){
						$Headers = $True
						return
					}
					return
				#exit if unable to fetch the headers
				} elseif($Headers -eq $False -or $Headers.Count -eq 0) {
					Write-Error "Failed to fetch the headers from the input."
					break
				}
				
				$ArrLine = $_.split("`t")

			} else {

				#Skip if delimiter line
				if($_ -match "^(={3,}|-{3,}|_{3,})" -or [string]::IsNullOrEmpty($_)){
					return
				}

				#Parse line with pattern
				$line = $_ | Select-String -Pattern "\s*(.*?)(?:\s{2,}|$)" -AllMatches
				
				#Skip if invalid line
				if($line.Matches.count -lt 3){
					return
				}

				#Convert the line to an array
				Foreach($match in $line.Matches) {
					if(![string]::IsNullOrEmpty($match.Groups[1].Value)){
						$ArrLine += $match.Groups[1].Value
					}
				}

				#Grab the headers
				if($Headers -eq $false){
					$Headers = $ArrLine
					return
				}


			}

			0..($Headers.count-1) | ForEach-Object {
				if($Headers[$_] -match '^.*_t'){
					$Time = (ConvertFrom-UnixDate $ArrLine[$_])
					if($Headers[$_] -match '^Start.*_t'){
						$StartTime = $Time
					} elseif($Headers[$_] -match '^End.*_t'){
						$EndTime = $Time
					}
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace('_t','') -Value $Time
				} elseif($Headers[$_+1] -match '^.*_t') {
					return
				} elseif($Headers[$_] -match '^Duration.*') {

					#If job is not ended yet, we set the Duration to null
					if($StartTime -gt $EndTime){
						$Duration = $null

					} elseif($StartTime -ne $null -and $EndTime -ne $null){
						$Duration = [TimeSpan]::Parse($EndTime - $StartTime)

					} else {
						try {
							$Duration = [TimeSpan]::Parse($ArrLine[$_])
						} catch {
							$Duration = $ArrLine[$_]
						}
					}
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace(' [hh:mm]','') -Value $Duration
				} elseif($Headers[$_] -match '^.*\[kB\]') {
					$Size = $ArrLine[$_]/1KB/1KB
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace(' [kB]',' (GB)') -Value $Size
				} elseif($Headers[$_] -match '^.*\[MB/min\]') {
					$Value = ConvertTo-Int $ArrLine[$_]
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace(' [MB/min]',' (MB/min)') -Value $Value
				} elseif($Headers[$_] -match '(GB Written|Media|Errors|Warnings|Objects|Files)') {
					$Value = ConvertTo-Int $ArrLine[$_]
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace(' [MB/min]',' (MB/min)') -Value $Value
				} else {
					$Item | Add-Member -type NoteProperty -Name $Headers[$_] -Value $ArrLine[$_]
				}

			}

			$ArrayOutput += $Item
		}
	}
	END {
		return $ArrayOutput
	}
}

Function ConvertTo-Int {
	<#
		.SYNOPSIS
			Converts a string value to a Int or Double
	#>
	[CmdletBinding()]
	Param(
		[Parameter(ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
        $IntVal
	)
	try{
		if($IntVal.GetType().FullName -match '^.*Int.*$') {
			return [int]$IntVal
		} elseif($IntVal.GetType().FullName -match '^.*(Double|Float).*$') {
			return [math]::Round([double]$IntVal,2)
		} elseif($IntVal -match '^.*(\,|\.).*$') {
			return [math]::Round([double]($IntVal.replace(',','.')),2)
		} else {
			return [int]($IntVal)
		}
	} catch {
		return $IntVal
	}
}