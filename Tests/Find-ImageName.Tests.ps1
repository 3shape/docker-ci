Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Utilities.ps1"

Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        BeforeAll {
            $tempFolder = New-RandomFolder
        }

        AfterAll {
            Remove-Item $tempFolder -Recurse -Force | Out-Null
        }

        It 'can find a repository origin' {
            $gitRepoNoSpace = Join-Path $tempFolder "NoSpace"
            New-FakeGitRepository -Path $gitRepoNoSpace
            $result = Find-ImageName -RepositoryPath $gitRepoNoSpace
            $result | Should -BeExactly "dockerbuild-pwsh"
        }

        It 'can find a repository origin with folder with space' {
            $gitRepoWithSpace = Join-Path $tempFolder "With Space"
            New-FakeGitRepository -Path $gitRepoWithSpace
            $result = Find-ImageName -RepositoryPath $gitRepoWithSpace
            $result | Should -BeExactly "dockerbuild-pwsh"
        }
    }
}
