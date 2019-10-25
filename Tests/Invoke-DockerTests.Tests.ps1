Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Force $PSScriptRoot/../Docker.Build.Tests.psm1

Describe 'Run docker tests' {
    $dirWithNoTest = Join-Path $Global:TestDataDir "DockerImage"
    $dirThatDoesNotExist = Join-Path $Global:TestDataDir "GibberishGoo"

    Context 'Run with 1 pester test' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-DockerTests -TestDirectory $Global:PesterTestsDir
            $result.PassedCount | Should -Be 1
            $result.TestResult[0].Describe | Should -BeExactly 'At level 0'
        }
    }

    Context 'Run with 2 pester tests' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-DockerTests -TestDirectory $Global:PesterTestsDir -Depth 1
            $result.PassedCount | Should -Be 2
            $result.TestResult[0].Describe | Should -BeExactly 'At level 1'
            $result.TestResult[1].Describe | Should -BeExactly 'At level 0'
        }
    }

    Context 'Run with 0 pester tests' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-DockerTests -TestDirectory $dirWithNoTest -Depth 1
            $result.PassedCount | Should -Be 0
        }
    }

    Context 'Run with dir that does not exist' {
        It 'finds test files and produces correct command to run them' {
            $code = { Invoke-DockerTests -TestDirectory $dirThatDoesNotExist }
            $code | Should -Throw -ExceptionType ([System.IO.DirectoryNotFoundException]) -PassThru
        }
    }

    Context 'Pipeline execution' {

        It 'returns the expected pscustomobject' {
            $result = Invoke-DockerTests -TestDirectory $Global:PesterTestsDir
            $result.TestResult | Should -Not -BeNullOrEmpty
        }
    }
}
