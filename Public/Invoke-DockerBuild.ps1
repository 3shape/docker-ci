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
        $Dockerfile = "Dockerfile"

    )
    $postfixedRegistry = Add-Postfix -Value $Registry
    $commandResult = Invoke-Command "docker build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${Dockerfile}`""
    $result = [PSCustomObject]@{
        "Dockerfile" = $Dockerfile;
        "ImageName" = $ImageName;
        'Registry' = $Registry;
        "CommandResult" = $commandResult
    }
    $result
}
