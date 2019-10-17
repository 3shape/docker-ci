function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceRegistry,

        [Parameter(mandatory=$true)]
        [String]
        $SourceImageName,

        [ValidateNotNullOrEmpty()]
        [String]
        $SourceTag = 'latest',

        [ValidateNotNullOrEmpty()]
        [String]
        $TargetRegistry,

        [Parameter(mandatory=$true)]
        [String]
        $TargetImageName,

        [ValidateNotNullOrEmpty()]
        [String]
        $TargetTag = 'latest'
    )

    $postfixedSourceRegistry = Add-Postfix -Value $SourceRegistry
    $postfixedTargetRegistry = Add-Postfix -Value $TargetRegistry
    $source = "${postfixedSourceRegistry}${SourceImageName}:${SourceTag}"
    $target = "${postfixedTargetRegistry}${TargetImageName}:${TargetTag}"

    Invoke-Command "docker tag ${source} ${target}"
}
