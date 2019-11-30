#Requires -Version 6

Import-Module -Global -Force $PSScriptRoot/MockReg.psm1
function Set-GlobalVar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Variable,
        [Parameter(Mandatory = $true)]
        $Value
    )
    $variableIsSet = Test-Path "variable:global:${Variable}"
    if (!$variableIsSet) {
        Set-Variable -Name $Variable -Value $Value -Option Constant -Scope Global -Force
    }
}

# Set the module to quiet mode for testing purposes so we don't spam the test logs.
$env:DOCKER_CI_QUIET_MODE = $true

# Add any variables that are needed globally in test scope
Set-GlobalVar -Variable TestDataDir -Value (Join-Path $PSScriptRoot '../Test-Data')
Set-GlobalVar -Variable DockerImagesDir -Value(Join-Path $Global:TestDataDir 'DockerImage')
Set-GlobalVar -Variable ExampleReposDir -Value(Join-Path $Global:TestDataDir 'ExampleRepos')
Set-GlobalVar -Variable TestBinariesDir -Value(Join-Path $Global:TestDataDir 'Binaries')
Set-GlobalVar -Variable LocalDockerRegistryDir -Value(Join-Path $Global:TestDataDir 'DockerRegistry')
Set-GlobalVar -Variable PesterTestsDir -Value (Join-Path $Global:TestDataDir 'PesterTests')
Set-GlobalVar -Variable StructureTestsDir -Value (Join-Path $Global:TestDataDir 'StructureTestsConfig')
Set-GlobalVar -Variable StructureTestsPassDir -Value (Join-Path $Global:StructureTestsDir 'Pass')
Set-GlobalVar -Variable StructureTestsFailDir -Value (Join-Path $Global:StructureTestsDir 'Fail')

Set-GlobalVar -Variable ModuleName -Value 'Docker-CI'
Set-GlobalVar -Variable LocalDockerRegistry -Value 'localhost:5000'
Set-GlobalVar -Variable LocalDockerRegistryName -Value 'registry'
Set-GlobalVar -Variable InvokeCommandReturnValueKeyName -Value 'command'
Set-GlobalVar -Variable InvokeCommandArgsReturnValueKeyName -Value 'commandargs'
Set-GlobalVar -Variable InvokeCommandAndReturnOneKeyName -Value 'command'
Set-GlobalVar -Variable InvokeCommandAndReturnOneArgsKeyName -Value 'commandargs'
# Global scriptblocks
Set-GlobalVar -Variable CodeThatReturnsExitCodeZero -Value {
    StoreMockValue -Key $Global:InvokeCommandReturnValueKeyName -Value $Command
    StoreMockValue -Key $Global:InvokeCommandArgsReturnValueKeyName -Value $CommandArgs
    $result = [CommandCoreResult]::new()
    $result.Output = @("Hello", "World")
    $result.ExitCode = 0
    return $result
}

Set-GlobalVar -Variable CodeThatReturnsExitCodeOne -Value {
    StoreMockValue -Key $Global:InvokeCommandAndReturnOneKeyName -Value $Command
    StoreMockValue -Key $Global:InvokeCommandAndReturnOneArgsKeyName -Value $CommandArgs
    $result = [CommandCoreResult]::new()
    $result.ExitCode = 1
    return $result
}

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Source\Private\Invoke-DockerCommand.ps1"
. "$PSScriptRoot\..\Source\Private\Assert-ExitCodeOk.ps1"
. "$PSScriptRoot\..\Source\Private\Find-DockerOSType.ps1"
. "$PSScriptRoot\..\Source\Private\CommandCoreResult.ps1"
. "$PSScriptRoot\..\Source\Private\New-Process.ps1"

Set-GlobalVar -Variable DockerOsType -Value (Find-DockerOSType)
