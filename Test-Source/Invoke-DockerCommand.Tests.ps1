Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-DockerCommand.ps1"
. "$PSScriptRoot\..\Source\Private\CommandCoreResult.ps1"

Describe 'Runs only external tools' {

    Context 'Runs a simple external command' {
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
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'returns correct output and exit code, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs $command.CommandArgs -ShowInProgressOutput:$true
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$false
            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -ShowInProgressOutput:$true
            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Runs a non-existent command, throws an exception' {

        It 'throws MethodInvocationException instead of CommandNotFoundException' {
            $theCode = { Invoke-ExecCommandCore -Command 'GibberishGoo' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Runs a PS CmdLet, throws an exception just like running a non-existent command' {

        It 'throws MethodInvocationException instead of CommandNotFoundException' {
            $theCode = { Invoke-ExecCommandCore -Command 'Get-Verb' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Runs a null or empty command' {

        It 'throws ParameterBindingException if a null command is passed' {
            $theCode = { Invoke-ExecCommandCore $null }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'throws ParameterBindingException if an empty command is passed' {
            $theCode = { Invoke-ExecCommandCore -Command "" }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
    }
}
