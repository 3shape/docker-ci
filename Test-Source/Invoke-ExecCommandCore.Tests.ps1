Import-Module -Force $PSScriptRoot/../Source/Docker-CI.psm1
Import-Module -Force $PSScriptRoot/Docker-CI.Tests.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-ExecCommandCore.ps1"
. "$PSScriptRoot\..\Source\Private\CommandCoreResult.ps1"
. "$PSScriptRoot\..\Source\Private\New-Process.ps1"

Describe 'Runs only external tools' {

    Context 'Runs a simple external command' {
        if ($IsWindows) {
            $command = [PSCustomObject]@{
                'Command'     = 'find'
                'CommandArgs' = '/?'
            }
        } elseif ($IsLinux) {
            $command = [PSCustomObject]@{
                'Command'     = 'grep'
                'CommandArgs' = '--help'
            }
        }

        BeforeEach {
            $tempFile = New-TemporaryFile
        }

        AfterEach {
            Remove-Item $tempFile -Force
        }

        It 'returns correct output and exit code, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs $command.CommandArgs -Quiet:$true 6> $tempFile
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -BeNullOrEmpty
        }

        It 'can run a command with no args' {
            $result = Invoke-ExecCommandCore -Command $command.Command -Quiet:$true
            $result.ExitCode | Should -Not -Be 0
        }

        It 'returns correct output and exit code, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs $command.CommandArgs -Quiet:$false 6> $tempFile
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -Not -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, silently' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -Quiet:$true 6> $tempFile
            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, verbosely' {
            $result = Invoke-ExecCommandCore -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -Quiet:$false 6> $tempFile
            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -Not -BeNullOrEmpty
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

    Context 'Runs a program that crashes' {

        It 'can detect the crash' {
            $code = { throw [System.ArgumentException]::new("exception message") }
            Mock -CommandName "Write-Information" $code
            $theCode = { Invoke-ExecCommandCore -Command "ping" -CommandArgs 'localhost' }
            $theCode | Should -Throw -ExceptionType ([System.ArgumentException]) -PassThru
        }
    }
}
