function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [Parameter(mandatory=$true)]
        [String]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [ValidateNotNullOrEmpty()]
        [String]
        $NewRegistry,

        [Parameter(mandatory=$true)]
        [String]
        $NewImageName,

        [ValidateNotNullOrEmpty()]
        [String]
        $NewTag = 'latest'
    )

    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedNewRegistry = Add-Postfix -Value $NewRegistry
    $source = "${postfixedRegistry}${ImageName}:${Tag}"
    $target = "${postfixedNewRegistry}${NewImageName}:${NewTag}"

    Invoke-Command "docker tag ${source} ${target}"
}
