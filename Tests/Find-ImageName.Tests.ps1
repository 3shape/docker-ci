Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Utilities.ps1"

Describe 'Parse context from git repository' {

    Context 'When git is installed' {

        BeforeEach {
            Initialize-MockReg
        }

        BeforeAll {
            $tempFolder = New-RandomFolder
            $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
        }

        AfterAll {
            Remove-Item $tempFolder -Recurse -Force | Out-Null
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
            Mock -CommandName "Invoke-Command" $mockCode -Verifiable -ModuleName $script:moduleName

            $result = Find-ImageName -RepositoryPath $gitReposWithUppercase

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName -Exactly 1
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
