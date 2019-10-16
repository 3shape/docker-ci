function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceRegistry,

        [ValidateNotNullOrEmpty()]
        [String]
        $SourceRepository,

        [Parameter(mandatory=$true)]
        [String]
        $SourceImage,

        [ValidateNotNullOrEmpty()]
        [String]
        $SourceTag = 'latest',

        [ValidateNotNullOrEmpty()]
        [String]
        $TargetRegistry,

        [ValidateNotNullOrEmpty()]
        [String]
        $TargetRepository,

        [Parameter(mandatory=$true)]
        [String]
        $TargetImage,

        [ValidateNotNullOrEmpty()]
        [String]
        $TargetTag = 'latest'
    )

    $postfixedSourceRegistry = Add-Postfix -Value $SourceRegistry
    $postfixedTargetRegistry = Add-Postfix -Value $TargetRegistry
    $postfixedSourceRepository = Add-Postfix -Value $SourceRepository
    $postfixedTargetRepository = Add-Postfix -Value $TargetRepository
    $source = "${postfixedSourceRegistry}${postfixedSourceRepository}${SourceImage}:${SourceTag}"
    $target = "${postfixedTargetRegistry}${postfixedTargetRepository}${TargetImage}:${TargetTag}"

    Invoke-Command "docker tag ${source} ${target}"
}
