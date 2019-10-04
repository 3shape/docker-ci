#Requires -PSEdition Core -Version 6

function Ensure-DockerInstalled {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $DockerBinaryName = 'docker'
    )


    $dockerCommand = @( $DockerBinaryName + " -v")
    Run-Commands $dockerCommand
}
