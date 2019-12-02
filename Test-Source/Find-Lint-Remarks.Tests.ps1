Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName

. "$PSScriptRoot\..\Source\Private\Find-LintRemarks.ps1"
. "$PSScriptRoot\..\Source\Private\LintRemark.ps1"

Describe 'Parse context from git repository' {

    Context 'When parsing text as lint remarks' {

        It 'can find multiple lint remarks' {
            $validText =
            @("/dev/stdin:2 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead",
                "/dev/stdin:3 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead",
                "/dev/stdin:8 DL3009 Delete the apt-get lists after installing something",
                "/dev/stdin:11 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead",
                "/dev/stdin:12 SC1025 Use arguments JSON notation for CMD and ENTRYPOINT arguments",
                "/dev/stdin:12 DL3009 Delete the apt-get lists after installing something",
                "/dev/stdin:12 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead")

            $result = Find-LintRemarks $validText

            $result.Length | Should -Be 7
            $result[0].LineNumber | Should -Be 2
            $result[0].LintRule | Should -Be 'DL3027'
            $result[1].LineNumber | Should -Be 3
            $result[1].LintRule | Should -Be 'DL3027'
            $result[2].LineNumber | Should -Be 8
            $result[2].LintRule | Should -Be 'DL3009'
            $result[3].LineNumber | Should -Be 11
            $result[3].LintRule | Should -Be 'DL3027'
            $result[4].LineNumber | Should -Be 12
            $result[4].LintRule | Should -Be 'DL3009'
            $result[5].LineNumber | Should -Be 12
            $result[5].LintRule | Should -Be 'DL3027'
            $result[6].LineNumber | Should -Be 12
            $result[6].LintRule | Should -Be 'SC1025'
        }

        It 'can find 0 lint remarks' {
            $validText = @("sdf", "sdfsdf", "sdf", "sdfsd")

            $result = Find-LintRemarks $validText
            $result.Length | Should -Be 0
        }

        It 'can find lint remarks that contain special characters' {
            $text = '/dev/stdin:2 DL3016 Pin versions in npm. Instead of `npm install <package>` use `npm install <package>@<version>`'

            $result = Find-LintRemarks $text

            $result.Length | Should -Be 1
        }

        It 'returns an empty list on null input' {
            $input = $null

            $result = Find-LintRemarks $input

            $test = ($result -is [Array])
            $test | Should -Be $true
            $result.Length | Should -Be 0
        }
    }
}
