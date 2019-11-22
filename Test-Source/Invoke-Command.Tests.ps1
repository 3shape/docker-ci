Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'Run external tools as commands' {

    Context 'Run a simple external command' {
        if ($IsWindows) {
            $commandName = "find /?"
        } elseif ($IsLinux) {
            $commandName = "grep --help"
        }

        It 'returns correct output and error information' {
            $result = Invoke-Command $commandName
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'Returns the error output for failing commands' {
            $result = Invoke-Command "find ---nope-this-is-clearly-wrong"
            $result.ExitCode | Should -Not -Be 0
        }
    }

    Context 'Run a PS CmdLet' {
        It 'returns correct result information' {
            $commandName = 'Get-Verb'
            $result = Invoke-Command $commandName
            $result.Success | Should -Be $true
            $result.Output | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Run a nonexisting command' {
        It 'throws an exception' {
            $theCode = {
                Invoke-Command 'GibberishGoo'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.CommandNotFoundException]) -PassThru
        }
    }

    Context 'Run a null or empty command' {
        It 'throws an exception if a null command is passed' {
            $theCode = {
                Invoke-Command $null
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'throws an exception if an empty command is passed' {
            $theCode = {
                Invoke-Command ""
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
    }
}
