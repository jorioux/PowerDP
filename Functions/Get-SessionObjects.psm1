Function Get-SessionObjects {
    <#
        .SYNOPSIS
            omnirpt -report session_objects
        .DESCRIPTION
            Converts the session_objects report to a PowerShell array
        .EXAMPLE
            Get-SessionObjects 2018/03/30-01
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Session
    )

    $Cmd = 'omnirpt -report session_objects'
    $Cmd += " -session $Session"
    $Cmd += " -tab"

    $Array = Invoke-Expression -Command $Cmd | ConvertTo-Array

    return $Array | Select-Object * | Sort-Object -Property "Start Time"
}