#Requires -Version 6
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

# Add any variables that are needed globally in test scope
Set-GlobalVar -Variable TestDataDir -Value (Join-Path $PSScriptRoot '../Test-Data')
Set-GlobalVar -Variable PesterTestsDir -Value (Join-Path $Global:TestDataDir 'PesterTests')
Set-GlobalVar -Variable StructureTestsDir -Value (Join-Path $Global:TestDataDir 'StructureTestsConfig')
Set-GlobalVar -Variable StructureTestsPassDir -Value (Join-Path $Global:StructureTestsDir 'Pass')
Set-GlobalVar -Variable StructureTestsFailDir -Value (Join-Path $Global:StructureTestsDir 'Fail')
Set-GlobalVar -Variable ModuleName -Value 'Docker.Build'
