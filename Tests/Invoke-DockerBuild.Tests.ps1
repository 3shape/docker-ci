Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"

Describe 'Build docker images' {



    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Docker build with latest tag' {
        BeforeEach {
            Initialize-MockReg
        }

        $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
        $dockerTestData = Join-Path $testData "DockerImage"

        It 'creates correct docker build command' {
            if ($IsWindows) {
                $dockerFile = Join-Path $dockerTestData "Windows.Dockerfile"
            } elseif ($IsLinux) {
                $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            }
            $code = {
                Write-Debug $Command
                StoreMockValue -Key "command" -Value $Command
            }

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $dockerTestData -File $dockerFile

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName

            $result = GetMockValue -Key "command"
            $result | Should -BeLikeExactly "docker build `"${dockerTestData}`" -t leeandrasmus:latest -f `"${dockerFile}`""
        }
    }
}
