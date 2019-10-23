function Format-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Dockerfile = './Dockerfile'
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

    $archPath = Split-Path -Parent -Path $pathToDockerFile
    $distroPath = Split-Path -Parent -Path $archPath
    $versionPath = Split-Path -Parent -Path $distroPath

    $result = [PSCustomObject]@{
        'Dockerfile' = $pathToDockerFile
        'Arch'       = $(Split-Path -Leaf -Path $archPath)
        'Distro'     = $(Split-Path -Leaf -Path $distroPath)
        'Version'    = $(Split-Path -Leaf -Path $versionPath)
        'Tag'        = ''
    }
    $result.Tag = $result.Version + '-' + $result.Distro + '-' + $result.Arch
    return $result
}
