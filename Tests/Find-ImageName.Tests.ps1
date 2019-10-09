Import-Module -Force $PSScriptRoot/../Docker.Build.psm1

Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        It 'can find a repository origin' {
            $repositoryBasePath = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data/Repositories/NoSpace"
            $result = Find-ImageName -RepositoryPath $repositoryBasePath
            $result | Should -BeExactly "dockerbuild-pwsh"
        }

        It 'can find a repository origin with folder with space' {
            $repositoryBasePath = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data/Repositories/With Space"
            $result = Find-ImageName -RepositoryPath $repositoryBasePath
            $result | Should -BeExactly "dockerbuild-pwsh"
        }
    }
}
