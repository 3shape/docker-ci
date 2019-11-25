function Find-DockerSocket {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $OsType = (Find-DockerOSType)
    )

    if ($OsType -ieq 'windows') {
        return '\\.\pipe\docker_engine'
    } elseif ($OsType -ieq 'linux') {
        return '/var/run/docker.sock'
    } else {
        throw "'$OsType' not supported"
    }
}
