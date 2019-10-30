Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Source\Private\Assert-ExitCodeOk.ps1"

Describe 'Build docker images' {

    BeforeAll {
        $returnExitCodeZero = {
            Write-Debug $Command
            StoreMockValue -Key "command" -Value $Command
            $result = [CommandResult]::new()
            $result.ExitCode = 0
            return $result
        }
    }

    BeforeEach {
        Initialize-MockReg
        if ($IsWindows) {
            $dockerFile = Join-Path $Global:DockerImagesDir "Windows.Dockerfile"
        }
        elseif ($IsLinux) {
            $dockerFile = Join-Path $Global:DockerImagesDir "Linux.Dockerfile"
        }
        Mock -CommandName "Invoke-Command" $returnExitCodeZero -Verifiable -ModuleName $Global:ModuleName
    }

    AfterEach {
        Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $Global:ModuleName
    }

    Context 'Docker build with latest tag' {

        It 'creates correct docker build command' {
            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile
            $result = GetMockValue -Key "command"
            $result | Should -BeLikeExactly "docker build `"$($Global:DockerImagesDir)`" -t leeandrasmus:latest -f `"${dockerFile}`""
        }

        It 'Throws exception if exitcode is not 0' {
            $returnExitCodeOne = {
                Write-Debug $Command
                StoreMockValue -Key "command" -Value $Command
                $result = [CommandResult]::new()
                $result.ExitCode = 1
                return $result
            }
            Mock -CommandName "Invoke-Command" $returnExitCodeOne -Verifiable -ModuleName $Global:ModuleName
            $runner = {
                Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile
            }
            $runner | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }
    }

    Context 'Docker build with various parameters' {

        It 'creates correct docker build command, with valid registry parameter' {
            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile -Registry 'valid'
            $result = GetMockValue -Key "command"
            $result | Should -BeLikeExactly "docker build `"$($Global:DockerImagesDir)`" -t valid/leeandrasmus:latest -f `"${dockerFile}`""
        }

        It 'creates correct docker build command, with $null registry parameter' {
            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile -Registry $null
            $result = GetMockValue -Key "command"
            $result | Should -BeLikeExactly "docker build `"$($Global:DockerImagesDir)`" -t leeandrasmus:latest -f `"${dockerFile}`""
        }
    }

    Context 'Pipeline execution' {

        BeforeEach {
            Initialize-MockReg
        }

        $pipedInput = {
            $input = [PSCustomObject]@{
                "ImageName" = "myimage";
            }
            return $input
        }

        It 'can consume arguments from pipeline' {
            Mock -CommandName "Invoke-Command" $returnExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            & $pipedInput | Invoke-DockerBuild
        }

        It 'returns the expected pscustomobject' {
            Mock -CommandName "Invoke-Command" $returnExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            $result = & $pipedInput | Invoke-DockerBuild
            $result.Dockerfile | Should -Not -BeNullOrEmpty
            $result.ImageName | Should -Not -BeNullOrEmpty
        }
    }
}
