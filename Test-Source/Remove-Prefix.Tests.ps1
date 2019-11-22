Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName

. "$PSScriptRoot\..\Source\Private\Remove-Prefix.ps1"

Describe 'Remove a prefix' {

    Context 'When input is supplied' {

        It 'can remove the prefix on valid input when prefix not found in the string' {
            $input = "test"

            $result = Remove-Prefix -Value $input -Prefix 'notfound'

            $result | Should -BeExactly $input
        }

        It 'can remove the prefix on valid input when prefix is entire string' {
            $input = "test"

            $result = Remove-Prefix -Value $input -Prefix 'test'

            $result | Should -BeExactly ''
        }
    }
}
