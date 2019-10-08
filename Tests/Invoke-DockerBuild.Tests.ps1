Import-Module $PSScriptRoot/../Docker.Build.psm1
Import-Module $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Commands.ps1"

Describe 'Build docker images' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    Context 'Docker build with latest tag' {
        $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
        $dockerTestData = Join-Path $testData "DockerImage"

        It 'creates correct docker build command' {
            if ($IsWindows) {
                $dockerFile = Join-Path $dockerTestData "Windows.Dockerfile"
            } elseif ($IsLinux) {
                $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            }
            $code = {
                $modulePath = (Get-ChildItem -Recurse "MockReg.psm1" | Select-Object -First 1).FullName;
                Write-Debug $modulePath
                Import-Module $modulePath
                StoreMockValue @{"mock" = $Commands}
            }
            Mock -CommandName "Invoke-Commands" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerBuild -Image "leeandrasmus" -Context $dockerTestData -File $dockerFile

            Assert-MockCalled -CommandName "Invoke-Commands" -ModuleName $script:moduleName
            $result = GetMockValue -Key "mock"
            $result | Should -BeLikeExactly "docker build ${dockerTestData} -t leeandrasmus:latest -f ${dockerFile}"
        }
    }
}
