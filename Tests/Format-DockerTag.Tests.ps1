Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
# . $PSScriptRoot/../Private/DockerTagInfo.ps1

Describe 'Parse version, distro and arch from Dockerfile path' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Given a well-formed directory structure' {
        $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
        $exampleReposPath = Join-Path $testData "ExampleRepos"

        It 'Can parse tool version, distro and arch' {
            $dockerFile = Join-Path $exampleReposPath '/3.0/servercore/amd64/Dockerfile'
            $result = Format-DockerTag -Dockerfile $dockerFile
            $result.Tag | Should -Be '3.0-servercore-amd64'
            $result.Distro | Should -Be 'servercore'
            $result.Version | Should -Be '3.0'
            $result.Arch | Should -be 'amd64'
        }
    }

    Context 'Given a well-formed directory structure but non-existing Dockerfile' {
        $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
        $exampleReposPath = Join-Path $testData "ExampleRepos"

        It 'throws an exception' {
            $noSuchDockerFile = Join-Path $exampleReposPath "NotADockerFile"
            $code = { Format-DockerTag -Dockerfile $noSuchDockerFile }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }
    }

}