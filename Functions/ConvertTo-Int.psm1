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