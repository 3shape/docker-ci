Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'docker push' {

    Context 'Push an image' {

        BeforeEach {
            Initialize-MockReg
            Mock -CommandName 'Invoke-Command' $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
        }

        AfterEach {
            Assert-MockCalled -CommandName 'Invoke-Command' -ModuleName $Global:ModuleName
        }

        It 'produces the correct command to invoke with only image name provided' {
            Invoke-DockerPush -ImageName 'cool-image'

            $mockResult = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            $mockResult | Should -Be "docker push cool-image:latest"
        }

        It 'produces the correct command to invoke with image name and registry provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages'

            $mockResult = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:latest"
        }

        It 'produces the correct command to invoke with image name and $null registry value provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry $null

            $mockResult = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            $mockResult | Should -Be "docker push cool-image:latest"
        }

        It 'produces the correct command to invoke with image name, registry and tag provided' {
            Invoke-DockerPush -ImageName 'cool-image' -Registry 'hub.docker.com:1337/thebestdockerimages' -Tag 'v1.0.3'

            $mockResult = GetMockValue -Key $Global:InvokeCommandReturnValueKeyName
            $mockResult | Should -Be "docker push hub.docker.com:1337/thebestdockerimages/cool-image:v1.0.3"
        }

        It 'throws an exception if the execution of docker push did not succeed' {
            Mock -CommandName 'Invoke-Command' $Global:CodeThatReturnsExitCodeOne -Verifiable -ModuleName $Global:ModuleName

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
            Mock -CommandName 'Invoke-Command' $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
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
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Verbosity of execution' {

        It 'Outputs result if Quiet is disabled' {
            $tempFile = New-TemporaryFile
            Mock -CommandName 'Invoke-Command' $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName

            Invoke-DockerPush -ImageName 'cool-image' -Quiet:$false 6> $tempFile

            $result = Get-Content $tempFile
            $result | Should -Be @('Hello', 'World')
        }

        It 'Suppresses output if Quiet is enabled' {
            $tempFile = New-TemporaryFile
            Mock -CommandName 'Invoke-Command' $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName

            Invoke-DockerPush -ImageName 'cool-image' -Quiet:$true 6> $tempFile

            $result = Get-Content $tempFile
            $result | Should -BeNullOrEmpty
        }
    }
}
