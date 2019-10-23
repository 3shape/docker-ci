function Find-RepositoryName {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $RepositoryPath
    )
    $ReposNameStart = $RepositoryPath.LastIndexOf('/') + 1
    $ReposNameEnd = $RepositoryPath.LastIndexOf(".git")
    $ReposNameLength = $ReposNameEnd - $ReposNameStart
    return $RepositoryPath.Substring($ReposNameStart, $ReposNameLength)
}
