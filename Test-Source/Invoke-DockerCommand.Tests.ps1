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

        It 'returns the exit code for failing commands, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$false
            $result.ExitCode | Should -Not -Be 0
            #   Not all command bails out by print error output to stderr
        }

        It 'returns the exit code for failing commands, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$true
            $result.ExitCode | Should -Not -Be 0
            #   Not all command bails out by print error output to stderr
        }
    }

    Context 'Run a non-existent command, throws an exception' {
        It 'throws an exception' {
            $theCode = { Invoke-ExecCommandCore 'GibberishGoo' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Cannot run a PS CmdLet, behaves just like running a non-existent command' {
        It 'returns error result information' {
            $theCode = { Invoke-ExecCommandCore 'Get-Verb' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Run a null or empty command' {
        It 'throws an exception if a null command is passed' {
            $theCode = { Invoke-ExecCommandCore $null }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'throws an exception if an empty command is passed' {
            $theCode = { Invoke-ExecCommandCore "" }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
    }
}
