function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [ValidateNotNullOrEmpty()]
        [String]
        $Repository,

        [Parameter(Mandatory = $true)]
        [String]
        $ImageName,

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
    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedRepository = Add-Postfix -Value $Repository
    Invoke-Command "docker build `"${Context}`" -t ${postfixedRegistry}${postfixedRepository}${ImageName}:${Tag} -f `"${File}`""
}
