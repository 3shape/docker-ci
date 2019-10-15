Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\CommandResult.ps1"

Describe 'docker push' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    BeforeEach {
        Initialize-MockReg

    }

    Context 'Push an image' {

        It 'produces the correct command to invoke with only image name provided' {
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerPush -Image 'cool-image'
            $mockResult = GetMockValue -Key 'Invoke-Command'

            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $script:moduleName
            $mockResult | Should -Be "docker push cool-image:latest"
        }

        It 'produces the correct command to invoke with image name and repository provided' {
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerPush -Image 'cool-image' -Repository 'thebestdockerimages'
            $mockResult = GetMockValue -Key 'Invoke-Command'

            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $script:moduleName
            $mockResult | Should -Be "docker push thebestdockerimages/cool-image:latest"
        }

        It 'produces the correct command to invoke with image name, registry and repository provided' {
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerPush -Image 'cool-image' -Repository 'thebestdockerimages' -Registry 'hub.docker.com:1337'
            $mockResult = GetMockValue -Key 'Invoke-Command'

            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $script:moduleName
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:latest"
        }

        It 'produces the correct command to invoke with image name, registry and repository provided' {
            $code = {
                StoreMockValue -Key "Invoke-Command" -Value $Command
            }
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerPush -Image 'cool-image' -Repository 'thebestdockerimages' -Registry 'hub.docker.com:1337' -Tag 'v1.0.3'
            $mockResult = GetMockValue -Key 'Invoke-Command'

            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $script:moduleName
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:v1.0.3"
        }
    }
}
