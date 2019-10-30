function Invoke-DockerBuild {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Context = ".",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = "latest",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Dockerfile = "Dockerfile",

        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru
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
    if ($PassThru) {
        Write-Host $commandResult.Output
    }
    return $result
}
