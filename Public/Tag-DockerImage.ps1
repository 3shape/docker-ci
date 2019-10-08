#Requires -PSEdition Core -Version 6

function Tag-DockerImage {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $Image,
        [ValidateNotNullOrEmpty()]
        [String] $Tag
    )


}
