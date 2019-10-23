function Format-AsAbsolutePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Path
    )
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    $here = Get-Location
    $combinedPath = Join-Path $here $Path
    return [System.IO.Path]::GetFullPath($combinedPath)
}
