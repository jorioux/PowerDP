Function Get-ListSessions {
    <#
        .SYNOPSIS
            omnirpt -report list_sessions
        .DESCRIPTION
            Converts the list_sessions report to a PowerShell array
        .EXAMPLE
            Get-ListSessions -Specification *daily* -SessionType Backup
        .EXAMPLE
            Get-ListSessions -Specification *full* -Days 7
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    Param(
        [string]$Specification = "*",
        [string]$SessionType = "*",
        [int]$Hours = 0,
        [int]$Days = 0,
        [string]$Timeframe,
        [string]$Mode = "*", #full,incr,trans,etc...
        [String]$Status = "*"
    )

    $Cmd = 'omnirpt -report list_sessions'

    #generate timestamp parameter
    if($Timeframe -notmatch '^\d+\s\d+$'){
        $Hours += ($Days * 24)
        if($Hours -lt 1){
            $Hours = 24
        }
        $Timeframe = "$Hours $Hours"
    }

    $Cmd += " -timeframe $Timeframe"
    $Cmd += " -tab"

    $Array = Invoke-Expression -Command $Cmd | ConvertTo-Array

    return $Array | Where {
        $_.Specification -like "$Specification" -and 
        $_.'Session Type' -like "$SessionType" -and 
        $_.Mode -like "$Mode" -and 
        $_.Status -like "$Status"
    } | Select-Object * -ExcludeProperty *Owner,*DA,Success | Sort-Object -Property "Start Time"
}