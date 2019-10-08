. "$PSScriptRoot\..\Private\Test-DockerInstalled.ps1"
. "$PSScriptRoot\..\Private\Invoke-Commands.ps1"

Describe 'Verify docker tool installed' {

    Context 'When docker is installed' {

        It 'It is detected properly' {
            Test-DockerInstalled -DockerCommand "docker info"
        }

        It 'Raises an exception if the provided docker binary does not exist' {
            $code = {
                Test-DockerInstalled -DockerCommand "nonexistent"
            }
            $code | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }

    }
}
