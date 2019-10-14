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

    $SourceRegistryPostfixed = $SourceRegistry
    $TargetRegistryPostfixed = $TargetRegistry

    # Add postfix /
    if (-Not ([String]::IsNullOrWhiteSpace($SourceRegistry))) {
        $SourceRegistryPostfixed = Add-Postfix -Data $SourceRegistry
    }
    if (-Not ([String]::IsNullOrWhiteSpace($TargetRegistry))) {
        $TargetRegistryPostfixed = Add-Postfix -Data $TargetRegistry
    }

    $source = "${SourceRegistryPostfixed}${SourceImage}:${SourceTag}"
    $target = "${TargetRegistryPostfixed}${TargetImage}:${TargetTag}"
    Invoke-Command "docker tag ${source} ${target}"
}
