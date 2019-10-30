
function Test-IsSubdirectoryOf {
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true)]
        [String]
        $ParentPath,

        [Parameter(mandatory = $true)]
        [String]
        $ChildPath
    )
    $absolutePath = Format-AsAbsolutePath $ParentPath
    $absoluteChildPath = Format-AsAbsolutePath $ChildPath

    return (Test-Path $absolutePath -PathType Container) -and
    (Test-Path $absoluteChildPath -PathType Container) -and
    $absoluteChildPath.StartsWith($absolutePath)
}
