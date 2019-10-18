Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
# . $PSScriptRoot/../Private/DockerTagInfo.ps1

Describe 'Parse version, distro and arch from Dockerfile path' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
    $exampleReposPath = Join-Path $testData "ExampleRepos"

    Context 'Given a well-formed directory structure' {

        It 'Can parse tool version, distro and arch' {
            $dockerFile = Join-Path $exampleReposPath '/3.0/servercore/amd64/Dockerfile'
            $result = Format-DockerTag -ContextRoot $exampleReposPath -Dockerfile $dockerFile
            $result.Tag | Should -Be '3.0-servercore-amd64'
            $result.Distro | Should -Be 'servercore'
            $result.Version | Should -Be '3.0'
            $result.Arch | Should -be 'amd64'
        }

        It 'throws an exception, when Dockerfile is not found' {
            $noSuchDockerFile = Join-Path $exampleReposPath "NotADockerFile"
            $code = { Format-DockerTag -ContextRoot $exampleReposPath -Dockerfile $noSuchDockerFile }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }
    }

    Context 'Given a unsupported directory structure but an existing Dockerfile' {

        It 'throws an exception, when the Dockerfile is not in ContextPath' {
            $offContextDockerfile = Join-Path $exampleReposPath "/Off.Context.Dockerfile"
            $code = { Format-DockerTag -ContextRoot (Join-Path $exampleReposPath '3.0') -Dockerfile $offContextDockerfile }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }

        It 'throws an exception' {
            $unsupportedPathDockerFile = Join-Path $exampleReposPath "/3.0/servercore/Unsupported.Path.Dockerfile"
            $code = { Format-DockerTag -ContextRoot $exampleReposPath -Dockerfile $unsupportedPathDockerFile }
            $code | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -PassThru
        }
    }

}
