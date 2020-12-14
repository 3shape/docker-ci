Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
. "$PSScriptRoot\..\Source\Private\Convert-ToDockerHostPath.ps1"

Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1

Describe 'Convert absolute path to path on docker host with Convert-ToDockerHostPath' {

    $moduleName = (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).BaseName

    InModuleScope $moduleName {
        
        Context 'Verify we can mock' {

            It 'Hostname can be mocked' {
                Mock -CommandName "hostname" -MockWith {return $Global:DockerContainerHostname} -Verifiable
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

            It 'returns the provided path' {
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith {return 'someHostname'} -Verifiable
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:WorkspaceAbsolutePath
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                Assert-MockCalled -CommandName "hostname" -Times 1
            }
        }

        Context 'When run inside docker container' {

            It 'returns the path on docker host if folder belongs to mapped volume' {
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith {return $Global:DockerContainerHostname} -Verifiable
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerInspectMockCode -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:DockerHostAbsolutePath
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 1
                Assert-MockCalled -CommandName "hostname" -Times 1
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 1
            }
            It 'returns the provided path otherwise' {
                Mock -CommandName "Invoke-DockerCommand" -MockWith $Global:DockerPsMockCode -ParameterFilter { $CommandArgs.StartsWith('ps') } -Verifiable
                Mock -CommandName "hostname" -MockWith {return $Global:DockerContainerHostname} -Verifiable
                Mock -CommandName "Invoke-DockerCommand" -MockWith {$result = [CommandResult]::new(); $result.StdOut = ''; $result.ExitCode = 0; return $result} -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Verifiable #-ModuleName $Global:ModuleName
                $result = Convert-ToDockerHostPath $Global:WorkspaceAbsolutePath
                $result | Should -Be $Global:WorkspaceAbsolutePath
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('ps') } -Times 2
                Assert-MockCalled -CommandName "hostname" -Times 2
                Assert-MockCalled -CommandName "Invoke-DockerCommand" -ParameterFilter { $CommandArgs.StartsWith('inspect -f') } -Times 2
            }
        }
    }
}