Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Pull docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Pull docker images' {

        BeforeEach {
            Initialize-MockReg
        }

        $code = {
            Write-Debug $Command
            StoreMockValue -Key "mock" -Value $Command
        }

        It 'pulls docker image with image name only' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName

            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:latest"
        }

        It 'pulls docker image with image name with random tag' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'latest' -TargetImage 'lololand' -TargetTag 'latest'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:latest"
        }

        It 'pulls docker image with ID' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'source' -TargetImage 'lololand'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:source lololand:latest"
        }

        It 'fails to pull docker image with both image name and ID' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand' -TargetTag 'target'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:target"
        }
    }
}
