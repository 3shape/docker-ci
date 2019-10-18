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
        $message = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($message)
    }

    $directoryToDockerfile = (Get-Item -Path $pathToDockerFile).Directory
    $isDockerfileInContextRoot = Test-IsSubdirectoryOf -Path $ContextRoot -ChildPath $directoryToDockerfile.FullName
    if (!$isDockerfileInContextRoot) {
        $message = "Cannot find the Dockerfile in $ContextRoot."
        throw [System.ArgumentException]::new($message)
    }

    try {
        Push-Location -Path $ContextRoot
        $relativePathToDockerfile = Resolve-Path -Path $pathToDockerFile -Relative
    }
    finally {
        Pop-Location
    }

    $parentDirCount = (Split-Path -Parent $relativePathToDockerfile).Split([IO.Path]::DirectorySeparatorChar).Length - 1
    if ($parentDirCount -lt 3) {
        throw "The parent directory structure of the Dockerfile cannot be parsed into a valid docker tag, full path to Dockerfile: ${pathToDockerFile}"
    }
    $result = [DockerTagInfo]::new()
    $archPath = Split-Path -Parent -Path $pathToDockerFile
    $distroPath = Split-Path -Parent -Path $archPath
    $versionPath = Split-Path -Parent -Path $distroPath
    $result.Arch = Split-Path -Leaf -Path $archPath
    $result.Distro = Split-Path -Leaf -Path $distroPath
    $result.Version = Split-Path -Leaf -Path $versionPath
    $result.Tag = $result.Version + '-' + $result.Distro + '-' + $result.Arch
    $result
}
