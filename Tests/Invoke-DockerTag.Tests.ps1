Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Commands.ps1"

Describe 'Tag docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Docker tag image with pester tag' {

        $code = {
            $modulePath = (Get-ChildItem -Recurse "MockReg.psm1" | Select-Object -First 1).FullName;
            Write-Debug $modulePath
            Import-Module $modulePath
            StoreMockValue @{"mock" = $Commands}
        }

        It 'tags docker image with image name only' {

            Mock -CommandName "Invoke-Commands" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand'

            Assert-MockCalled -CommandName "Invoke-Commands" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:latest"
        }

        It 'tags docker image with image name with latest tag' {

            Mock -CommandName "Invoke-Commands" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'latest' -TargetImage 'lololand' -TargetTag 'latest'

            Assert-MockCalled -CommandName "Invoke-Commands" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:latest"
        }

        It 'tags docker image with image name with source tag' {

            Mock -CommandName "Invoke-Commands" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'source' -TargetImage 'lololand'

            Assert-MockCalled -CommandName "Invoke-Commands" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:source lololand:latest"
        }

        It 'tags docker image with image name with target tag' {

            Mock -CommandName "Invoke-Commands" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand' -TargetTag 'target'

            Assert-MockCalled -CommandName "Invoke-Commands" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:target"
        }
    }
}
