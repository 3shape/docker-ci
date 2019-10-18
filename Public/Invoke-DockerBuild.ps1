function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
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
    Invoke-Command "docker build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${File}`""
}
