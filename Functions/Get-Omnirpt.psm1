Function Get-Omnirpt {
    <#
        .SYNOPSIS
            omnirpt -report session_objects
        .DESCRIPTION
            Converts the session_objects report to a PowerShell array
        .EXAMPLE
            Get-Omnirpt 2018/03/30-01
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Report,
        [string]$Session,
        [string]$Timeframe,
        [int]$Days
    )

    $ValidReports = @(
        'list_sessions',
        'used_media',
        'host_statistics',
        'obj_nobackup',
        'obj_copies',
        'obj_lastbackup',
        'obj_avesize',
        'media_list',
        'single_session',
        'session_objects',
        'session_hosts',
        'session_devices',
        'session_media',
        'session_objcopies'
    )

    if(!$ValidReports.Contains($Report)){
        write-host "Not a valid report. Valid reports are :`n"
        $ValidReports | %{write-host "`t$_"}
        return ""
    }

    $Cmd = "omnirpt -report $Report "

    if(![string]::IsNullOrEmpty($Session)){
        $Cmd += " -session $Session "
    }

    if($Days -ge 1){
        $Timeframe = [string]($Days*24)
        $Timeframe = $Timeframe + " " + $Timeframe
        $Cmd += " -timeframe $Timeframe "
    } elseif(![string]::IsNullOrEmpty($Timeframe)){
        $Cmd += " -timeframe $Timeframe "
    }

    $Cmd += ' -tab'

    $Array = Invoke-Expression -Command $Cmd | ConvertFrom-Omnirpt

    return $Array | Select-Object *
}