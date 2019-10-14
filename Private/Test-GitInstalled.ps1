function Test-GitInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $GitCommand = 'git --version'
    )
    Invoke-Command $GitCommand
}
