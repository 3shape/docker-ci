Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Utilities.ps1"

Describe 'Validate various support functions for testing' {

    Context 'Validating support functions for - When git is installed' {

        It 'returns platform agnostic TEMP folder' {
            $tempPath = Get-TempPath

            if ($IsWindows) {
                $tempPath.IndexOf((Get-Item -LiteralPath $Env:TEMP).FullName) | Should -Be 0
            } elseif ($IsLinux) {
                $tempPath.IndexOf('/tmp') | Should -Be 0
            }
        }

        It 'can create random folder in TEMP folder' {
            $pathInTemp = New-RandomFolder

            Test-Path -Path $pathInTemp | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force | Out-Null
        }

        It 'can create fake git repository for testing' {
            $pathInTemp = New-RandomFolder
            New-FakeGitRepository -Path $pathInTemp

            Test-Path -Path (Join-Path $pathInTemp ".git") -PathType Container | Should -Be $true
            Test-Path -Path (Join-Path $pathInTemp ".git/config") -PathType Leaf | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force | Out-Null
        }

    }
}
