#Requires -PSEdition Core -Version 6

function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [String]
        $SourceRegistry = '',
        [Parameter(mandatory=$true)]
        [String]
        $SourceImage,
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceTag = 'latest',
        [String]
        $TargetRegistry = '',
        [Parameter(mandatory=$true)]
        [String]
        $TargetImage,
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetTag = 'latest'
    )

    # Add postfix /
    if (-Not ([String]::IsNullOrWhiteSpace($SourceRegistry))) {
        $SourceRegistry = Ensure-Postfix -Data $SourceRegistry
    }
    if (-Not ([String]::IsNullOrWhiteSpace($TargetRegistry))) {
        $TargetRegistry = Ensure-Postfix -Data $TargetRegistry
    }

    $source = "${SourceRegistry}${SourceImage}:${SourceTag}"
    $target = "${TargetRegistry}${TargetImage}:${TargetTag}"
    Invoke-Command "docker tag ${source} ${target}"
}
