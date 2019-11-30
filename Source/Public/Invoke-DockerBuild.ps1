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

        [ValidateNotNullOrEmpty()]
        [String]
        $ExtraParams = '',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )
    $postfixedRegistry = Add-Postfix -Value $Registry
    if ($ExtraParams) {
        $extraParameters = " ${ExtraParams}"
    }
    $dockerBuildCommand = "docker"
    $dockerBuildCommandArgs = "build `"${Context}`" -t ${postfixedRegistry}${ImageName}:${Tag} -f `"${Dockerfile}`"${extraParameters}"
    $commandResult = Invoke-DockerCommand -CommandArgs $dockerBuildCommandArgs
    Assert-ExitCodeOK $commandResult
    $result = [PSCustomObject]@{
        'Dockerfile'    = $Dockerfile;
        'ImageName'     = $ImageName;
        'Registry'      = $postfixedRegistry;
        'Tag'           = $Tag;
        'CommandResult' = $commandResult
    }
    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }
    return $result
}
