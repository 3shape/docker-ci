function Find-DockerOSType {
    $commandResult = Invoke-Command "docker info --format '{{.OSType}}'"
    Assert-ExitCodeOk $commandResult
    $commandResult.Output
}
