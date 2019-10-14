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

    Context 'Various other functions' {

        It 'can postfix default / to a string' {
            $postfixed = Add-RegistryPostfix -Registry 'lalaland'
            $postfixed | Should -BeLikeExactly 'lalaland/'
        }

        It 'can postfix a string to a string' {
            $postfixed = Add-RegistryPostfix -Registry 'lala' -Postfix 'land'
            $postfixed | Should -BeLikeExactly 'lalaland'
        }

        # To get the digest of a docker image:
        #   best: docker inspect --format='{{index .RepoDigests 0}}' $ImageName
        #   pwsh: (docker inspect $ImageName | ConvertFrom-Json).RepoDigests
        It 'can validate valid docker digests' {
            $digest = 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = Test-DockerDigest -Digest $digest
            $result | Should -Be $true
        }

        It 'can validate invalid docker digests - missing sha256: prefix' {
            $digest = 'f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = Test-DockerDigest -Digest $digest
            $result | Should -Be $false
        }

        It 'can validate invalid docker digests - wrong digest length' {
            $digest = 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b0'
            $result = Test-DockerDigest -Digest $digest
            $result | Should -Be $false
        }
    }
}
