Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\LintRemark.ps1"

Describe 'Execute linting on a given docker image' {

    Context 'When full path to a docker image is specified' {

        $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
        $dockerTestData = Join-Path $testData "DockerImage"

        It 'can find 0 rule violations' {
            $dockerFile = Join-Path $dockerTestData "Windows.Dockerfile"
            $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Windows.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLinting -DockerFile $dockerFile

            $lintedDockerFile | Should -Be $result
        }

        It 'can find 1 rule violation' {
            $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Linux.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLinting -DockerFile $dockerFile

            $lintedDockerFile | Should -Be $result
        }

        It 'can find multiple rule violations' {

            $dockerFile = Join-Path $dockerTestData "Poorly.Written.Dockerfile"
            [string[]] $lintedDockerFile = Get-Content -Path (Join-Path $dockerTestData "Poorly.Written.Dockerfile.Linted")

            [string[]] $result = Invoke-DockerLinting -DockerFile $dockerFile

            for ($i = 0; $i -lt $lintedDockerFile.Length; $i++) {
                $lintedDockerFile[$i] | Should -Be $result[$i]
            }

        }

        It 'throws exception if docker image does not exist' {
            $code = {
                Invoke-DockerLinting -DockerFile "not/here"
            }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }



    }

}
