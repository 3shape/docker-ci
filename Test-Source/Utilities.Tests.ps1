Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
. "$PSScriptRoot\..\Source\Private\Utilities.ps1"

Describe 'Validate various support functions for testing' {

    Context 'Validating support functions for - When git is installed' {

        It 'can create random folder in TEMP folder' {
            $pathInTemp = New-RandomFolder

            Test-Path -Path $pathInTemp | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force
        }

        It 'can create fake git repository for testing' {
            $pathInTemp = New-RandomFolder
            New-FakeGitRepository -Path $pathInTemp

            Test-Path -Path (Join-Path $pathInTemp ".git") -PathType Container | Should -Be $true
            Test-Path -Path (Join-Path $pathInTemp ".git/config") -PathType Leaf | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force
        }

        It 'can remove and create fake git repository for testing' {
            $pathInTemp = New-RandomFolder
            New-Item (Join-Path $pathInTemp '.git') -ItemType Container -Force
            New-FakeGitRepository -Path $pathInTemp

            Test-Path -Path (Join-Path $pathInTemp ".git") -PathType Container | Should -Be $true
            Test-Path -Path (Join-Path $pathInTemp ".git/config") -PathType Leaf | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force
        }
    }

    Context 'Various other functions' {

        It 'can postfix default / to a string' {
            $postfixed = Add-Postfix -Value 'lalaland'
            $postfixed | Should -BeLikeExactly 'lalaland/'
        }

        It 'can postfix a string to a string' {
            $postfixed = Add-Postfix -Value 'lala' -Postfix 'land'
            $postfixed | Should -BeLikeExactly 'lalaland'
        }

        It 'wont add postfix to a whitespace only value' {
            $postfixed = Add-Postfix -Value '    ' -Postfix 'land'
            [string]::IsNullOrEmpty($postfixed) | Should -Be $true
        }

        It 'wont add postfix to a $null value' {
            $postfixed = Add-Postfix -Value $null -Postfix 'land'
            [string]::IsNullOrEmpty($postfixed) | Should -Be $true
        }
    }
}
