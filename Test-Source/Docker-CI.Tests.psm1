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
    $result = [CommandResult]::new()
    $result.Output = @("Hello", "World")
    $result.ExitCode = 0
    return $result
}

Set-GlobalVar -Variable CodeThatReturnsExitCodeOne -Value {
    StoreMockValue -Key $Global:InvokeCommandAndReturnOneKeyName -Value $Command
    StoreMockValue -Key $Global:InvokeCommandAndReturnOneArgsKeyName -Value $CommandArgs
    $result = [CommandResult]::new()
    $result.ExitCode = 1
    return $result
}

Set-GlobalVar -Variable DockerPsOutput -Value @(
    'CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES',
    'a28e1ca69345        jenkins.agent:bionic   "jenkins-agent"     41 minutes ago      Up 41 minutes                           jenkins.agent'
)
Set-GlobalVar -Variable DockerPsMockCode -Value {
    $result = [CommandResult]::new()
    $result.Output = $Global:DockerPsOutput
    $result.StdOut = $Global:DockerPsOutput
    $result.ExitCode = 0
    return $result
}

Set-GlobalVar -Variable DockerInspectOutput -Value @(
    ' /home/devops/workspace=/home/jenkins/workspace',
    '  /var/run/docker.sock=/var/run/docker.sock',
    '  /var/lib/docker/volumes/5c15f2a0ff099e4a6d59a863a9dfa4580e5615798987200bed2e98acd26fd3f8/_data=/home/jenkins/.jenkins',
    '  /var/lib/docker/volumes/b29f5bbedd3a667ee45f0dde717a2c9b8092af81e0b9da92f9499f5c10a6c12e/_data=/home/jenkins/agent',
    '  c:\devops\workspace=c:\jenkins\workspace',
    '  \\.\pipe\docker_engine=\\.\pipe\docker_engine'
)

Set-GlobalVar -Variable DockerInspectMockCode -Value {
    $result = [CommandResult]::new()
    $result.Output = $Global:DockerInspectOutput
    $result.StdOut = $Global:DockerInspectOutput
    $result.ExitCode = 0
    return $result
}

Set-GlobalVar -Variable DockerContainerHostname -Value 'a28e1ca69345' # must be part of DockerPsMockCode

if ($IsWindows) {
    Set-GlobalVar -Variable WorkspaceAbsolutePath -Value 'c:\jenkins\workspace\mybuild'
    Set-GlobalVar -Variable DockerHostAbsolutePath -Value 'c:\devops\workspace\mybuild'
} elseif ($IsLinux) {
    Set-GlobalVar -Variable WorkspaceAbsolutePath -Value '/home/jenkins/workspace/mybuild'
    Set-GlobalVar -Variable DockerHostAbsolutePath -Value '/home/devops/workspace/mybuild'
}


. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Source\Private\Invoke-DockerCommand.ps1"
. "$PSScriptRoot\..\Source\Private\Assert-ExitCodeOk.ps1"
. "$PSScriptRoot\..\Source\Private\Find-DockerOSType.ps1"
. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Source\Private\New-Process.ps1"
. "$PSScriptRoot\..\Source\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Source\Private\Utilities.ps1"
. "$PSScriptRoot\New-RandomFolder.ps1"

Set-GlobalVar -Variable DockerOsType -Value (Find-DockerOSType)
