Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1

InModuleScope $Global:ModuleName {
    Describe 'Find-DockerSocket' {

        It 'can figure out linux os type without passing it' {
            $mockCode = { 'linux' }
            Mock -CommandName "Find-DockerOSType" $mockCode -Verifiable -ModuleName $Global:ModuleName
            $actualDockerSocket = Find-DockerSocket
            $actualDockerSocket | Should -BeExactly '/var/run/docker.sock'
        }

        It 'can figure out windows os type without passing it' {
            $mockCode = { 'windows' }
            Mock -CommandName "Find-DockerOSType" $mockCode -Verifiable -ModuleName $Global:ModuleName
            $actualDockerSocket = Find-DockerSocket
            $actualDockerSocket | Should -BeExactly '\\.\pipe\docker_engine'
        }

        It 'when windows is passed' {
            $dockerSocket = Find-DockerSocket -OsType 'windows'
            $dockerSocket | Should -BeExactly '\\.\pipe\docker_engine'
        }

        It 'when linux is passed' {
            $dockerSocket = Find-DockerSocket -OsType 'linux'
            $dockerSocket | Should -BeExactly '/var/run/docker.sock'
        }

        It 'when MacOS is passed should throw exception' {
            $dockerSocket = { Find-DockerSocket -OsType 'MacOS' }
            $dockerSocket | Should -Throw "'MacOS' not supported" -ExceptionType ([System.Exception]) -PassThru
        }

        Context 'Case insensitive' {
            It 'when LINUX is passed' {
                $dockerSocket = Find-DockerSocket -OsType 'LINUX'
                $dockerSocket | Should -BeExactly '/var/run/docker.sock'
            }

            It 'when WINDOWS is passed' {
                $dockerSocket = Find-DockerSocket -OsType 'WINDOWS'
                $dockerSocket | Should -BeExactly '\\.\pipe\docker_engine'
            }
        }

    }
}
