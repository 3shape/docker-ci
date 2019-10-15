. "$PSScriptRoot\..\Private\Utilities.ps1"

function Invoke-DockerPush {
    [CmdletBinding()]
    param (
        [ValidateNotNull()]
        [string]
        $Registry = '',
        [ValidateNotNull()]
        [string]
        $Repository = '',
        [string]
        $ImageName,
        [ValidateNotNullOrEmpty()]
        [string]
        $Tag = 'latest'
    )
    $postfixedRegistry = Add-PostFix $Registry
    $postfixedRepository = Add-Postfix $Repository
    $command = "docker push ${postfixedRegistry}${postfixedRepository}${ImageName}:${Tag}"
    Invoke-Command $command
}
