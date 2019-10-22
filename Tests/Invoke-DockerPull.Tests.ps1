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
        $commandResult = [CommandResult]::new()
        $commandResult.ExitCode = 0
        return $commandResult
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
            Invoke-DockerPull -Registry 'mcr.microsoft.com' -ImageName 'windows/servercore/iis'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore/iis:latest"
        }

        It 'pulls public docker image by registry and image name' {
            Invoke-DockerPull -Registry 'mcr.microsoft.com' -ImageName 'windows/servercore/iis'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore/iis:latest"
        }

        It 'pulls public docker image by image name and tag' {
            Invoke-DockerPull -Registry 'mcr.microsoft.com' -ImageName 'windows/servercore' -Tag 'ltsc2019'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore:ltsc2019"
        }

        It 'pulls public docker image by image name and digest' {
            Invoke-DockerPull -Registry 'mcr.microsoft.com' -ImageName 'windows/servercore' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            $result = GetMockValue -Key "pull"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker pull mcr.microsoft.com/windows/servercore@sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840"
        }

        It 'pulls public docker image by image name, with both tag and digest; and fails' {
            $theCode = {
                Invoke-DockerPull -ImageName 'mcr.microsoft.com/windows/servercore' -Tag 'ltsc2019' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }

        It 'pulls public docker image by image name with invalid digest, missing sha256: prefix; and fails' {
            $theCode = {
                Invoke-DockerPull -ImageName 'lalaland' -Digest 'f5c0a8d225a4b7556db2b26753a7f4c4de3b090c1a8852983885b80694ca9840'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -PassThru
        }

        It 'pulls public docker image by image name with invalid digest, wrong digest length; and fails' {
            $theCode = {
                Invoke-DockerPull -ImageName 'lalaland' -Digest 'sha256:f5c0a8d225a4b7556db2b26753a7f4c4d'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -PassThru
        }

        It 'does not allow colons in imagename, force use of tag' {
            $theCode = {
                Invoke-DockerPull -ImageName 'lalaland:latest'
            }
            $theCode | Should -Throw -ExceptionType ([System.ArgumentException]) -PassThru
        }

        It 'does not allow at signs in imagename, force use of tag' {
            $theCode = {
                Invoke-DockerPull -ImageName 'lalaland@sha256:f5c0a8d225a4b7556db2b26753a7f4c4d'
            }
            $theCode | Should -Throw -ExceptionType ([System.ArgumentException]) -PassThru
        }

        It 'throws exception on non-zero exit code' {
            $returnNonZeroExitCode = {
                $commandResult = [CommandResult]::new()
                $commandResult.ExitCode = 1
                return $commandResult
            }
            Mock -CommandName "Invoke-Command" $returnNonZeroExitCode  -Verifiable -ModuleName $script:moduleName
            $theCode = {
                Invoke-DockerPull -ImageName 'mcr.microsoft.com/windows/servercore/iis'
            }
            $theCode | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -PassThru
        }
    }

    Context 'Pipeline execution' {

        $code = {
            Write-Debug $Command
            StoreMockValue -Key "pull" -Value $Command
            $commandResult = [CommandResult]::new()
            $commandResult.ExitCode = 0
            return $commandResult
        }

        BeforeEach {
            Initialize-MockReg
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
        }

        AfterEach {
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
        }
        BeforeAll {
            $pipedInput = {
                $input = [PSCustomObject]@{
                    "ImageName" = "myimage";
                    "Registry"  = "localhost";
                    "Tag"       = "v1.0.2"
                }
                return $input
            }
        }

        It 'can consume arguments from pipeline' {
            & $pipedInput | Invoke-DockerPull
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerPull
            $result.ImageName | Should -Be 'myimage'
            $result.Registry | Should -Be 'localhost/'
            $result.Tag | Should -Be 'v1.0.2'
        }
    }
}
