function Format-AsAbsolutePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $path
    )
    if ([System.IO.Path]::IsPathRooted($path)) {
        return $path
    }

    $here = Get-Location
    $combinedPath = Join-Path $here $path
    return [System.IO.Path]::GetFullPath($combinedPath)
}
