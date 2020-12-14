function Convert-ToDockerHostPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Path
    )

    $pathOnDockerHost = $Path
    if ( (Invoke-DockerCommand 'ps' -Quiet).StdOut | Select-String $(hostname) ) { 
        # executed inside docker container $(hostname)
        $dockerCommand = "inspect -f ""{{ range .Mounts }}{{ .Source }}={{ .Destination }}{{ println }} {{ end }}"" $(hostname)"
        $mounts = (Invoke-DockerCommand $dockerCommand -Quiet).StdOut.trim() | Where-Object {  $_ -NotMatch "/var/lib/docker" -and $_ -NotMatch "docker.sock" -and $_ -NotMatch "\\pipe\\" -and $_ -ne '' }
        if ($mounts) {
            $mounts | ForEach-Object {
                if ($_.split('=')[0] -ne $_.split('=')[1]) {
                    # Replace container path with host path
                    $pathOnDockerHost = $pathOnDockerHost.Replace($_.split('=')[1],$_.split('=')[0])
                }
            }
        }
    }
    return $pathOnDockerHost
}
