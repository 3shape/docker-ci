Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\CommandResult.ps1"

Describe 'docker push' {

    Context 'Push an image' {

        BeforeAll {
            $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
        }

        BeforeEach {
            Initialize-MockReg
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
        }

        AfterEach {
            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $script:moduleName
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

        It 'produces the correct command to invoke with image name, registry and tag provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages' -Tag 'v1.0.3'

            $mockResult = GetMockValue -Key 'Invoke-Command'
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:v1.0.3"
        }
    }

    Context 'Pipeline execution' {

        BeforeAll {
            $pipedInput = {
                $input = [PSCustomObject]@{
                    "ImageName" = "myimage";
                    "Registry" = "localhost";
                    "Tag" = "v1.0.2"
                }
                return $input
            }
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
