Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
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

        It 'pulls public docker image by image name only' {
            Invoke-DockerPull -ImageName 'mcr.microsoft.com/windows/servercore/iis'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore/iis:latest"
        }

        It 'pulls public docker image by registry and image name' {
            Invoke-DockerPull -Registry 'mcr.microsoft.com/windows/servercore' -Image 'iis'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore/iis:latest"
        }

        It 'pulls public docker image by image name and tag' {
            Invoke-DockerPull -ImageName 'mcr.microsoft.com/windows/servercore' -Tag 'ltsc2019'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore:ltsc2019"
        }

        It 'pulls public docker image by image name and digest' {
            Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore@sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840"
        }

        It 'pulls public docker image by image name, with both tag and digest; and fails' {
            $theCode = {
                Invoke-DockerPull -Image 'mcr.microsoft.com/windows/servercore' -Tag 'ltsc2019' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by tag only; and fails' {
            $theCode = {
                Invoke-DockerPull -Tag 'mcr.microsoft.com/windows/servercore' -Passthrough
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by digest only; and fails' {
            $theCode = {
                Invoke-DockerPull -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840' -Passthrough
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by registry and digest only; and fails' {
            $theCode = {
                Invoke-DockerPull -Registry 'lalaland' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840' -Passthrough
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by image name with invalid digest, missing sha256: prefix; and fails' {
            $theCode = {
                Invoke-DockerPull -Image 'lalaland' -Digest 'f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840' -Passthrough
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by image name with invalid digest, wrong digest length; and fails' {
            $theCode = {
                Invoke-DockerPull -Image 'lalaland' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4d' -Passthrough
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
   }
}
