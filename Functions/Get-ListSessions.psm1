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
        [String]$Status = "*",
        [switch]$WithMedia #fetch for Media label and pool name
    )

    $Cmd = 'omnirpt -report list_sessions'

    #generate timestamp parameter
    if($Timeframe -notmatch '^\d+\s\d+$'){
        $Hours += ($Days * 24)
        if($Hours -lt 1){
            $Hours = 24
        }
        $Timeframe = $([string]$Hours + ' ' + [string]$Hours)
    }

    $Cmd += ' -timeframe ' + $Timeframe
    $Cmd += ' -tab'

    $Array = Invoke-Expression -Command $Cmd | ConvertFrom-Omnirpt

    if($WithMedia){
        $NewArray = @()
        $Array | %{
            $Session = $_
            $PoolName = ''
            $Medias = ''
            #Fetch Media info only if session type is Copy
            if($Session.'Session Type' -like "*copy*"){
                $Cmd = 'omnirpt -report session_media'
                $Cmd += ' -session ' + $Session.'Session ID'
                $Cmd += ' -tab'
                
                $(Invoke-Expression -Command $Cmd | ConvertFrom-Omnirpt) | %{
                    $Medias += (($_.Label).split('[')[1]).split(']')[0] + ' '
                    $PoolName = $_.'Pool Name'
                }
                $Medias = $Medias.Trim()
            }
            $NewArray += $Session | 
                            Select-Object -Property *, @{n='Media Labels'; e={$SessionID = $Session.'Session ID'; $Medias}} | 
                            Select-Object -Property *, @{n='Pool Name'; e={$SessionID = $Session.'Session ID'; $PoolName}}
        }
        $Array = $NewArray
    }

    return $Array | Where {
        $_.Specification -like "$Specification" -and 
        $_.'Session Type' -like "$SessionType" -and 
        $_.Mode -like "$Mode" -and 
        $_.Status -like "$Status"
    } | Select-Object * -ExcludeProperty *Owner,*DA,Success | Sort-Object -Property "Start Time"
}