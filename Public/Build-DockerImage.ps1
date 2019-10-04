#Requires -PSEdition Core -Version 6

function Build-DockerImage {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $Image,
        [ValidateNotNullOrEmpty()]
        [String] $Tag
    )

    Ensure-DockerInstalled
    Ensure-GitInstalled

}
