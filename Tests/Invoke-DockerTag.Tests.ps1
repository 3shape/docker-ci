Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Tag docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    $code = {
        Write-Debug $Command
        StoreMockValue -Key "mock" -Value $Command
    }

    BeforeEach {
        Initialize-MockReg
        Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
    }

    Context 'Docker tags public registry images' {

        It 'tags docker image with image name only' {

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

            Invoke-DockerTag -SourceImage 'lalaland' -SourceTag 'source' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:source lololand:latest"
        }

        It 'tags docker image with image name with target tag' {

            Invoke-DockerTag -SourceImage 'lalaland' -TargetImage 'lololand' -TargetTag 'target'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest lololand:target"
        }
    }

    Context 'Docker tags private registry images' {

        It 'tags private docker image as public docker image with image name only' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn' -SourceImage 'lalaland' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/lalaland:latest lololand:latest"
        }

        It 'tags private docker image as public docker image with image name and tag' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn' -SourceImage 'lalaland' -TargetImage 'lololand' -TargetTag 'target'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/lalaland:latest lololand:target"
        }

        It 'tags private docker image with tag as public docker image with image name only' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn' -SourceImage 'lalaland' -SourceTag 'nomansland' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/lalaland:nomansland lololand:latest"
        }

        It 'tags private docker image with tag as public docker image with image name and tag' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn' -SourceImage 'lalaland' -SourceTag 'nomansland' -TargetImage 'lololand' -TargetTag 'target'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/lalaland:nomansland lololand:target"
        }

        It 'tags private docker image as private docker image with image name only' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn/docker-repo' -SourceImage 'lalaland' -TargetRegistry 'dockerhub.com:5999' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/docker-repo/lalaland:latest dockerhub.com:5999/lololand:latest"
        }

        It 'tags private docker image as private docker image with image name and tag' {

            Invoke-DockerTag -SourceRegistry 'artifactoryfqdn' -SourceImage 'lalaland' -TargetRegistry 'dockerhub.com:5999/docker-repo' -TargetImage 'lololand' -TargetTag 'target'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag artifactoryfqdn/lalaland:latest dockerhub.com:5999/docker-repo/lololand:target"
        }

        It 'tags public docker image as private docker image with image name only' {

            Invoke-DockerTag -SourceImage 'lalaland' -TargetRegistry 'dockerhub.com:5999/docker-repo' -TargetImage 'lololand'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest dockerhub.com:5999/docker-repo/lololand:latest"
        }

        It 'tags public docker image as private docker image with image name and tag' {

            Invoke-DockerTag -SourceImage 'lalaland' -TargetRegistry 'dockerhub.com:5999' -TargetImage 'lololand' -TargetTag 'target'
            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            Write-Debug $result
            $result | Should -BeLikeExactly "docker tag lalaland:latest dockerhub.com:5999/lololand:target"
        }
    }

}
