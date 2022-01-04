function Find-DockerOSType {
    if ($script:CachedDockerInformation['OSType']) {
        return $script:CachedDockerInformation['OSType']
    } else {
        $commandResult = Invoke-DockerCommand 'info --format "{{.OSType}}"'
        Assert-ExitCodeOk $commandResult
        $script:CachedDockerInformation['OSType'] = $commandResult.Output
        return $commandResult.Output
    }
}
