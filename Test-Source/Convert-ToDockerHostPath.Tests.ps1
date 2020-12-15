Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1
. "$PSScriptRoot\..\Source\Private\Convert-ToDockerHostPath.ps1"

Describe 'Convert absolute path to path on docker host with Convert-ToDockerHostPath' {

    BeforeEach {
        Initialize-MockReg
    }

    InModuleScope $Global:ModuleName {

        Context 'Verify we can mock' {

            It 'Hostname can be mocked' {
                Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                $result = hostname
                $result | Should -Be $Global:DockerContainerHostname
                Assert-MockCalled -CommandName "hostname" -Times 1
            }

            It 'Invoke-DockerCommand can be mocked (ps)' {
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                $result = Invoke-DockerCommand 'ps'
                $result.Output | Should -Be $Global:DockerPsOutput
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
            }

            It 'Invoke-DockerCommand can be mocked (inspect)' {
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerInspectMockCode -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                $result = Invoke-DockerCommand 'inspect -f'
                $result.Output | Should -Be $Global:DockerInspectOutput
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
            }
        }

        Context 'When run NOT inside docker container' {

            It 'returns unchanged provided path' {
                Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith { return 'someHostname' } -Verifiable
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:WorkspaceAbsolutePath
                Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                Assert-MockCalled -CommandName "hostname" -Times 1
            }
        }

        Context 'When run inside docker container' {

            It 'returns the path on docker host if folder belongs to mapped volume generic' {
                Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                Mock -CommandName "Invoke-Command" -MockWith $Global:DockerInspectMockCode -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:DockerHostAbsolutePath
                Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                Assert-MockCalled -CommandName "hostname" -Times 1
                Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
            }

            if ($IsWindows) {
                It 'returns the path on docker host if folder belongs to mapped volume on Windows' {
                    Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                    Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                    Mock -CommandName "Invoke-Command" -MockWith $Global:DockerInspectMockCodeWindows -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                    $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                    $result | Should -Be $Global:DockerHostAbsolutePath
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                    Assert-MockCalled -CommandName "hostname" -Times 1
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
                }
            }

            if ($IsLinux) {
                It 'returns the path on docker host if folder belongs to mapped volume on Linux' {
                    Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                    Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                    Mock -CommandName "Invoke-Command" -MockWith $Global:DockerInspectMockCodeLinux -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                    $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                    $result | Should -Be $Global:DockerHostAbsolutePath
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                    Assert-MockCalled -CommandName "hostname" -Times 1
                    Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
                }
            }

            It 'returns the provided path otherwise' {
                Mock -CommandName "Invoke-Command" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith { return $Global:DockerContainerHostname } -Verifiable
                Mock -CommandName "Invoke-Command" -MockWith $Global:CodeThatReturnsExitCodeZeroAndEmptyStdOut -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:WorkspaceAbsolutePath
                Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 2
                Assert-MockCalled -CommandName "hostname" -Times 2
                Assert-MockCalled -CommandName "Invoke-Command" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 2
            }
        }
    }
}
