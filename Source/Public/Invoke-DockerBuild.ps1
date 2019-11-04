. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

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

        [String]
        $ExtraParams = '',

        [Switch]
        $PassThru
    )
    $postfixedRegistry = Add-Postfix -Value $Registry
    if (![String]::IsNullOrEmpty($ExtraParams)) {
        $extraParameters = ' ' + $ExtraParams
    }
    $dockerBuildCommand = "docker build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${Dockerfile}`"" + $extraParameters
    $commandResult = Invoke-Command $dockerBuildCommand
    Assert-ExitCodeOK $commandResult
    $result = [PSCustomObject]@{
        'Dockerfile'    = $Dockerfile;
        'ImageName'     = $ImageName;
        'Registry'      = $postfixedRegistry;
        'Tag'           = $Tag;
        'CommandResult' = $commandResult
    }
    if ($PassThru) {
        Write-PassThruOuput $($commandResult.Output)
    }
    return $result
}
