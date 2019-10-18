function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
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
    $commandResult = Invoke-Command "docker build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${File}`""
    $result = [PSCustomObject]@{
        "Dockerfile" = $File;
        "ImageName" = $ImageName;
        "CommandResult" = $commandResult
    }
    $result
}
