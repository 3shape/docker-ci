Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-DockerCommand.ps1"
. "$PSScriptRoot\..\Source\Private\CommandCoreResult.ps1"

Describe 'Run external tools as commands' {

    Context 'Run a simple external command' {
        if ($IsWindows) {
            $command = [PSCustomObject]@{
                'Command'     = 'find'
                'CommandArgs' = '/?'
            }
        }
        elseif ($IsLinux) {
            $command = [PSCustomObject]@{
                'Command'     = 'grep'
                'CommandArgs' = '--help'
            }
        }

        It 'returns correct output and exit code, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs $command.CommandArgs -ShowInProgressOutput:$false
            $result.ExitCode | Should -Be 0
            $result.StdOut | Should -Not -BeNullOrEmpty
            $result.StdErr | Should -BeNullOrEmpty
        }

        It 'returns correct output and exit code, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs $command.CommandArgs -ShowInProgressOutput:$true
            $result.ExitCode | Should -Be 0
            $result.StdOut | Should -Not -BeNullOrEmpty
            $result.StdErr | Should -BeNullOrEmpty
        }

        It 'returns the error output for failing commands, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$false
            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -BeNullOrEmpty
            $result.StdErr | Should -Not -BeNullOrEmpty
        }

        It 'returns the error output for failing commands, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$true
            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -BeNullOrEmpty
            $result.StdErr | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Cannot run a PS CmdLet' {
        It 'returns error result information' {
            $commandName = 'Get-Verb'
            $result = Invoke-ExecCommandCore $commandName
            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Run a nonexisting command' {
        It 'throws an exception' {
            $theCode = {
                Invoke-ExecCommandCore 'GibberishGoo'
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
