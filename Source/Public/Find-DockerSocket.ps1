function Find-DockerSocket {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $OsType = (Find-DockerOSType)
    )

    if ($osType -ieq 'windows') {
        '\\.\pipe\docker_engine'
    } elseif ($osType -ieq 'linux') {
        '/var/run/docker.sock'
    } else {
        throw "'$OsType' not supported"
    }
}
