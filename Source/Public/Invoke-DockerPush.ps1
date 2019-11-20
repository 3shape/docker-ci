. "$PSScriptRoot\..\Private\Utilities.ps1"
. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerPush {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_POSH_QUIET_MODE)
    )
    $postfixedRegistry = Add-PostFix $Registry
    $command = "docker push ${postfixedRegistry}${ImageName}:${Tag}"
    $commandResult = Invoke-Command $command
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
