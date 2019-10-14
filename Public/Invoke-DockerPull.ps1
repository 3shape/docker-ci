function Invoke-DockerPull {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,
        [Parameter(mandatory=$true)]
        [String]
        $Image,
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',
        [ValidateNotNullOrEmpty()]
        [String]
        $Digest = ''
    )

    $RegistryPostfixed = Add-RegistryPostfix -Registry $Registry

    # Pulls by tag by default
    $ImageToPull = "${RegistryPostfixed}${Image}:${Tag}"

    # Digest overrides tag however
    if (-Not [String]::IsNullOrEmpty($Digest)) {
        $validDigest = Test-DockerDigest -Digest $Digest
        if (-Not $validDigest) {
            throw "Invalid digest provided."
        }
        $ImageToPull = "${RegistryPostfixed}${Image}@${Digest}"
    }
    Invoke-Command "docker pull ${ImageToPull}"
}
