
function Test-DockerDigest {
    param (
        [Parameter(Mandatory=$true)]
        [String] $Digest
    )

    $shaPrefix = 'sha256:'
    $shaLength = 64
    return $Digest.StartsWith($shaPrefix) -and $Digest.Length -eq ($shaPrefix.Length + $shaLength)
}
