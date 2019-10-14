Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\LintRemark.ps1"

Describe 'Execute linting on a given docker image' {
    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
    $dockerTestData = Join-Path $testData "DockerImage"

    Context 'When full path to a docker image is specified' {

        It 'can find 0 rule violations' {
            $dockerFile = Join-Path $dockerTestData "Windows.Dockerfile"
            $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Windows.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLint -DockerFile $dockerFile

            $lintedDockerFile | Should -Be $result
        }

        It 'can find 1 rule violation' {
            $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Linux.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLint -DockerFile $dockerFile

            $lintedDockerFile | Should -Be $result
        }

        It 'can find multiple rule violations' {

            $dockerFile = Join-Path $dockerTestData "Poorly.Written.Dockerfile"
            [string[]] $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Poorly.Written.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLint -DockerFile $dockerFile

            for ($i = 0; $i -lt $lintedDockerFile.Length; $i++) {
                $lintedDockerFile[$i] | Should -Be $result[$i]
            }

        }

        It 'throws exception if docker image does not exist' {
            $code = {
                Invoke-DockerLint -DockerFile "not/here"
            }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }

        It 'throws correct exception message if docker image does not exist' {
            try {
                Invoke-DockerLint -DockerFile "not.here"
            }
            catch {
                $exception = $_.Exception

            }
            $exception.Message | Should -BeLike "*not.here*"
        }

    }

    Context 'When no path to docker image is specified' {

        BeforeEach {
            Initialize-MockReg
            $script:currentLocation = Get-Location
        }

        AfterEach {
            Set-Location $script:currentLocation
        }

        It "Defaults to `'Dockerfile`'" {
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value "$Command"
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
            Set-Location -Path $dockerTestData

            Invoke-DockerLint

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key 'Invoke-Command'
            $result | Should -BeLike "*Dockerfile*"
        }
    }
}
