Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Test-IsSubdirectoryOf.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"

Describe 'test if child path is a subdirectory of path' {

    BeforeAll {
        $parentPath = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
    }

    Context 'both paths are valid directories' {

        It 'succeeds when child path is part of path' {
            $childPath = Join-Path $parentPath "ExampleRepos"
            $result = Test-IsSubdirectoryOf -Path $parentPath -ChildPath $childPath
            $result | Should -Be $true
        }

        It 'succeeds when deeper child path is part of path' {
            $childPathLevel1 = Join-Path $parentPath "ExampleRepos"
            $childPathLevel3 = Join-Path $childPathLevel1 "/3.0/servercore/amd64/"
            $result = Test-IsSubdirectoryOf -Path $parentPath -ChildPath $childPathLevel3
            $result | Should -Be $true
        }

        It 'fails when child path is NOT part of path' {
            $childPath = (Get-Item -Path $PSScriptRoot).PSDrive.Root
            $result = Test-IsSubdirectoryOf -Path $parentPath -ChildPath $childPath
            $result | Should -Be $false
        }
    }

    Context 'one or both paths are not valid directories' {

        It 'fails when child path does not exist' {
            $childPath = Join-Path $parentPath "NoneExistentDirectory"
            $result = Test-IsSubdirectoryOf -Path $parentPath -ChildPath $childPath
            $result | Should -Be $false
        }

        It 'fails when parent path does not exist' {
            $notChildPath = Join-Path $parentPath "NoneExistentDirectory"
            $result = Test-IsSubdirectoryOf -Path $notChildPath -ChildPath $parentPath
            $result | Should -Be $false
        }
    }
}
