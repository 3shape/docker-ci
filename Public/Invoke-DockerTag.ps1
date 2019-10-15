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

    $SourceRegistryPostfixed = Add-RegistryPostfix -Registry $SourceRegistry
    $TargetRegistryPostfixed = Add-RegistryPostfix -Registry $TargetRegistry
    $source = "${SourceRegistryPostfixed}${SourceImage}:${SourceTag}"
    $target = "${TargetRegistryPostfixed}${TargetImage}:${TargetTag}"

    Invoke-Command "docker tag ${source} ${target}"
}
