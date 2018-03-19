function ConvertTo-Array {
	[cmdletbinding()]
	param(
        [string[]]$Lines
	)
	write-host $_
	if($Lines -eq "" -or $Lines -eq $null){return}

	$h,$headers = $false
	$array = @()
	$Lines | %{
		$i++
		if($_.StartsWith("#")){
			if($headers){
				$h = $_.replace("# ","")
				$h = $h.split("`t")
				$headers = $false
				return
			}
			if($_.StartsWith("# Headers")){
				$headers = $true
				return
			}
			return
		}
		
		$arrLine = $_.split("`t")

		$item = New-Object PSObject
				
		0..($h.count-1) | %{
			if($h[$_] -match '^.*_t'){
				$value = ConvertFrom-UnixDate($arrLine[$_])
			} else {
				$value = $arrLine[$_]
			}
			$item | Add-Member -type NoteProperty -Name $h[$_] -Value $value
		}

		$array += $item
	}
	return $array
}