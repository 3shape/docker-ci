Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\Utilities.ps1"
. "$PSScriptRoot\New-RandomFolder.ps1"

Describe 'Run docker tests using Google Structure' {

    Context 'Running structure tests' {

        BeforeEach {
            $script:backupLocation = Get-Location
            Set-Location $Global:TestDataDir
        }

        AfterEach {
            Set-Location $script:backupLocation
        }

        It 'can accept a relative path as test report directory' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs -TestReportDir './'
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 1
            $testResult.Pass | Should -Be 1
            $testResult.Fail | Should -Be 0
            $testResult.Results[0].Name | Should -Be 'Command Test: Say hello world'
            $testResult.Results[0].Pass | Should -Be $true
            $testResult.Results[0].StdOut | Should -Be "hello`nworld`n"
        }

        It 'can accept a non-existant path as test report directory, and can create the path to store test reports' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs -TestReportDir (Join-Path (New-RandomFolder) (New-Guid))
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 1
            $testResult.Pass | Should -Be 1
            $testResult.Fail | Should -Be 0
            $testResult.Results[0].Name | Should -Be 'Command Test: Say hello world'
            $testResult.Results[0].Pass | Should -Be $true
            $testResult.Results[0].StdOut | Should -Be "hello`nworld`n"
        }

        It 'can execute 1 succesful test' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 1
            $testResult.Pass | Should -Be 1
            $testResult.Fail | Should -Be 0
            $testResult.Results[0].Name | Should -Be 'Command Test: Say hello world'
            $testResult.Results[0].Pass | Should -Be $true
            $testResult.Results[0].StdOut | Should -Be "hello`nworld`n"
        }

        It 'can execute multiple succesful tests' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir 'testbash.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsPassDir 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 2
            $testResult.Pass | Should -Be 2
            $testResult.Fail | Should -Be 0
            $testResult.Results.Length | Should -Be 2
        }

        It 'can execute multiple failing tests' {
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir 'testbash.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsFailDir 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 1
            $testResult.Total | Should -Be 2
            $testResult.Pass | Should -Be 0
            $testResult.Fail | Should -Be 2
            $testResult.Results.Length | Should -Be 2
        }

        It 'can detect when there are no test configs and throw exception.' {
            Set-Location $Global:StructureTestsDir

            $theCode = {
                $imageToTest = 'ubuntu:latest'
                Invoke-DockerTests -ImageName $imageToTest -TestReportDir (New-RandomFolder)
            }

            $theCode | Should -Throw -ExceptionType ([System.ArgumentException]) -PassThru
        }

        It 'throws an exception if required on test failures' {
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            $theCode = { Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs -TreatTestFailuresAsExceptions -TestReportDir (New-RandomFolder) }

            $theCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }

        It 'picks up all yaml files at the current location if ConfigFiles argument is not supplied' {
            Set-Location $Global:StructureTestsPassDir
            $imageToTest = 'ubuntu:latest'

            $result = Invoke-DockerTests -ImageName $imageToTest
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 2
            $testResult.Pass | Should -Be 2
            $testResult.Fail | Should -Be 0
            $testResult.Results.Length | Should -Be 2
        }
    }

    Context 'Pipeline execution' {

        BeforeAll {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir 'testbash.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsPassDir 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)

            $pipedInput = {
                $input = [PSCustomObject]@{
                    "ImageName"   = "myimage";
                    'ConfigFiles' = $configs
                }
                return $input
            }
        }

        It 'can consume arguments from pipeline' {
            & $pipedInput | Invoke-DockerTests
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerTests
            $result.ImageName | Should -Be 'myimage'
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Verbosity of execution' {

        It 'outputs result if Quiet is disabled' {
            $tempFile = New-TemporaryFile
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs -Quiet:$false 6> $tempFile

            $result = Get-Content $tempFile
            Write-Debug "Result: $result"
            $result | Should -BeLike "*Pass=0; Fail=1; Total=1*"
        }

        It 'suppresses output if Quiet is enabled' {
            $tempFile = New-TemporaryFile
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir 'testbash.yml'
            $configs = @($structureCommandConfig)
            $imageToTest = 'ubuntu:latest'

            Invoke-DockerTests -ImageName $imageToTest -ConfigFiles $configs -Quiet:$true 6> $tempFile

            $result = Get-Content $tempFile
            Write-Debug "Result: $result"
            $result | Should -BeNullOrEmpty
        }
    }
}
