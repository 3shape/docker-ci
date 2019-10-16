function Invoke-DockerPull {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [ValidateNotNullOrEmpty()]
        [String]
        $Repository,

        # Pull by name, by name + tag, by name + digest
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageOnly')]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndDigest')]
        [Parameter(mandatory = $true,ParameterSetName = 'WithImageAndTag')]
        [String]
        $Image,

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
    $postfixedRepository = Add-Postfix -Value $Repository

    # Pulls by tag by default
    $imageToPull = "${postfixedRegistry}${postfixedRepository}${Image}:${Tag}"

    # Digest overrides tag however
    if (-Not [String]::IsNullOrEmpty($Digest)) {
        $validDigest = Test-DockerDigest -Digest $Digest
        if (-Not $validDigest) {
            throw "Invalid digest provided, digest: ${Digest}"
        }
        $imageToPull = "${postfixedRegistry}${postfixedRepository}${Image}@${Digest}"
    }
    Invoke-Command "docker pull ${imageToPull}"
}
