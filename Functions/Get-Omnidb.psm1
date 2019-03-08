Function Get-Omnidb {
    <#
        .SYNOPSIS
            Returns an array with session detail
        .DESCRIPTION
            Fetches the session detail and returns a PowerShell array
        .EXAMPLE
            Get-Omnidb -Session 2019/02/07-7
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Session,
        [switch]$Media,
        [switch]$Listcopies
    )

    if($Media){
        $Cmd = "omnidb -session $Session -media -detail"
    } elseif($Listcopies){
        $Output = (Get-Omnidb -Session $Session)
        if($Output -eq $null){
            return $Output
        } else {
            $CopyID = $Output.'Copy ID'
        }
        $CopyID = $CopyID.split(' ')[0]
        $Cmd = "omnidb -copyid $CopyID -listcopies -detail"
    } else {
        $Cmd = "omnidb -session $Session -detail"
    }

    $Output = (Invoke-Expression -Command $Cmd)
    if($Output.count -le 2){
        return $Output
    } else {
        return $Output | ConvertFrom-OmnidbDetail
    }
}