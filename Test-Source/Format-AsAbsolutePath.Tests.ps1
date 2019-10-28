Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
. "$PSScriptRoot\..\Source\Private\Format-AsAbsolutePath.ps1"

Describe 'Parse absolute path from input string' {

    Context 'When an absolute path is provided' {
        if ($IsWindows) {
            $absolutePath = 'C:\Windows\System32'
        }
        elseif ($IsLinux) {
            $absolutePath = '/usr/bin'
        }

        It 'returns the provided path' {
            $result = Format-AsAbsolutePath $absolutePath
            $result | Should -Be $absolutePath
        }
    }

    Context 'When a relative path is provided' {

        It 'returns the absolute, fully-qualified path' {
            $relativePath = '../../UpToLevels'
            $result = Format-AsAbsolutePath $relativePath
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Not -BeLike "*..*"
        }
    }
}
