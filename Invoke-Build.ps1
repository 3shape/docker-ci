Invoke-Psake -buildFile Build.ps1 -taskList build
exit ( [int]( -not $psake.build_success ) )
