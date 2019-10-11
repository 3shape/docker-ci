Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Tag docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Docker tag image with pester tag' {

        BeforeEach {
            Initialize-MockReg
        }

        $code = {
            Write-Debug $Command
            StoreMockValue -Key "mock" -Value $Command
        }

        It 'tags docker image with image name only' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName

            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:latest"
        }

        It 'tags docker image with image name with pester tag' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'pester' -TargetImage 'lololand' -TargetTag 'pester'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:pester lololand:pester"
        }

        It 'tags docker image with image name with source tag' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'source' -TargetImage 'lololand'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:source lololand:latest"
        }

        It 'tags docker image with image name with target tag' {

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand' -TargetTag 'target'

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:target"
        }
    }
}
