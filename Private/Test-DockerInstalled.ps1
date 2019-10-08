#Requires -PSEdition Core -Version 6

function Test-DockerInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $DockerCommand = 'docker'
    )

    $dockerCommand = @($DockerCommand)
    Invoke-Commands $dockerCommand
}
