Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Private\Assert-ExitCodeOk.ps1"

Describe 'Build docker images' {

    $code = {
        Write-Debug $Command
        StoreMockValue -Key "command" -Value $Command
        $result = [CommandResult]::new()
        $result.ExitCode = 0
        return $result
    }

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
            }
            elseif ($IsLinux) {
                $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            }

            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName

            Invoke-DockerBuild -ImageName "leeandrasmus" -Context $dockerTestData -Dockerfile $dockerFile

            Assert-MockCalled -CommandName "Invoke-Command" -ModuleName $script:moduleName

            $result = GetMockValue -Key "command"
            $result | Should -BeLikeExactly "docker build `"${dockerTestData}`" -t leeandrasmus:latest -f `"${dockerFile}`""
        }

        It 'Throws exception if exitcode is not 0' {
            if ($IsWindows) {
                $dockerFile = Join-Path $dockerTestData "Windows.Dockerfile"
            }
            elseif ($IsLinux) {
                $dockerFile = Join-Path $dockerTestData "Linux.Dockerfile"
            }
            $returnExitCodeOne = {
                Write-Debug $Command
                StoreMockValue -Key "command" -Value $Command
                $result = [CommandResult]::new()
                $result.ExitCode = 1
                return $result
            }
            Mock -CommandName "Invoke-Command" $returnExitCodeOne -Verifiable -ModuleName $script:moduleName

            $runner = {
                Invoke-DockerBuild -ImageName "leeandrasmus" -Context $dockerTestData -Dockerfile $dockerFile
            }

            $runner | Should -Throw -ExceptionType ([System.Exception]) -PassThru

        }
    }

    Context 'Pipeline execution' {
        $pipedInput = {
            $input = [PSCustomObject]@{
                "ImageName" = "myimage";
            }
            return $input
        }

        It 'can consume arguments from pipeline' {
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
            & $pipedInput | Invoke-DockerBuild
        }

        It 'returns the expected pscustomobject' {
            Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
            $result = & $pipedInput | Invoke-DockerBuild
            $result.Dockerfile | Should -Not -BeNullOrEmpty
            $result.ImageName | Should -Not -BeNullOrEmpty
        }
    }
}
