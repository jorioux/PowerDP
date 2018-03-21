#check if the omnirpt command is available
if (!(Get-Command omnirpt -ErrorAction SilentlyContinue)){
    Write-Warning '[PowerDP] omnirpt.exe command not found on this system'
    Write-Warning '[PowerDP] This module might not work without Omniback'
}