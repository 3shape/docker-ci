function Invoke-DockerBuild {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [String]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [String]
        $Context = ".",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = "latest",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Dockerfile = "Dockerfile"

    )
    $postfixedRegistry = Add-Postfix -Value $Registry
    $commandResult = Invoke-Command "docker build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${Dockerfile}`""
    Assert-ExitCodeOK $commandResult
    $result = [PSCustomObject]@{
        "Dockerfile"    = $Dockerfile;
        "ImageName"     = $ImageName;
        'Registry'      = $postfixedRegistry;
        'Tag'           = $Tag;
        "CommandResult" = $commandResult
    }
    return $result
}
