Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'docker push' {

    Context 'Push an image' {

        BeforeEach {
            Initialize-MockReg
            $returnExitCodeZero = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
                $result = [CommandResult]::new()
                $result.ExitCode = 0
                return $result
            }
            Mock -CommandName "Invoke-Command" $returnExitCodeZero -Verifiable -ModuleName $Global:ModuleName
        }

        AfterEach {
            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $Global:ModuleName
        }

        It 'produces the correct command to invoke with only image name provided' {
            Invoke-DockerPush -ImageName 'cool-image'

            $mockResult = GetMockValue -Key 'Invoke-Command'
            $mockResult | Should -Be "docker push cool-image:latest"
        }

        It 'produces the correct command to invoke with image name and registry provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages'

            $mockResult = GetMockValue -Key 'Invoke-Command'
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:latest"
        }

        It 'produces the correct command to invoke with image name and $null registry value provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry $null

            $mockResult = GetMockValue -Key 'Invoke-Command'
            $mockResult | Should -Be "docker push cool-image:latest"
        }

        It 'produces the correct command to invoke with image name, registry and tag provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages' -Tag 'v1.0.3'

            $mockResult = GetMockValue -Key 'Invoke-Command'
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:v1.0.3"
        }

        It 'throws an exception if the execution of docker push did not succeed' {
            $errorProducingCode = {
                $result = [CommandResult]::new()
                $result.ExitCode = 1
                return $result
            }
            Mock -CommandName "Invoke-Command" $errorProducingCode -Verifiable -ModuleName $Global:ModuleName

            $theCode = {
                Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages' -Tag 'v1.0.3'
            }

            $theCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru

        }
    }

    Context 'Pipeline execution' {
        $pipedInput = {
            $input = [PSCustomObject]@{
                "ImageName" = "myimage";
                "Registry"  = "localhost";
                "Tag"       = "v1.0.2"
            }
            return $input
        }

        BeforeEach {
            Initialize-MockReg
            $returnExitCodeZero = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
                $result = [CommandResult]::new()
                $result.ExitCode = 0
                return $result
            }
            Mock -CommandName "Invoke-Command" $returnExitCodeZero -Verifiable -ModuleName $Global:ModuleName
        }

        AfterEach {
            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $Global:ModuleName
        }

        It 'can consume arguments from pipeline' {
            & $pipedInput | Invoke-DockerPush
        }

        It 'returns the expected pscustomobject' {
            $result = & $pipedInput | Invoke-DockerPush
            $result.ImageName | Should -Be 'myimage'
            $result.Registry | Should -Be 'localhost/'
            $result.Tag | Should -Be 'v1.0.2'
        }
    }
}
