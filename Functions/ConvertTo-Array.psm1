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
		[ValidateNotNullOrEmpty()]
        [string[]]$Lines
	)
	BEGIN {
		$Headers = $False
		$ArrayOutput = @()
		$i = 0
	}
	PROCESS {
		$Lines | ForEach-Object {

			#skip line if null or empty
			if([string]::IsNullOrEmpty($_)){return}

			$ArrLine = @()
			$Item = New-Object PSObject
			$i++
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
				Write-Error "Failed to fetch the headers from the input. Make sure you use the '-tab' parameter with the omnirpt command."
				break
			}
			
			$ArrLine = $_.split("`t")

			0..($Headers.count-1) | ForEach-Object {
				if($Headers[$_] -match '^.*_t'){
					$Item | Add-Member -type NoteProperty -Name $Headers[$_].replace('_t','') -Value (ConvertFrom-UnixDate $ArrLine[$_])
				} elseif($Headers[$_+1] -match '^.*_t') {
					return
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