#Requires -PSEdition Core -Version 6

function Test-GitInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $GitCommand = 'git --version'
    )

    Invoke-Command $GitCommand
}
