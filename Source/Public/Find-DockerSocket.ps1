function Find-DockerSocket {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $OsType = (Find-DockerOSType)
    )

    $osType = $OsType.ToLower()
    if ($osType -eq 'windows') {
        '\\.\pipe\docker_engine'
    } elseif ($osType -eq 'linux') {
        '/var/run/docker.sock'
    } else {
        throw "'$osType' not supported"
    }
}
