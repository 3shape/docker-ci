function Get-RepositoryName {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $FullRepositoryName
    )

    $ReposNameStart = $FullRepositoryName.IndexOf('/') + 1
    $ReposNameEnd = $FullRepositoryName.LastIndexOf(".git")
    $ReposNameLength = $ReposNameEnd - $ReposNameStart

    $result = $FullRepositoryName.Substring($ReposNameStart, $ReposNameLength)
    $result
}
