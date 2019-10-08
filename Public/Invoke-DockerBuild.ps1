#Requires -PSEdition Core -Version 6

function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
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

    $dockerCommand = @("docker build ${Context} -t ${Image}:${Tag} -f ${File}")
    Invoke-Commands -Commands $dockerCommand

}
