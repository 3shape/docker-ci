Invoke-Psake -buildFile "$PSScriptRoot/Build.ps1" -taskList build,test
exit ( [int]( -not $psake.build_success ) )
