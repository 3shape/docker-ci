#Requires -PSEdition Core -Version 6

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

    $gitCommand = @("git config --file $gitConfigPath --get remote.origin.url")

    $fullReposUrl = Invoke-Commands -Commands $gitCommand
    Find-RepositoryName -RepositoryPath $fullReposUrl
}
