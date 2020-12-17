function Convert-ToDockerHostPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Path
    )

    $pathOnDockerHost = $Path
    $commandResultPS = Invoke-DockerCommand 'ps' -Quiet
    Assert-ExitCodeOK $commandResultPS

    if ( ($commandResultPS).StdOut | Select-String $(hostname) ) {
        # executed inside docker container $(hostname)
        $dockerCommand = "inspect -f ""{{ range .Mounts }}{{ .Source }}={{ .Destination }}{{ println }} {{ end }}"" $(hostname)"
        $commandResultInspect = Invoke-DockerCommand $dockerCommand -Quiet
        Assert-ExitCodeOK $commandResultInspect

        $mounts = ($commandResultInspect).StdOut.trim() | Where-Object { $_ -NotMatch "/var/lib/docker" -and $_ -NotMatch "docker.sock" -and $_ -NotMatch "\\pipe\\" -and $_ -ne '' }

        if ($mounts.Length -gt 0) {
            $mounts | ForEach-Object {
                if ($_.split('=')[0] -ne $_.split('=')[1]) {
                    # Replace container path with host path
                    $pathOnDockerHost = $pathOnDockerHost.Replace($_.split('=')[1], $_.split('=')[0])
                }
            }
        }
    }
    return $pathOnDockerHost
}
