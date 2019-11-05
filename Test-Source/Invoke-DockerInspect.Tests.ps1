Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"

Describe 'Inspect docker images' {

    BeforeEach {
        Initialize-MockReg
        Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
    }

    AfterEach {
        Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $Global:ModuleName
    }

    Context 'Docker inspect image' {

        It 'creates the correct command for inspection with image name' {
            Invoke-DockerInspect -ImageName "leeandrasmus"
            $result = GetMockValue -Key "command"
            $result | Should -BeExactly "docker inspect leeandrasmus:latest"
        }

        It 'creates the correct command for inspection with image name and tag' {
            Invoke-DockerInspect -ImageName "leeandrasmus" -Tag "tagname"
            $result = GetMockValue -Key "command"
            $result | Should -BeExactly "docker inspect leeandrasmus:tagname"
        }

        It 'creates the correct command for inspection with registry, image name and tag' {
            Invoke-DockerInspect -ImageName "leeandrasmus" -Tag "tagname" -Registry 'localregistry'
            $result = GetMockValue -Key "command"
            $result | Should -BeExactly "docker inspect localregistry/leeandrasmus:tagname"
        }

        It 'Throws exception if exitcode is not 0' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeOne -Verifiable -ModuleName $Global:ModuleName
            $runner = { Invoke-DockerInspect -ImageName "leeandrasmus" -Context $Global:DockerImagesDir -Dockerfile $dockerFile }
            $runner | Should -Throw -ExceptionType ([System.Exception]) -PassThru
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
            & $pipedInput | Invoke-DockerInspect
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerInspect
            $result.Registry | Should -Not -Be $null
            $result.ImageName | Should -Not -BeNullOrEmpty
            $result.Tag | Should -Not -BeNullOrEmpty
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Passthru execution' {

        It 'Captures the output of the command invoked' {
            $tempFile = New-TemporaryFile
            Invoke-DockerInspect -ImageName "leeandrasmus" -Passthru 6> $tempFile
            $result = Get-Content $tempFile
            $result | Should -Not -Be $null
        }
    }
}
