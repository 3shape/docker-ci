Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1

. "$PSScriptRoot\..\Source\Private\Utilities.ps1"
. "$PSScriptRoot\New-RandomFolder.ps1"

Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        BeforeAll {
            $tempFolder = New-RandomFolder
        }

        AfterAll {
            Remove-Item $tempFolder -Recurse -Force | Out-Null
        }

        BeforeEach {
            Initialize-MockReg
        }

        It 'can find a repository origin' {
            $noSpacePath = Join-Path $tempFolder "NoSpace"
            New-FakeGitRepository -Path $noSpacePath
            $result = Find-ImageName -RepositoryPath $noSpacePath
            $result.ImageName | Should -BeExactly "dockerbuild-pwsh"
        }

        It 'can find a repository origin with folder with space' {
            $gitRepoWithSpace = Join-Path $tempFolder "With Space"
            New-FakeGitRepository -Path $gitRepoWithSpace
            $result = Find-ImageName -RepositoryPath $gitRepoWithSpace
            $result.ImageName | Should -BeExactly "dockerbuild-pwsh"
        }

        It 'can identify an invalid repository, .git folder without config file' {
            $gitRepoNoConfig = Join-Path $tempFolder "NoSpace" '.git'
            New-Item $gitRepoNoConfig -ItemType Container -Force
            $code = { Find-ImageName -RepositoryPath $gitRepoNoConfig }
            $code | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -PassThru
        }

        It 'lowercases the repository names' {
            $gitReposWithUppercase = Join-Path $tempFolder 'ThisIsNotUsefulAsAnImageName'
            New-FakeGitRepository -Path $gitReposWithUppercase
            $mockCode = {
                $invocationResult = [CommandResult]::new();
                $invocationResult.Output = "https://github.com/3shapeAS/DOCKERBUILD-pwsh.git"
                $invocationResult
            }
            Mock -CommandName "Invoke-Command" $mockCode -Verifiable -ModuleName $Global:ModuleName

            $result = Find-ImageName -RepositoryPath $gitReposWithUppercase

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $Global:ModuleName -Exactly 1
            $result.ImageName | Should -BeExactly 'dockerbuild-pwsh'
        }
    }

    Context 'Pipeline execution' {
        BeforeAll {
            $tempFolder = New-RandomFolder
            $location = Join-Path $tempFolder "NoSpace"
            New-FakeGitRepository -Path $location

            $pipedInput = {
                $input = [PSCustomObject]@{
                    'RepositoryPath' = $location;
                }
                return $input
            }
        }

        It 'can consume arguments from pipeline' {
            & $pipedInput | Find-ImageName
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Find-ImageName
            $result.ImageName | Should -Be 'dockerbuild-pwsh'
        }
    }
}
