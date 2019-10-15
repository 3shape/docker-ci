Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Private\CommandResult.ps1"

Describe 'docker push' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
    }

    BeforeEach {
        Initialize-MockReg
        $code = {
            Write-Debug $Command
            StoreMockValue -Key "Invoke-Command" -Value $Command
        }
        Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
    }

    Context 'Push an image' {

        It 'produces the correct command to invoke' {
            Invoke-DockerLogin -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'Invoke-Command'
            $result | Should -BeLikeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin'
        }
    }

    Context 'Login to specific docker registry' {

        It 'produced the correct command to invoke' {
            Invoke-DockerLogin -Registry 'my.docker.registry' -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'Invoke-Command'
            $result | Should -BeLikeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin my.docker.registry'
        }
    }
}
