Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'Docker login ' {

    BeforeEach {
        Initialize-MockReg
        $returnsExitCodeZero = {
            Write-Debug $Command
            StoreMockValue -Key "Invoke-Command" -Value $Command
            $result = [CommandResult]::new()
            $result.ExitCode = 0
            return $result
        }
        Mock -CommandName "Invoke-Command" $returnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
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
