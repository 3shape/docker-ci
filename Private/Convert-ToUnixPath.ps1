function Convert-ToUnixPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Path
    )

    return $Path.Replace('\', '/')
}
