#Requires -PSEdition Core -Version 6

function Test-GitInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $GitCommand = 'git --version'
    )

    $gitCommand = @($GitCommand)
    Invoke-Commands $gitCommand
}
