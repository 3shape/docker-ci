Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1

. "$PSScriptRoot\..\Source\Private\Find-RepositoryName.ps1"

Describe 'Parse repos name from full git repository' {

    Context 'When full git scheme URL is specified' {

        It 'The repository name can be deduced' {
            $result = Find-RepositoryName -RepositoryPath "git@github.com:3shapeAS/jenkinsapi-powershell.git"
            $result | Should -BeExactly "jenkinsapi-powershell"
        }
    }

    Context 'When full https scheme URL is specified' {
        It 'The repository name can be deduced' {
            $result = Find-RepositoryName -RepositoryPath "https://github.com/3shapeAS/dockerbuild-pwsh.git"
            $result | Should -BeExactly "dockerbuild-pwsh"
        }
    }
}
