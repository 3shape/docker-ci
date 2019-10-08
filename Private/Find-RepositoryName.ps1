function Find-RepositoryName {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryPath
    )
    $ReposNameStart = $RepositoryPath.IndexOf('/') + 1
    $ReposNameEnd = $RepositoryPath.LastIndexOf(".git")
    $ReposNameLength = $ReposNameEnd - $ReposNameStart
    $RepositoryPath.Substring($ReposNameStart, $ReposNameLength)
}
