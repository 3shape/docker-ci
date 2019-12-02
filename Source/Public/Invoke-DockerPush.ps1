. "$PSScriptRoot\..\Private\Utilities.ps1"
. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerPush {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )
    $postfixedRegistry = Add-PostFix $Registry
    $args = "push ${postfixedRegistry}${ImageName}:${Tag}"
    $commandResult = Invoke-DockerCommand $args
    Assert-ExitCodeOk $commandResult
    $result = [PSCustomObject]@{
        'CommandResult' = $commandResult;
        'ImageName'     = $ImageName;
        'Registry'      = $postfixedRegistry;
        'Tag'           = $Tag;
    }
    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }
    return $result
}
