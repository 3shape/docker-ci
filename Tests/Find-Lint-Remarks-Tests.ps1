Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Find-LintRemarks.ps1"
. "$PSScriptRoot\..\Private\LintRemark.ps1"

Describe 'Parse context from git repository' {

    Context 'When parsing text as lint remarks' {


        It 'can find 5 lint remarks' {
            $validText = @"
/dev/stdin:2 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead /dev/stdin:3 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead /dev/stdin:8 DL3009 Delete the apt-get lists after installing something /dev/stdin:11 DL3027 Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead /dev/stdin:12 SC1025 Use arguments JSON notation for CMD and ENTRYPOINT arguments
"@

            $result = Find-LintRemarks $validText
            $result.Length | Should -Be 5
        }

        It 'can find 0 lint remarks' {
            $validText = @"
sdf sdfsdf sdf sdfsd
"@

            $result = Find-LintRemarks $validText
            $result.Length | Should -Be 0
        }

        It 'can find lint remarks that contain special characters' {
            $text = '/dev/stdin:2 DL3016 Pin versions in npm. Instead of `npm install <package>` use `npm install <package>@<version>`'

            $result = Find-LintRemarks $text

            $result.Length | Should -Be 1
        }

    }
}




