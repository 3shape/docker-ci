. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerPull {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        # Pull by name, by name + tag, by name + digest
        [Parameter(mandatory = $true, ParameterSetName = 'WithImageOnly', ValueFromPipelineByPropertyName = $true)]
        [Parameter(mandatory = $true, ParameterSetName = 'WithImageAndDigest', ValueFromPipelineByPropertyName = $true)]
        [Parameter(mandatory = $true, ParameterSetName = 'WithImageAndTag', ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true, ParameterSetName = 'WithImageAndTag', ValueFromPipelineByPropertyName = $true)]
        [String]
        $Tag = 'latest',

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true, ParameterSetName = 'WithImageAndDigest')]
        [String]
        $Digest = '',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)

    )

    if ($ImageName.Contains(':') -or $ImageName.Contains('@')) {
        throw [System.ArgumentException]::new('Image name cannot contain colon or at-sign.')
    }

    $postfixedRegistry = Add-Postfix -Value $Registry

    # Pulls by tag by default
    $imageToPull = "${postfixedRegistry}${ImageName}:${Tag}"

    # Digest cannot be used together with Tag
    if (-Not [String]::IsNullOrEmpty($Digest)) {
        $validDigest = Test-DockerDigest -Digest $Digest
        if (-Not $validDigest) {
            throw "Invalid digest provided, digest: ${Digest}"
        }
        $imageToPull = "${postfixedRegistry}${ImageName}@${Digest}"
    }

    $commandResult = Invoke-Command "docker pull ${imageToPull}"
    Assert-ExitCodeOk $commandResult
    $result = [PSCustomObject]@{
        'CommandResult' = $commandResult
        'ImageName'     = $ImageName
        'Tag'           = $Tag
        'Registry'      = $postfixedRegistry
        'Digest'        = $Digest
    }
    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }
    return $result
}
