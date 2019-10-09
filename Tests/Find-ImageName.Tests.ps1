Import-Module -Force $PSScriptRoot/../Docker.Build.psm1

Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        It 'can find a repository origin' {
            $repositoryBasePath = (Split-Path -Parent $PSScriptRoot)
            $result = Find-ImageName -RepositoryPath $repositoryBasePath
            $result | Should -BeExactly "dockerbuild-pwsh"
        }
    }
}
