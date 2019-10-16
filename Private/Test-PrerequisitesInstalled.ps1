function Test-PrerequisitesInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $GitCommand = 'git --version',

        [ValidateNotNullOrEmpty()]
        [String] $DockerCommand = 'docker'
    )
    Test-GitInstalled -GitCommand $GitCommand
    Test-DockerInstalled -DockerCommand $DockerCommand
}
