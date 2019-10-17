. "$PSScriptRoot\..\Private\Utilities.ps1"

function Invoke-DockerPush {
    [CmdletBinding()]
    param (
        [ValidateNotNull()]
        [string]
        $Registry = '',

        [Parameter(Mandatory = $true)]
        [string]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [string]
        $Tag = 'latest'
    )
    $postfixedRegistry = Add-PostFix $Registry
    $command = "docker push ${postfixedRegistry}${ImageName}:${Tag}"
    Invoke-Command $command
}
