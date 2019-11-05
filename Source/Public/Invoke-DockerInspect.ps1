. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerInspect {
    [CmdletBinding(PositionalBinding = $false)]
    param (
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

        [Switch]
        $PassThru
    )
    $postfixedRegistry = Add-Postfix -Value $Registry
    $dockerInspectCommand = "docker inspect ${postfixedRegistry}${ImageName}:${Tag}"
    $commandResult = Invoke-Command $dockerInspectCommand
    Assert-ExitCodeOK $commandResult
    $result = [PSCustomObject]@{
        'Registry'      = $postfixedRegistry;
        'ImageName'     = $ImageName;
        'Tag'           = $Tag;
        'CommandResult' = $commandResult
    }
    if ($PassThru) {
        Write-PassThruOuput $($commandResult.Output)
    }
    return $result
}
