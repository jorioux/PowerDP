Function ConvertFrom-OmnidbDetail {
    <#
        .SYNOPSIS
            Returns an array from "omnidb [options] -detail" output
        .DESCRIPTION
            Accepts the output of "omnidb [options] -detail" in pipline and returns a PowerShell array
        .EXAMPLE
            omnidb -session 2019/02/07-7 -detail | ConvertFrom-OmnidbDetail
        .LINK
            https://github.com/jorioux/PowerDP
    #>

    Param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Lines,
        [switch]$FullObjectName
    )
    BEGIN {
        $ArrayOutput = @()
        $Item = New-Object PSObject
    }
    PROCESS {

        $Lines | %{
            #An empty line means its a new item
            if([string]::IsNullOrWhiteSpace($_)){
                #Add Item to Array only if its not empty
                if(($Item|Get-Member -Type NoteProperty).count -gt 0){
                    $ArrayOutput += $Item
                    $Item = New-Object PSObject
                }
            }
            if($_ -match "^\s*((?:[\w\[\]]\s?)+)\s+:\s(.*)"){
                $Name = $Matches[1].trimend()
                $Value = $Matches[2]

                if($Name -eq "Object name" -and !$FullObjectName){
                    $Value = [regex]::Match($Value, '^(.+):.*').groups[1].value
                }

                #Convert values to correct type
                if($Name -match "^.*(Time|Started|Finished).*$"){
                    $Value = $Value
                } elseif($Name -match "^.*(Number).*$"){
                    $Value = ConvertTo-Int($Value)
                } elseif($Value -match "^(\d+)\sKB"){
                    $Name = $Name + " (GB)"
                    $Value = ConvertTo-Int($Matches[1]/1024/1024)
                } elseif($Name -match "^(.*)\s\[KB.*"){
                    $Name = $Matches[1] + " (GB)"
                    $Value = ConvertTo-Int($Value/1024/1024)
                }
                $Item | Add-Member -type NoteProperty -Name $Name -Value $Value

            }
        }
    }
    END {
        $ArrayOutput += $Item
        return $ArrayOutput | Select-Object *
    }
}
