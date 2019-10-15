Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Test-DockerDigest.ps1"

Describe 'Docker digest basic validation' {

    Context 'Basic prefix and length checks' {

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
