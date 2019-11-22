Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName

. "$PSScriptRoot\..\Source\Private\Test-IsSubdirectoryOf.ps1"
. "$PSScriptRoot\..\Source\Private\Format-AsAbsolutePath.ps1"

Describe 'test if child path is a subdirectory of path' {

    Context 'both paths are valid directories' {

        It 'succeeds when child path is part of path' {
            $result = Test-IsSubdirectoryOf -ParentPath $Global:TestDataDir -ChildPath $global:ExampleReposDir
            $result | Should -Be $true
        }

        It 'succeeds when deeper child path is part of path' {
            $deeperChildPath = Join-Path $Global:ExampleReposDir "/3.0/servercore/amd64/"
            $result = Test-IsSubdirectoryOf -ParentPath $Global:TestDataDir -ChildPath $deeperChildPath
            $result | Should -Be $true
        }

        It 'fails when child path is NOT part of path' {
            $childPath = (Get-Item -Path $PSScriptRoot).PSDrive.Root
            $result = Test-IsSubdirectoryOf -ParentPath $Global:TestDataDir -ChildPath $childPath
            $result | Should -Be $false
        }
    }

    Context 'one or both paths are not valid directories' {

        It 'fails when child path does not exist' {
            $childPath = Join-Path $Global:TestDataDir "NoneExistentDirectory"
            $result = Test-IsSubdirectoryOf -ParentPath $Global:TestDataDir -ChildPath $childPath
            $result | Should -Be $false
        }

        It 'fails when parent path does not exist' {
            $nonExistantPath = Join-Path $Global:TestDataDir "NoneExistentDirectory"
            $result = Test-IsSubdirectoryOf -ParentPath $nonExistantPath -ChildPath $Global:TestDataDir
            $result | Should -Be $false
        }
    }
}
