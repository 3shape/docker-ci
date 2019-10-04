Import-Module -Force -Name (Get-ChildItem $PSScriptRoot\..\*.psm1 | Select-Object -first 1).FullName
Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        It 'can find a repository origin' {
            $repositoryBasePath = (Split-Path -Parent $PSScriptRoot)
            $result = Parse-ImageName -RepositoryPath ($repositoryBasePath)
            $result | Should -BeExactly "dockerbuild-pwsh"
        }
    }
}
