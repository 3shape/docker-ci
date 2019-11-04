Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"

Describe 'Build docker images' {

    BeforeEach {
        Initialize-MockReg
        $dockerFile = Join-Path $Global:DockerImagesDir "Linux.Dockerfile"
        Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
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
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeOne -Verifiable -ModuleName $Global:ModuleName
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
            $result | Should -BeExactly "docker build `"$Global:DockerImagesDir`" -t leeandrasmus:latest -f `"${dockerFile}`""
        }
    }

    Context 'Docker build with cache from parameter' {

        It 'creates correct docker build command, with valid registry parameter and with correct CacheFrom image name' {
            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile -Registry 'valid' -CacheFrom 'leeandrasmus:sha256'
            $result = GetMockValue -Key "command"
            $result | Should -BeExactly "docker build `"$Global:DockerImagesDir`" -t valid/leeandrasmus:latest -f `"${dockerFile}`" --cache-from leeandrasmus:sha256"
        }

        It 'creates correct docker build command, with $null registry parameter and with correct CacheFrom image name' {
            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile -Registry $null -CacheFrom 'leeandrasmus:notlatest'
            $result = GetMockValue -Key "command"
            $result | Should -BeExactly "docker build `"$Global:DockerImagesDir`" -t leeandrasmus:latest -f `"${dockerFile}`" --cache-from leeandrasmus:notlatest"
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
            & $pipedInput | Invoke-DockerBuild
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerBuild
            $result.Dockerfile | Should -Not -BeNullOrEmpty
            $result.ImageName | Should -Not -BeNullOrEmpty
            $result.Registry | Should -Not -Be $null
            $result.Tag | Should -Not -BeNullOrEmpty
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Passthru execution' {

        It 'Captures the output of the command invoked' {
            $tempFile = New-TemporaryFile
            Invoke-DockerBuild -ImageName "leeandrasmus" -Dockerfile $dockerFile -Passthru 6> $tempFile
            $result = Get-Content $tempFile

            $result | Should -Be @('Hello', 'World')
        }
    }
}
