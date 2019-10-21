function Invoke-DockerPull {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        # Pull by name, by name + tag, by name + digest
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageOnly')]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndDigest')]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndTag')]
        [String]
        $ImageName,

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndTag')]
        [String]
        $Tag = 'latest',

        [ValidateNotNullOrEmpty()]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndDigest')]
        [String]
        $Digest = ''
    )

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
    try {
        $result = Invoke-Command "docker pull ${imageToPull}"
    }
    catch {
        if ($result.Exitcode -ne 0) {
            $message = "An error occured during docker pull, the error message was: $result.Output"
            throw $message
        }
    }
    return $result
}
