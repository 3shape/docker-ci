Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'Docker login ' {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\Source\*.psd1)[0].BaseName
    }

    BeforeEach {
        Initialize-MockReg
        $code = {
            Write-Debug $Command
            StoreMockValue -Key "Invoke-Command" -Value $Command
            $result = [CommandResult]::new()
            $result.ExitCode = 0
            return $result
        }
        Mock -CommandName "Invoke-Command" $code -Verifiable -ModuleName $script:moduleName
    }

    Context 'Login to default docker registry' {

        It 'produced the correct command to invoke' {
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

        It 'produced the correct command to invoke, with $null registry parameter' {
            Invoke-DockerLogin -Registry $null -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'Invoke-Command'
            $result | Should -BeLikeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin'
        }
    }
}