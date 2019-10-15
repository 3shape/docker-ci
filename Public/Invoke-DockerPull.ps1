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

    $registryPostfixed = Add-Postfix -Registry $Registry

    # Pulls by tag by default
    $imageToPull = "${registryPostfixed}${Image}:${Tag}"

    # Digest overrides tag however
    if (-Not [String]::IsNullOrEmpty($Digest)) {
        $validDigest = Test-DockerDigest -Digest $Digest
        if (-Not $validDigest) {
            throw "Invalid digest provided, digest: ${Digest}"
        }
        $imageToPull = "${registryPostfixed}${Image}@${Digest}"
    }
    Invoke-Command "docker pull ${imageToPull}"
}
