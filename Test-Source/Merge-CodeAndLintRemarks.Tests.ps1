Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName

. "$PSScriptRoot\..\Source\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Source\Private\Merge-CodeAndLintRemarks.ps1"

Describe 'Merge code lines with linting remarks' {

    Context 'When both code lines and linting remarks are provided' {

        It 'can produce correct output for 0 violations' {
            $code = @("FROM mcr.microsoft.com/windows/servercore:1809")
            $expected = @("1: FROM mcr.microsoft.com/windows/servercore:1809")
            $lintRemarks = $null

            $result = Merge-CodeAndLintRemarks $code $lintRemarks
            $result | Should -Be $expected
        }

        It 'can produce correct output for 1 violation' {
            $code = @("FROM ubuntu:18.04", "RUN apt update")
            $lintRemarks = @(
                [LintRemark]@{LineNumber = 2; LintRule = "DL3027"; Explanation = "Do not use apt as it is meant to be an end-user tool, use apt-get or apt-cache instead." }
            )

            $result = Merge-CodeAndLintRemarks $code $lintRemarks

            $expected = @("1: FROM ubuntu:18.04", "DL3027 Do not use apt as it is meant to be an end-user tool, use apt-get or apt-cache instead.", "2: RUN apt update")
            $result | Should -BeExactly $expected
        }

        It 'can produce correct output for code with blank lines' {
            $code = @("FROM ubuntu:18.04", "", "RUN apt update")
            $lintRemarks = @(
                [LintRemark]@{LineNumber = 3; LintRule = "DL3027"; Explanation = "Do not use apt as it is meant to be an end-user tool, use apt-get or apt-cache instead." }
            )

            $result = Merge-CodeAndLintRemarks $code $lintRemarks

            $expected = @("1: FROM ubuntu:18.04", "2:", "DL3027 Do not use apt as it is meant to be an end-user tool, use apt-get or apt-cache instead.", "3: RUN apt update")
            $result | Should -BeExactly $expected
        }
    }
}
