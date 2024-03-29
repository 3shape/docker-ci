
# Fails due to drive permission
if ($IsWindows -and $env:TF_BUILD -ieq 'true') {
    return
}

Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1

$imageToTest = if ($Global:DockerOsType -ieq 'linux') {
    'ubuntu:latest'
} elseif ($Global:DockerOsType -ieq 'windows') {
    'mcr.microsoft.com/windows/nanoserver:1809'
} else {
    throw "'$Global:DockerOsType' is not supported"
}

$Image, $Tag = $imageToTest -split ':'

Describe 'Run docker tests using Google Structure' {

    Context 'Running structure tests' {

        BeforeAll {
            Invoke-DockerPull -ImageName $Image -Tag $Tag
        }

        BeforeEach {
            $script:backupLocation = Get-Location
            Set-Location $Global:TestDataDir
        }

        AfterEach {
            Set-Location $script:backupLocation
        }

        It 'can accept a relative path as test report directory' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'testshell.yml'
            $configs = @($structureCommandConfig)

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs -TestReportDir './'
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
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'testshell.yml'
            $configs = @($structureCommandConfig)

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs -TestReportDir (Join-Path (New-RandomFolder) (New-Guid))
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

        It 'can execute 1 successful test' {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'testshell.yml'
            $configs = $structureCommandConfig

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs
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
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'testshell.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 2
            $testResult.Pass | Should -Be 2
            $testResult.Fail | Should -Be 0
            $testResult.Results.Length | Should -Be 2
        }

        It 'can pick up tests in a nested folder structure' {
            $allPassingTestsDir = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType
            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $allPassingTestsDir
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 3
            $testResult.Pass | Should -Be 3
            $testResult.Fail | Should -Be 0
            $testResult.Results.Length | Should -Be 3
        }

        It 'can execute multiple failing tests' {
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)

            $result = Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 1
            $testResult.Total | Should -Be 2
            $testResult.Pass | Should -Be 0
            $testResult.Fail | Should -Be 2
            $testResult.Results.Length | Should -Be 2
        }

        It 'can detect when there are no test configs and throw exception.' {
            Set-Location (New-RandomFolder)

            $theCode = {
                Invoke-DockerTests -ImageName $imageToTest -TestReportDir (New-RandomFolder)
            }

            $theCode | Should -Throw -ExceptionType ([System.ArgumentException]) -PassThru
        }

        It 'throws an exception if required on test failures' {
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
            $configs = @($structureCommandConfig)

            $theCode = { Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs -TreatTestFailuresAsExceptions -TestReportDir (New-RandomFolder) }

            $theCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }

        It 'picks up all yaml files at the current location if ConfigPath argument is omitted' {
            $testsDir = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType
            Set-Location $testsDir

            $result = Invoke-DockerTests -ImageName $imageToTest
            $commandResult = $result.CommandResult
            $testResult = $result.TestResult

            $commandResult.ExitCode | Should -Be 0
            $testResult.Total | Should -Be 3
            $testResult.Pass | Should -Be 3
            $testResult.Fail | Should -Be 0
            $testResult.Results.Length | Should -Be 3
        }

        It 'throws if ConfigPath set to a directory with no yaml files.' {
            $theCode = { Invoke-DockerTests -ImageName $imageToTest -ConfigPath (New-RandomFolder) }
            $theCode | Should -Throw -ExceptionType 'System.ArgumentException'
        }

        InModuleScope $Global:ModuleName {

            if ($IsWindows) {

                It 'throws an exception if Convert-ToDockerHostPath fails on docker ps' {
                    $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
                    $configs = @($structureCommandConfig)
                    Mock -CommandName "Invoke-Command" -MockWith $Global:CodeThatReturnsExitCodeOne -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                    $theCode = { Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs }
                    $theCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                }

                It 'throws an exception if Convert-ToDockerHostPath fails on docker inspect' {
                    $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
                    $configs = @($structureCommandConfig)
                    Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                    Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                    Mock -CommandName "Invoke-Command" -MockWith $Global:CodeThatReturnsExitCodeOne -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable

                    $theCode = { Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs }
                    $theCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                    Assert-MockCalled -CommandName "hostname" -Times 2
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
                }
            }
        }
    }

    Context 'Pipeline execution' {

        BeforeAll {
            $structureCommandConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'testshell.yml'
            $structureExistConfig = Join-Path $Global:StructureTestsPassDir $Global:DockerOsType 'fileexistence.yaml'
            $configs = @($structureCommandConfig, $structureExistConfig)

            $pipedInput = {
                $input = [PSCustomObject]@{
                    "ImageName"  = "myimage";
                    'ConfigPath' = $configs
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
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
            $configs = @($structureCommandConfig)

            Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs -Quiet:$false 6> $tempFile

            $result = Get-Content $tempFile -Raw
            Write-Debug "Result: $result"
            $result | Should -BeLike "*Pass=0; Fail=1; Total=1*"
        }

        It 'suppresses output if Quiet is enabled' {
            $tempFile = New-TemporaryFile
            $structureCommandConfig = Join-Path $Global:StructureTestsFailDir $Global:DockerOsType 'testshell.yml'
            $configs = @($structureCommandConfig)

            Invoke-DockerTests -ImageName $imageToTest -ConfigPath $configs -Quiet:$true 6> $tempFile

            $result = Get-Content $tempFile
            Write-Debug "Result: $result"
            $result | Should -BeNullOrEmpty
        }
    }
}
