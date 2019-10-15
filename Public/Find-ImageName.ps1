function Find-ImageName {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $RepositoryPath
    )
    $gitConfigPath = Join-Path "$RepositoryPath" ".git" "config"
    $gitConfigExists = $(Test-Path $gitConfigPath)
    if (!$gitConfigExists)
    {
        throw "No such git config: $gitConfigExists"
    }
    $result = Invoke-Command "git config --file `"$gitConfigPath`" --get remote.origin.url"
    (Find-RepositoryName -RepositoryPath $result.Output).ToLower()
}
