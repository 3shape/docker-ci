
function Test-IsSubdirectoryOf {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [String]
        $Path,

        [Parameter(mandatory=$true)]
        [String]
        $ChildPath
    )
    $absolutePath = Format-AsAbsolutePath $Path
    $absoluteChildPath = Format-AsAbsolutePath $ChildPath

    (Test-Path $absolutePath -PathType Container) -and
    (Test-Path $absoluteChildPath -PathType Container) -and
    $absoluteChildPath.StartsWith($absolutePath)
}
