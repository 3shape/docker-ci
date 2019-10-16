Import-Module -Force $PSScriptRoot/../Docker.Build.psm1

Describe 'Run pester tests' {
    $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
    $pesterTestData = Join-Path $testData "PesterTests"
    $dirWithNoTest = Join-Path $testData "DockerImage"
    $dirThatDoesNotExist = Join-Path $testData "GibberishGoo"

    Context 'Run with 1 pester test' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-PesterTests -TestDirectory $pesterTestData
            $result.PassedCount | Should -Be 1
            $result.TestResult[0].Describe | Should -BeExactly 'At level 0'
        }
    }

    Context 'Run with 2 pester tests' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-PesterTests -TestDirectory $pesterTestData -Depth 1
            $result.PassedCount | Should -Be 2
            $result.TestResult[0].Describe | Should -BeExactly 'At level 1'
            $result.TestResult[1].Describe | Should -BeExactly 'At level 0'
        }
    }

    Context 'Run with 0 pester tests' {
        It 'finds test files and produces correct command to run them' {
            $result = Invoke-PesterTests -TestDirectory $dirWithNoTest -Depth 1
            $result.PassedCount | Should -Be 0
        }
    }

    Context 'Run with dir that does not exist' {
        It 'finds test files and produces correct command to run them' {
            $code = {Invoke-PesterTests -TestDirectory $dirThatDoesNotExist}
            $code | Should -Throw -ExceptionType ([System.IO.DirectoryNotFoundException]) -PassThru
        }
    }
}