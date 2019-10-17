function Format-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $ContextRoot,

        [Parameter(Mandatory=$true)]
        [string]
        $Dockerfile
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = [System.IO.File]::Exists($pathToDockerFile)
    if (!$dockerFileExists) {
        $mesage = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($mesage)
    }
    $parentDirCount = (Split-Path -Parent $pathToDockerFile).Split([IO.Path]::DirectorySeparatorChar).Length
    if ($parentDirCount -lt 3) {
        throw "The parent directory structure cannot be parsed into a valid docker tag, full path: ${pathToDockerFile}"
    }
    $result = [DockerTagInfo]::new()
    $archPath = Split-Path -Parent -Path $pathToDockerFile
    $distroPath = Split-Path -Parent -Path $archPath
    $versionPath = Split-Path -Parent -Path $distroPath
    $result.Arch = Split-Path -Leaf -Path $archPath
    $result.Distro = Split-Path -Leaf -Path $distroPath
    $result.Version = Split-Path -Leaf -Path $versionPath
    $result
}
