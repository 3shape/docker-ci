#Requires -PSEdition Core -Version 6

function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [String]
        $Image,
        [ValidateNotNullOrEmpty()]
        [String]
        $Context = ".",
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = "latest",
        [ValidateNotNullOrEmpty()]
        [String]
        $File = "Dockerfile"

    )
    Invoke-Command "docker build `"${Context}`" -t ${Image}:${Tag} -f `"${File}`""
}
