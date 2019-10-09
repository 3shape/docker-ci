function Test-DockerInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $DockerCommand = 'docker'
    )

    Invoke-Command $DockerCommand
}
