Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

Describe 'Parse version, distro and arch from Dockerfile path' {

    Context 'Given a well-formed directory structure' {

        It 'Can parse tool version, distro and arch' {
            $dockerFile = Join-Path $Global:ExampleReposDir '/3.0/servercore/amd64/Dockerfile'
            $result = Format-DockerTag -Dockerfile $dockerFile
            $result.Tag | Should -Be '3.0-servercore-amd64'
            $result.Distro | Should -Be 'servercore'
            $result.Version | Should -Be '3.0'
            $result.Arch | Should -be 'amd64'
        }
    }

    Context 'Given a well-formed directory structure but non-existing Dockerfile' {

        It 'throws an exception, when Dockerfile is not found' {
            $noSuchDockerFile = Join-Path $Global:ExampleReposDir "NotADockerFile"
            $code = { Format-DockerTag -Dockerfile $noSuchDockerFile }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }
    }

    Context 'Pipeline exeuction' {
        $dockerFile = Join-Path $Global:ExampleReposDir '/3.0/servercore/amd64/Dockerfile'
        $pipedInput = {
            $input = [PSCustomObject]@{
                'Dockerfile' = $dockerFile;
            }
            return $input
        }

        It 'can consume arguments from pipeline' {
            & ${pipedInput} | Format-DockerTag
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Format-DockerTag
            $result.Arch | Should -Be 'amd64'
            $result.Distro | Should -Be 'servercore'
            $result.Version | Should -Be '3.0'
            $result.Tag | Should -Be '3.0-servercore-amd64'
        }
    }

}

Describe 'Format-DockerTag throws exception' {

    BeforeEach {
        Initialize-MockReg
        $formatAsAbsolutePath = { "/tmp/Dockerfile" }
        $testPath = { $True }
        Mock -CommandName "Format-AsAbsolutePath" $formatAsAbsolutePath -Verifiable -ModuleName $Global:ModuleName
        Mock -CommandName "Test-Path" $testPath -Verifiable -ModuleName $Global:ModuleName
    }

    it 'should thrown exception if parent directory count is less than 3' {
        $code = { Format-DockerTag }
        $code | Should -Throw -ExceptionType ([System.Exception]) -PassThru
    }

}
