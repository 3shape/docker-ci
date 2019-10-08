. "$PSScriptRoot\..\Private\Test-GitInstalled.ps1"
. "$PSScriptRoot\..\Private\Invoke-Commands.ps1"

Describe 'Verify git tool installed' {

    Context 'When git is installed' {

        It 'It is detected properly' {
            Test-GitInstalled
        }

        It 'Raises an exception if the provided docker binary does not exist' {
            $code = {
                Test-GitInstalled -GitCommand "nonexistent"
            }
            $code | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }
    }
}
