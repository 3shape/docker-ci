function Find-ImageName {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $RepositoryPath
    )
    $gitConfigPath = Join-Path "$RepositoryPath" ".git" "config"
    $gitConfigExists = $(Test-Path $gitConfigPath)
    if (!$gitConfigExists) {
        throw "No such git config: $gitConfigExists"
    }
    $commandResult = Invoke-Command "git config --file `"$gitConfigPath`" --get remote.origin.url"
    Assert-ExitCodeOK $commandResult
    $imageName = (Find-RepositoryName -RepositoryPath $commandResult.Output[0]).ToLower()
    $result = [PSCustomObject]@{
        'ImageName' = $imageName
    }
    return $result
}
