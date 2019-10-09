#Requires -PSEdition Core -Version 6

function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [String]
        $SourceImage,
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceTag = 'latest',
        [Parameter(mandatory=$true)]
        [String]
        $TargetImage,
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetTag = 'latest'
    )

    $dockerCommand = @("docker tag ${SourceImage}:${SourceTag} ${TargetImage}:${TargetTag}")
    Invoke-Commands -Commands $dockerCommand

}
