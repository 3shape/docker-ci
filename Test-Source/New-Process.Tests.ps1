Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName

. "$PSScriptRoot\..\Source\Private\New-Process.ps1"

Describe 'Create a new process for command execution' {

    Context 'When creating a new process' {

        It 'sets all attributes of the process startinfo object correctly' {
            [System.Diagnostics.ProcessStartInfo] $result = $(New-Process -Command 'test').StartInfo

            $result.Arguments | Should -BeNullOrEmpty
            $result.FileName | Should -Be 'test'
            $result.CreateNoWindow | Should -Be $true
            $result.RedirectStandardError | Should -Be $true
            $result.RedirectStandardOutput | Should -Be $true
            $result.WorkingDirectory | Should -Not -BeNullOrEmpty
        }

        It 'throws if null command is specified' {
            $theCode = {
                New-Process -Command $null
            }

            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
        }

        It 'makes sure args are never $null' {
            [System.Diagnostics.ProcessStartInfo] $result = $(New-Process -Command 'test' -Arguments $null).StartInfo
            $result.Arguments | Should -Not -Be $null
        }

    }

}
