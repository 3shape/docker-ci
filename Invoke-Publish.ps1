Get-Module Docker.Build | Remove-Module
Invoke-Psake -buildFile "$PSScriptRoot/Build.ps1" -taskList build, publish
exit ( [int]( -not $psake.build_success ) )
