function Find-DockerOSType {
    $commandResult = Invoke-DockerCommand 'info --format "{{.OSType}}"'
    Assert-ExitCodeOk $commandResult
    return $commandResult.Output
}
