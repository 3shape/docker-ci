function Invoke-DockerPull {
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry = $global:DockerPublicRegistry,

        # Pull by name, by name + tag, by name + digest
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageOnly', ValueFromPipelineByPropertyName = $true)]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndDigest', ValueFromPipelineByPropertyName = $true)]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndTag', ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndTag', ValueFromPipelineByPropertyName = $true)]
        [String]
        $Tag = 'latest',

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndDigest')]
        [String]
        $Digest = ''
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
    if ($commandResult.Exitcode -ne 0) {
        $message = "An error occured during docker pull. The error message was: ${commandResult.Output}, the exit code was: ${commandResult.Exitcode}"
        Write-Debug "${message}"
        throw "${message}"
    }
    $result = [PSCustomObject]@{
        'Result' = $commandResult
        'ImageName' = $ImageName
        'Tag' = $Tag
        'Registry' = $postfixedRegistry
        'Digest' = $Digest
    }
    return $result
}
