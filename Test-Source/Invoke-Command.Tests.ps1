Import-Module -Force $PSScriptRoot/../Source/Docker-CI.psm1
Import-Module -Force -Global $PSScriptRoot/Docker-CI.Tests.psm1

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
            $result = Invoke-Command -Command $command.Command -CommandArgs $command.CommandArgs -Quiet:$true 6> $tempFile

            $result.ExitCode | Should -Be 0
            $result.StdOut | Should -Not -BeNullOrEmpty
            $result.StdErr | Should -BeNullOrEmpty
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -BeNullOrEmpty
        }

        It 'can run a command with no args' {
            $result = Invoke-Command -Command $command.Command -Quiet:$true
            
            # Flaky test fix
            Start-Sleep -Seconds 1

            Start-Sleep -Seconds 1

            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -BeNullOrEmpty
            $result.StdErr | Should -Not -BeNullOrEmpty
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'returns correct output and exit code, verbosely' {
            $result = Invoke-Command -Command $command.Command -CommandArgs $command.CommandArgs -Quiet:$false 6> $tempFile

            $result.ExitCode | Should -Be 0
            $result.StdOut | Should -Not -BeNullOrEmpty
            $result.StdErr | Should -BeNullOrEmpty
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -Not -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, silently' {
            $result = Invoke-Command -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -Quiet:$true 6> $tempFile

            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -BeNullOrEmpty
            $result.StdErr | Should -Not -BeNullOrEmpty
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -BeNullOrEmpty
        }

        It 'returns the exit code for failing commands, verbosely' {
            $result = Invoke-Command -Command $command.Command -CommandArgs "---nope-this-is-clearly-wrong" -Quiet:$false 6> $tempFile

            $result.ExitCode | Should -Not -Be 0
            $result.StdOut | Should -BeNullOrEmpty
            $result.StdErr | Should -Not -BeNullOrEmpty
            $result.Output | Should -Not -BeNullOrEmpty
            Get-Content $tempFile | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Runs a non-existent command, throws an exception' {

        It 'throws MethodInvocationException instead of CommandNotFoundException' {
            $theCode = { Invoke-Command -Command 'GibberishGoo' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Runs a PS CmdLet, throws an exception just like running a non-existent command' {

        It 'throws MethodInvocationException instead of CommandNotFoundException' {
            $theCode = { Invoke-Command -Command 'Get-Verb' }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.MethodInvocationException]) -PassThru
        }
    }

    Context 'Runs a null or empty command' {

        It 'throws ParameterBindingException if a null command is passed' {
            $theCode = { Invoke-Command $null }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'throws ParameterBindingException if an empty command is passed' {
            $theCode = { Invoke-Command -Command "" }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
    }

}
