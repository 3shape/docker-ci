Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Pull docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    $code = {
        Write-Debug $Command
        StoreMockValue -Key "pull" -Value $Command
    }

    BeforeEach {
        Initialize-MockReg
        Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
    }

    AfterEach {
        Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
    }

    Context 'Docker pulls docker images' {

        It 'pulls public docker image with image name only' {
            # This test will most likely fail IRL because there isn't any latest tag available for this image
            Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore:latest"
        }

        It 'pulls public docker image with image name and tag' {
            Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore' -Tag 'ltsc2019'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore:ltsc2019"
        }

        It 'pulls public docker image with image name and digest' {
            Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore@sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840"
        }

        It 'pulls public docker image with image name, tag and digest; digest overrides tag' {
            Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore' -Tag 'ltsc2019' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore@sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840"
        }
    }
}
