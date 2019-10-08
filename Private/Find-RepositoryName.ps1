function Find-RepositoryName {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryPath
    )
    $ReposNameStart = $RepositoryPath.LastIndexOf('/') + 1
    $ReposNameEnd = $RepositoryPath.LastIndexOf(".git")
    $ReposNameLength = $ReposNameEnd - $ReposNameStart
    $RepositoryPath.Substring($ReposNameStart, $ReposNameLength)
}
