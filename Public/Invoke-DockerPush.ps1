. "$PSScriptRoot\..\Private\Utilities.ps1"

function Invoke-DockerPush {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [String]
        $Registry = '',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest'
    )
    $postfixedRegistry = Add-PostFix $Registry
    $command = "docker push ${postfixedRegistry}${ImageName}:${Tag}"
    $commandResult = Invoke-Command $command
    $result = [PSCustomObject]@{
        'Result'    = $commandResult;
        'ImageName' = $ImageName;
        'Registry'  = $postfixedRegistry;
        'Tag'       = $Tag;
    }
    Assert-ExitCodeOk $commandResult
    return $result
}
